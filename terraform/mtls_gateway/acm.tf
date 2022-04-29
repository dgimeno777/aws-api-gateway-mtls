data "aws_acm_certificate" "mtls" {
  domain = var.mtls_domain_name
  types  = ["IMPORTED"]
}

data "aws_acm_certificate" "ownership_verification" {
  domain = var.ownership_verification_certificate_domain_name
  types  = ["AMAZON_ISSUED"]
}
