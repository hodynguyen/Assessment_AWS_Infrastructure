output "hosted_zone_id" {
  value = aws_route53_zone.this.zone_id
}

output "ui_record" {
  value = aws_route53_record.ui_record.fqdn
}

output "api_record" {
  value = aws_route53_record.api_record.fqdn
}
