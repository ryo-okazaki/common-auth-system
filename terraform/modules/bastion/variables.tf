variable "env" {
  type = string
}

variable "vpc_id" {
  type = string
}

variable "subnet_id" {
  type = string
}

variable "rds_sg_id" {
  description = "RDS security group ID for bastion access"
  type        = string
}
