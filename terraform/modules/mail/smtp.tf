# ==============================================================================
# IAM User for SES SMTP Authentication
# ==============================================================================

resource "aws_iam_user" "ses_smtp" {
  name = "${var.env}-${var.service_name}-ses-smtp"

  tags = {
    Name        = "${var.env}-${var.service_name}-ses-smtp"
    Environment = var.env
    Purpose     = "SES SMTP authentication for ${var.service_name}"
  }
}

resource "aws_iam_user_policy" "ses_smtp" {
  name = "${var.env}-${var.service_name}-ses-send"
  user = aws_iam_user.ses_smtp.name

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid      = "AllowSendEmail"
        Effect   = "Allow"
        Action   = ["ses:SendEmail", "ses:SendRawEmail"]
        Resource = "*"
        Condition = {
          StringLike = {
            "ses:FromAddress" = "*@${var.domain_name}"
          }
        }
      }
    ]
  })
}

resource "aws_iam_access_key" "ses_smtp" {
  user = aws_iam_user.ses_smtp.name
}

# ==============================================================================
# Store SMTP Credentials in Secrets Manager
# ==============================================================================

resource "aws_secretsmanager_secret" "ses_smtp" {
  name        = "${var.env}/${var.service_name}/ses-smtp-credentials"
  description = "SES SMTP credentials for ${var.service_name}"

  tags = {
    Name        = "${var.env}-${var.service_name}-ses-smtp"
    Environment = var.env
  }
}

resource "aws_secretsmanager_secret_version" "ses_smtp" {
  secret_id = aws_secretsmanager_secret.ses_smtp.id
  secret_string = jsonencode({
    username = aws_iam_access_key.ses_smtp.id
    password = aws_iam_access_key.ses_smtp.ses_smtp_password_v4
  })
}
