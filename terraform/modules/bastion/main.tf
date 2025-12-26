# 最新の Amazon Linux 2023 AMI を取得
data "aws_ami" "amazon_linux_2023" {
  most_recent = true
  owners      = ["amazon"]
  filter {
    name   = "name"
    values = ["al2023-ami-2023*-kernel-6.1-arm64"] # ARM64 (t4g用)
  }
}

# --- IAM Role for SSM ---
resource "aws_iam_role" "bastion" {
  name = "${var.env}-bastion-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action    = "sts:AssumeRole"
      Effect    = "Allow"
      Principal = { Service = "ec2.amazonaws.com" }
    }]
  })
}

# SSMを許可する標準ポリシーをアタッチ
resource "aws_iam_role_policy_attachment" "ssm_managed" {
  role       = aws_iam_role.bastion.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

resource "aws_iam_instance_profile" "bastion" {
  name = "${var.env}-bastion-profile"
  role = aws_iam_role.bastion.name
}

# --- Security Group ---
resource "aws_security_group" "bastion" {
  name        = "${var.env}-bastion-sg"
  description = "Security group for bastion host (SSM only)"
  vpc_id      = var.vpc_id

  # インバウンドは全て拒否（SSMはアウトバウンドから確立されるため不要）

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group_rule" "bastion_to_rds" {
  type                     = "ingress"
  from_port                = 5432
  to_port                  = 5432
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.bastion.id
  security_group_id        = var.rds_sg_id
}

# --- EC2 Instance ---
resource "aws_instance" "this" {
  ami           = data.aws_ami.amazon_linux_2023.id
  instance_type = "t4g.nano" # コスト最適

  subnet_id                   = var.subnet_id
  vpc_security_group_ids      = [aws_security_group.bastion.id]
  iam_instance_profile        = aws_iam_instance_profile.bastion.name
  associate_public_ip_address = false # プライベートサブネットに配置

  metadata_options {
    http_tokens = "required" # IMDSv2を強制 (Security Best Practice)
  }

  tags = {
    Name = "${var.env}-bastion"
  }
}

# インスタンスIDをSSM Parameter Storeに保存（scripts/tunnel.shで使用）
resource "aws_ssm_parameter" "bastion_id" {
  name  = "/${var.env}/network/bastion_instance_id"
  type  = "String"
  value = aws_instance.this.id
}
