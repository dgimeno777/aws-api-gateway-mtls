data "aws_route53_zone" "mtls" {
  zone_id = var.hosted_zone_id
}
