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
}

resource "aws_api_gateway_integration" "mtls_gateway" {
  rest_api_id             = module.mtls_gateway.api_gateway_id
  resource_id             = module.mtls_gateway.proxy_resource_id
  http_method             = module.mtls_gateway.proxy_method
  type                    = "HTTP_PROXY"
  connection_type         = "VPC_LINK"
  connection_id           = aws_api_gateway_vpc_link.mtls_gateway.id
  integration_http_method = "ANY"
  uri                     = "http://${aws_lb.mtls_gateway.dns_name}"
}

resource "aws_api_gateway_vpc_link" "mtls_gateway" {
  name = "${local.resource_name_prefix}-mtls-gateway-${local.resource_name_suffix}"
  target_arns = [
    aws_lb.mtls_gateway.arn
  ]
}

resource "aws_lb" "mtls_gateway" {
  name               = "${local.resource_name_prefix}-mtls-gateway-${local.resource_name_suffix}"
  internal           = true
  load_balancer_type = "network"
  subnet_mapping {
    subnet_id = data.aws_subnet.web.id
  }
}

resource "aws_lb_target_group" "mtls_gateway" {
  name        = "${local.resource_name_prefix}-${local.resource_name_suffix}"
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
