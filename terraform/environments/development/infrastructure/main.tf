# 1. Network: VPC, Subnets, IGW, NAT
module "network" {
  source          = "../../../modules/network"
  env             = var.environment
  vpc_cidr        = var.vpc_cidr
  public_subnets  = var.public_subnet_cidrs
  private_subnets = var.private_subnet_cidrs
  azs             = var.availability_zones
}

# 2. DNS & Certificate: Route53 Zone B, NS Delegation to Account C, ACM
module "dns" {
  source             = "../../../modules/dns"
  env                = var.environment
  domain_name        = var.domain_name
  parent_domain_name = var.parent_domain_name

  # Account C操作用のエイリアスプロバイダを渡す
  providers = {
    aws.dns_account = aws.dns_account
  }
}

module "mail" {
  source = "../../../modules/mail"

  env          = var.environment
  service_name = var.mail_service_name
  domain_name  = var.domain_name
  zone_id      = module.dns.zone_id
  aws_region   = var.region
  from_email   = var.from_email
}

# 4. Keycloak App: ALB, ECS, ECR, IAM, Route53 A-Record
module "keycloak_app" {
  source          = "../../../modules/keycloak-app"
  env             = var.environment
  vpc_id          = module.network.vpc_id
  public_subnets  = module.network.public_subnet_ids
  private_subnets = module.network.private_subnet_ids

  # DNSモジュールからの出力を利用
  acm_certificate_arn = module.dns.certificate_arn
  zone_id             = module.dns.zone_id
  domain_name         = var.domain_name

  # Database/Bastionとの連携
  db_endpoint        = module.database.db_endpoint
  db_password_arn    = module.database.db_password_secret_arn
  admin_password_arn = module.database.admin_password_secret_arn
  bastion_sg_id      = module.bastion.security_group_id

  rds_sg_id                   = module.database.rds_sg_id
  terraform_client_secret_arn = module.keycloak_app.terraform_client_secret_arn
  ses_smtp_credentials_secret_arn = module.mail.smtp_credentials_secret_arn
  ses_smtp_endpoint               = module.mail.smtp_endpoint
  ses_smtp_port                   = module.mail.smtp_port
  ses_from_email                  = module.mail.from_email
  ses_from_display_name           = "Keycloak Dev"
}

# 5. Database: RDS Instance & Security Group
module "database" {
  source      = "../../../modules/database"
  env         = var.environment
  vpc_id      = module.network.vpc_id
  subnet_ids  = module.network.private_subnet_ids
  db_password = var.db_password

  # Keycloak App(ECS)からの接続のみを許可するためのSG ID
  # app_sg_id      = module.keycloak_app.ecs_sg_id
  admin_password = var.db_admin_password
}

module "bastion" {
  source    = "../../../modules/bastion"
  env       = var.environment
  vpc_id    = module.network.vpc_id
  subnet_id = module.network.private_subnet_ids[0]
  rds_sg_id = module.database.rds_sg_id
}
