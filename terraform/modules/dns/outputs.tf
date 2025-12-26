output "certificate_arn" {
  value = aws_acm_certificate.this.arn
}

output "zone_id" {
  value = aws_route53_zone.sub.zone_id
}
