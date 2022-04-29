module "mtls_gateway" {
  source                                         = "../mtls_gateway"
  ownership_verification_certificate_domain_name = var.mtls_gateway.ownership_verification_certificate_domain_name
  hosted_zone_id                                 = var.mtls_gateway.hosted_zone_id
  mtls_domain_name                               = var.mtls_gateway.mtls_domain_name
  truststore_local_filepath                      = var.mtls_gateway.truststore_local_filepath
  waf_whitelisted_ipv4_cidr_blocks               = var.mtls_gateway.waf_whitelisted_ipv4_cidr_blocks
  waf_whitelisted_country_codes                  = var.mtls_gateway.waf_whitelisted_country_codes
  mtls_authorizer_image                          = var.mtls_gateway.mtls_authorizer_image
  mtls_s3_bucket_name                            = var.mtls_gateway.mtls_s3_bucket_name
  internal_nlb_arn                               = aws_lb.mtls_gateway.arn
}

resource "aws_lb" "mtls_gateway" {
  name                       = "${local.resource_name_prefix}-mtls-gateway-${local.resource_name_suffix}"
  internal                   = true
  load_balancer_type         = "network"
  enable_deletion_protection = false
  subnets = [
    data.aws_subnet.web.id
  ]
}

resource "aws_lb_target_group" "mtls_gateway" {
  name        = "${local.resource_name_prefix}-mtls-gateway-${local.resource_name_suffix}"
  port        = 3000
  protocol    = "TCP"
  target_type = "ip"
  vpc_id      = data.aws_vpc.web.id
}

resource "aws_lb_listener" "mtls_gateway" {
  load_balancer_arn = aws_lb.mtls_gateway.arn
  port              = 80
  protocol          = "TCP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.mtls_gateway.arn
  }
}
