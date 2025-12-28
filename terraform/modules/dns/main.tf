terraform {
  required_providers {
    aws = {
      source                = "hashicorp/aws"
      configuration_aliases = [aws.dns_account]
    }
  }
}

# Account B側でサブドメインのホストゾーンを作成
resource "aws_route53_zone" "sub" {
  name = var.domain_name

  tags = {
    Name = var.domain_name
  }
}

# Account C側（Parent Zone）にNSレコードを書き込み
data "aws_route53_zone" "parent" {
  provider = aws.dns_account
  name     = var.parent_domain_name
}

resource "aws_route53_record" "ns" {
  provider = aws.dns_account
  zone_id  = data.aws_route53_zone.parent.zone_id
  name     = var.domain_name
  type     = "NS"
  ttl      = 300
  records  = aws_route53_zone.sub.name_servers
}

# ACM 証明書
resource "aws_acm_certificate" "this" {
  domain_name = var.domain_name
  subject_alternative_names = [
    "*.${var.domain_name}" # *.dev.auth.ryo-okazaki.com
  ]

  validation_method = "DNS"

  lifecycle {
    create_before_destroy = true
  }

  tags = {
    Name = "${var.env}-acm-certificate"
  }
}

resource "aws_route53_record" "cert_validation" {
  for_each = {
    for dvo in aws_acm_certificate.this.domain_validation_options : dvo.domain_name => {
      name   = dvo.resource_record_name
      record = dvo.resource_record_value
      type   = dvo.resource_record_type
    }
  }
  allow_overwrite = true
  name            = each.value.name
  records         = [each.value.record]
  ttl             = 60
  type            = each.value.type
  zone_id         = aws_route53_zone.sub.zone_id
}
