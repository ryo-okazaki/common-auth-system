output "domain_identity_arn" {
  description = "SES Domain Identity ARN"
  value       = aws_ses_domain_identity.this.arn
}

output "smtp_endpoint" {
  description = "SES SMTP endpoint"
  value       = "email-smtp.${var.aws_region}.amazonaws.com"
}

output "smtp_port" {
  description = "SES SMTP port (STARTTLS)"
  value       = 587
}

output "smtp_credentials_secret_arn" {
  description = "ARN of Secrets Manager secret containing SMTP credentials"
  value       = aws_secretsmanager_secret.ses_smtp.arn
}

output "from_email" {
  description = "From email address"
  value       = "${var.from_email}@${var.domain_name}"
}