variable "env" {
  type = string
}

variable "vpc_id" {
  type = string
}

variable "public_subnets" {
  type = list(string)
}

variable "private_subnets" {
  type = list(string)
}

variable "db_endpoint" {
  type = string
}

variable "db_password_arn" {
  type = string
}

variable "admin_password_arn" {
  type = string
}

variable "acm_certificate_arn" {
  type = string
}

variable "domain_name" {
  type = string
}

variable "bastion_sg_id" {
  type = string
}

variable "zone_id" {
  type = string
}

variable "rds_sg_id" {
  description = "RDS security group ID"
  type        = string
}
