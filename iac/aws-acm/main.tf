resource "aws_acm_certificate" "my_domain_cert" {
  region            = var.REGION
  domain_name       = "${var.DOMAIN_NAME}"
  
  subject_alternative_names = [
    "*.${var.DOMAIN_NAME}"
  ]

  validation_method = "DNS"
 
  tags = {
    Environment = "Production"
    Website = var.DOMAIN_NAME
  }
}