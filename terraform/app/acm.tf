data "aws_acm_certificate" "mtls" {
  domain = "api.mtls-example.com"
}
