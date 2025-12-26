variable "env" {
  description = "Environment name (e.g., dev, staging, prod)"
  type = string
}

variable "vpc_id" {
  description = "VPC ID where the RDS instance will be deployed"
  type = string
}

variable "subnet_ids" {
  description = "List of subnet IDs for the RDS subnet group"
  type = list(string)
}

variable "db_password" {
  description = "Master password for the RDS database"
  type = string
  sensitive = true
}

variable "admin_password" {
  description = "Admin password for Keycloak"
  type = string
  sensitive = true
}

# variable "app_sg_id" {
#   description = "Security Group ID of the application allowed to access the database"
#   type = string
# }
