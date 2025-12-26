output "db_endpoint" {
  value = aws_db_instance.this.endpoint
}

output "db_password_secret_arn" {
  value = aws_secretsmanager_secret.db_password.arn
}

# 管理者パスワードもSecrets Managerで管理するため追加
output "admin_password_secret_arn" {
  value = aws_secretsmanager_secret.admin_password.arn
}

output "rds_sg_id" {
  value = aws_security_group.rds.id
}
