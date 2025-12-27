# =============================================================================
# General
# =============================================================================
variable "environment" {
  description = "Environment name"
  type        = string
}

variable "region" {
  description = "AWS region"
  type        = string
  default     = "ap-northeast-1"
}

variable "aws_profile_auth" {
  description = "AWS CLI profile for Auth account"
  type        = string
}

variable "aws_profile_network" {
  description = "AWS CLI profile for Network account"
  type        = string
}

variable "aws_profile_shared" {
  description = "AWS CLI profile for Shared account"
  type        = string
}

variable "dns_account_assume_role" {
  description = "ARN of the role to assume for cross-account access"
  type        = string
}

# =============================================================================
# Network
# =============================================================================
variable "vpc_cidr" {
  description = "CIDR block for VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "public_subnet_cidrs" {
  description = "List of CIDR blocks for public subnets"
  type        = list(string)
  default     = ["10.0.1.0/24", "10.0.2.0/24"]
}

variable "private_subnet_cidrs" {
  description = "List of CIDR blocks for private subnets"
  type        = list(string)
  default     = ["10.0.10.0/24", "10.0.20.0/24"]
}

variable "availability_zones" {
  description = "List of availability zones"
  type        = list(string)
  default     = ["ap-northeast-1a", "ap-northeast-1c"]
}

# =============================================================================
# DNS
# =============================================================================
variable "domain_name" {
  description = "Domain name for the auth service"
  type        = string
}

variable "parent_domain_name" {
  description = "Parent domain name (in Account C)"
  type        = string
}

# =============================================================================
# Mail
# =============================================================================
variable "mail_service_name" {
  description = "Service name for mail (e.g., keycloak)"
  type        = string
}

variable "from_email" {
  description = "Default from email address"
  type        = string
  default     = "noreply"
}

# =============================================================================
# Database
# =============================================================================
variable "db_instance_class" {
  description = "RDS instance class"
  type        = string
  default     = "db.t3.micro"
}

variable "db_multi_az" {
  description = "Enable Multi-AZ for RDS"
  type        = bool
  default     = false
}

variable "db_password" {
  description = "Master password for the RDS database"
  type        = string
}

variable "db_admin_password" {
  description = "Admin password for Keycloak"
  type        = string
}

# =============================================================================
# ECS
# =============================================================================
variable "keycloak_image_tag" {
  description = "Keycloak Docker image tag"
  type        = string
  default     = "latest"
}

variable "keycloak_cpu" {
  description = "CPU units for Keycloak task"
  type        = number
  default     = 512
}

variable "keycloak_memory" {
  description = "Memory (MiB) for Keycloak task"
  type        = number
  default     = 1024
}

variable "keycloak_desired_count" {
  description = "Desired count of Keycloak tasks"
  type        = number
  default     = 1
}
