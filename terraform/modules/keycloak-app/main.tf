# --- ECR Repository ---
resource "aws_ecr_repository" "this" {
  name                 = "${var.env}-keycloak"
  image_tag_mutability = "MUTABLE"
  force_delete         = true

  image_scanning_configuration {
    scan_on_push = true
  }
}

resource "null_resource" "push_keycloak_image" {
  depends_on = [aws_ecr_repository.this]

  triggers = {
    ecr_repository_url = aws_ecr_repository.this.repository_url
  }

  provisioner "local-exec" {
    command     = "bash ${path.module}/docker/push-ecr-image.sh"
    environment = {
      ECR_REPOSITORY_URL = aws_ecr_repository.this.repository_url
      KEYCLOAK_VERSION   = "26.0"
    }
  }
}

# --- IAM Roles for ECS ---
# 1. Task Execution Role (ECS AgentがSecrets取得やログ出力に利用)
resource "aws_iam_role" "execution" {
  name = "${var.env}-keycloak-execution-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = { Service = "ecs-tasks.amazonaws.com" }
    }]
  })
}

resource "aws_iam_role_policy_attachment" "task_ssm" {
  role       = aws_iam_role.task.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

resource "aws_iam_role_policy_attachment" "execution_basic" {
  role       = aws_iam_role.execution.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

# Secrets Managerへのアクセス許可を追加
resource "aws_iam_policy" "secrets_access" {
  name = "${var.env}-keycloak-secrets-policy"
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect   = "Allow"
      Action   = "secretsmanager:GetSecretValue"
      Resource = [
        var.db_password_arn,
        var.admin_password_arn,
        aws_secretsmanager_secret.terraform_client_secret.arn
      ]
    }]
  })
}

resource "aws_iam_role_policy_attachment" "execution_secrets" {
  role       = aws_iam_role.execution.name
  policy_arn = aws_iam_policy.secrets_access.arn
}

# 2. Task Role (Keycloakアプリケーション本体がAWS APIを叩く際に利用)
resource "aws_iam_role" "task" {
  name = "${var.env}-keycloak-task-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = { Service = "ecs-tasks.amazonaws.com" }
    }]
  })
}

# --- Security Groups ---
# ALB Security Group
resource "aws_security_group" "alb" {
  name        = "${var.env}-keycloak-alb-sg"
  vpc_id      = var.vpc_id
  description = "ALB for Keycloak"

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# ECS Security Group
resource "aws_security_group" "ecs" {
  name        = "${var.env}-keycloak-ecs-sg"
  vpc_id      = var.vpc_id
  description = "ECS for Keycloak"

  # ALBからのトラフィック
  ingress {
    from_port       = 8080
    to_port         = 8080
    protocol        = "tcp"
    security_groups = [aws_security_group.alb.id]
  }

  # ALBからのヘルスチェック用
  ingress {
    from_port       = 9000
    to_port         = 9000
    protocol        = "tcp"
    security_groups = [aws_security_group.alb.id]
  }

  # Bastion(SSM Tunnel)からのトラフィック
  ingress {
    from_port       = 8080
    to_port         = 8080
    protocol        = "tcp"
    security_groups = [var.bastion_sg_id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# ECS から RDS への接続を許可
resource "aws_security_group_rule" "ecs_to_rds" {
  type                     = "ingress"
  from_port                = 5432
  to_port                  = 5432
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.ecs.id
  security_group_id        = var.rds_sg_id
}

# --- ALB Components ---
resource "aws_lb" "this" {
  name               = "${var.env}-keycloak-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb.id]
  subnets            = var.public_subnets
}

resource "aws_lb_target_group" "this" {
  name        = "${var.env}-keycloak-tg"
  port        = 8080
  protocol    = "HTTP"
  vpc_id      = var.vpc_id
  target_type = "ip"

  health_check {
    path                = "/health/live"
    port = "9000"
    healthy_threshold   = 3
    unhealthy_threshold = 3
    timeout             = 5
    interval            = 30
    matcher             = "200-399"
  }
}

resource "aws_lb_listener" "https" {
  load_balancer_arn = aws_lb.this.arn
  port              = "443"
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-2016-08"
  certificate_arn   = var.acm_certificate_arn

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.this.arn
  }
}

# --- ECS Cluster & Service ---
resource "aws_ecs_cluster" "this" {
  name = "${var.env}-keycloak-cluster"
}

resource "aws_cloudwatch_log_group" "this" {
  name              = "/ecs/${var.env}-keycloak"
  retention_in_days = 30
}

resource "aws_ecs_task_definition" "this" {
  family                   = "keycloak"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = "512"
  memory                   = "1024"
  execution_role_arn       = aws_iam_role.execution.arn
  task_role_arn            = aws_iam_role.task.arn

  container_definitions = jsonencode([
    {
      name  = "keycloak"
      image = "${aws_ecr_repository.this.repository_url}:26.0"
      essential = true

      # 本番モードで起動
      # command = ["start", "--optimized"]
      command = ["start"]

      portMappings = [
        { containerPort = 8080, hostPort = 8080 },
        { containerPort = 9000, hostPort = 9000 }
      ]

      environment = [
        { name = "KC_DB", value = "postgres" },
        { name = "KC_DB_URL", value = "jdbc:postgresql://${var.db_endpoint}/keycloak" },
        { name = "KC_DB_USERNAME", value = "keycloak" },
        { name = "KC_HOSTNAME", value = "https://${var.domain_name}" },

        { name = "KC_PROXY", value = "edge" },
        # { name = "KC_PROXY_HEADERS", value = "xforwarded" },
        { name = "KC_HTTP_ENABLED", value = "true" },
        # { name = "KC_HOSTNAME_STRICT", value = "false" },
        # { name = "KC_HOSTNAME_STRICT_HTTPS", value = "false" },
        { name = "KC_LOG_LEVEL", value = "INFO" },
        { name = "KC_HEALTH_ENABLED", value = "true" },
        { name = "KC_METRICS_ENABLED", value = "true" },

        { name = "KEYCLOAK_ADMIN", value = "admin" }
      ]
      secrets = [
        { name = "KC_DB_PASSWORD", valueFrom = var.db_password_arn },
        { name = "KEYCLOAK_ADMIN_PASSWORD", valueFrom = var.admin_password_arn }
      ]
      logConfiguration = {
        logDriver = "awslogs"
        options = {
          "awslogs-group"         = aws_cloudwatch_log_group.this.name
          "awslogs-region"        = "ap-northeast-1"
          "awslogs-stream-prefix" = "ecs"
        }
      }
    }
  ])
}

resource "aws_ecs_service" "this" {
  name            = "keycloak-service"
  cluster         = aws_ecs_cluster.this.id
  task_definition = aws_ecs_task_definition.this.arn
  desired_count   = 1
  launch_type     = "FARGATE"

  enable_execute_command = true

  network_configuration {
    subnets         = var.private_subnets
    security_groups = [aws_security_group.ecs.id]
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.this.arn
    container_name   = "keycloak"
    container_port   = 8080
  }

  # lifecycle {
  #   ignore_changes = [task_definition] # デプロイパイプライン(CI/CD)がある場合は無視設定を推奨
  # }
}

resource "aws_route53_record" "alb" {
  zone_id = var.zone_id # dnsモジュールから受け取ったホストゾーンID
  name    = var.domain_name
  type    = "A"

  alias {
    name                   = aws_lb.this.dns_name
    zone_id                = aws_lb.this.zone_id
    evaluate_target_health = true
  }
}
