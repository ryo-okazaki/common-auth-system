# Primary provider
provider "aws" {
  region = var.region
  # profile = var.aws_profile_auth

  default_tags {
    tags = {
      Environment = var.environment
      Project     = "auth"
      ManagedBy   = "Terraform"
    }
  }
}

# For Route 53 parent zone delegation
provider "aws" {
  alias  = "dns_account"
  region = "ap-northeast-1" # Route53はGlobalだが指定が必要

  assume_role {
    role_arn = var.dns_account_assume_role
  }
}
