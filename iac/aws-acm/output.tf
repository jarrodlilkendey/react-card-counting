output "acm_dns_validation_records" {
  description = "Human-readable DNS records for ACM DNS validation"
  value = [
    for dns_record in aws_acm_certificate.my_domain_cert.domain_validation_options :
    "${dns_record.domain_name}:  ${dns_record.resource_record_name}  ${dns_record.resource_record_type}  ${dns_record.resource_record_value}"
  ]
}