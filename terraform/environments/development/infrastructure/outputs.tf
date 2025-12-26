# =============================================================================
# General / DNS
# =============================================================================

output "keycloak_url" {
  description = "The public URL of the Keycloak instance"
  value       = "https://${var.domain_name}"
}

output "route53_zone_id" {
  description = "The Route53 Hosted Zone ID for Account B"
  value       = module.dns.zone_id
}

output "acm_certificate_arn" {
  description = "The ARN of the ACM certificate used by the ALB"
  value       = module.dns.certificate_arn
}

# =============================================================================
# Network
# =============================================================================

output "vpc_id" {
  description = "The ID of the VPC"
  value       = module.network.vpc_id
}

output "public_subnet_ids" {
  description = "List of public subnet IDs"
  value       = module.network.public_subnet_ids
}

output "private_subnet_ids" {
  description = "List of private subnet IDs"
  value       = module.network.private_subnet_ids
}

# =============================================================================
# Compute (ALB / ECS / ECR)
# =============================================================================

output "alb_dns_name" {
  description = "The DNS name of the ALB"
  value       = module.keycloak_app.alb_dns_name
}

output "ecr_repository_url" {
  description = "The URL of the ECR repository for Keycloak"
  value       = module.keycloak_app.ecr_repository_url
}

output "ecs_cluster_name" {
  description = "The name of the ECS cluster"
  value       = module.keycloak_app.ecs_cluster_name
}

output "bastion_instance_id" {
  description = "The ID of the bastion host (Used for SSM Tunneling)"
  value       = module.bastion.instance_id
}

# =============================================================================
# Database & Secrets
# =============================================================================

output "db_endpoint" {
  description = "The connection endpoint for the RDS instance"
  value       = module.database.db_endpoint
}

output "db_password_secret_arn" {
  description = "The ARN of the secret containing the DB password"
  value       = module.database.db_password_secret_arn
}

output "admin_password_secret_arn" {
  description = "The ARN of the secret containing the Keycloak admin password"
  value       = module.database.admin_password_secret_arn
}
