output "hosted_zone_id" {
  value = aws_route53_zone.domain.zone_id
}

output "certificate_arn" {
  value = aws_acm_certificate_validation.domain.certificate_arn
}
