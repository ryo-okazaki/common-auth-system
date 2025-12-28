# modules/database/main.tf
resource "aws_db_subnet_group" "this" {
  name       = "${var.env}-db-subnet-group"
  subnet_ids = var.subnet_ids
}

resource "aws_security_group" "rds" {
  name   = "${var.env}-rds-sg"
  vpc_id = var.vpc_id

  # ingress {
  #   from_port       = 5432
  #   to_port         = 5432
  #   protocol        = "tcp"
  #   security_groups = [var.app_sg_id] # ECSからのアクセスのみ許可
  # }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_db_instance" "this" {
  identifier        = "${var.env}-keycloak-db"
  engine            = "postgres"
  engine_version    = "15"
  instance_class    = "db.t4g.micro"
  allocated_storage = 20
  db_name           = "keycloak"
  username          = "keycloak"
  password          = var.db_password

  db_subnet_group_name   = aws_db_subnet_group.this.name
  vpc_security_group_ids = [aws_security_group.rds.id]
  skip_final_snapshot    = true
  multi_az               = true

  lifecycle {
    # prevent_destroy = true # 誤削除防止
    prevent_destroy = false
  }
}

# Secrets Managerでのパスワード管理
resource "aws_secretsmanager_secret" "db_password" {
  name                    = "/${var.env}/keycloak/db_password"
  recovery_window_in_days = 0
}

resource "aws_secretsmanager_secret_version" "db_password" {
  secret_id     = aws_secretsmanager_secret.db_password.id
  secret_string = var.db_password
}

resource "aws_secretsmanager_secret" "admin_password" {
  name                    = "/${var.env}/keycloak/db_admin_password"
  recovery_window_in_days = 0
}

resource "aws_secretsmanager_secret_version" "admin_password" {
  secret_id     = aws_secretsmanager_secret.admin_password.id
  secret_string = var.admin_password
}
