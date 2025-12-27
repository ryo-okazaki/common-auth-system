variable "env" {
  description = "Environment name"
  type        = string
}

variable "service_name" {
  description = "Service name (e.g., keycloak)"
  type        = string
  default     = "keycloak"
}

variable "domain_name" {
  description = "Domain name for SES (e.g., dev.auth.ryo-okazaki.com)"
  type        = string
}

variable "zone_id" {
  description = "Route 53 Hosted Zone ID"
  type        = string
}

variable "aws_region" {
  description = "AWS Region"
  type        = string
  default     = "ap-northeast-1"
}

variable "from_email" {
  description = "Default from email address"
  type        = string
  default     = "noreply"
}