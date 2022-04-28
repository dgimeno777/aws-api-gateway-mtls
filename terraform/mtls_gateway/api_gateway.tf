resource "aws_api_gateway_rest_api" "mtls" {
  name                         = "mtls-${local.resource_name_suffix}"
  disable_execute_api_endpoint = true

  endpoint_configuration {
    types = ["REGIONAL"]
  }
}

resource "aws_api_gateway_deployment" "mtls" {
  depends_on = [
    aws_api_gateway_integration.mtls_root_path,
    aws_api_gateway_integration.mtls_proxy
  ]
  rest_api_id = aws_api_gateway_rest_api.mtls.id

  triggers = {
    redeployment = sha1(jsonencode(aws_api_gateway_rest_api.mtls.body))
  }

  variables = {
    resources = join(", ", [aws_api_gateway_resource.mtls_proxy.id])
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_api_gateway_stage" "mtls" {
  deployment_id         = aws_api_gateway_deployment.mtls.id
  rest_api_id           = aws_api_gateway_rest_api.mtls.id
  stage_name            = "mtls-${local.resource_name_suffix}"
  cache_cluster_enabled = false
}

resource "aws_api_gateway_authorizer" "mtls" {
  name                             = "mtls-${local.resource_name_suffix}"
  type                             = "REQUEST"
  rest_api_id                      = aws_api_gateway_rest_api.mtls.id
  authorizer_uri                   = aws_lambda_function.mtls_authorizer.invoke_arn
  authorizer_credentials           = aws_iam_role.mtls_authorizer.arn
  authorizer_result_ttl_in_seconds = 15
  identity_source                  = "context.identity.clientCert.clientCertPem"
}

resource "aws_api_gateway_domain_name" "mtls" {
  depends_on               = [aws_s3_object.mtls_ca_truststore]
  domain_name              = var.mtls_domain_name
  security_policy          = "TLS_1_2"
  regional_certificate_arn = data.aws_acm_certificate.ownership_verification.arn

  endpoint_configuration {
    types = ["REGIONAL"]
  }

  mutual_tls_authentication {
    truststore_uri = local.mtls_ca_truststore_uri
  }
}

resource "aws_route53_record" "mtls" {
  name    = aws_api_gateway_domain_name.mtls.domain_name
  type    = "A"
  zone_id = data.aws_route53_zone.mtls.id

  alias {
    evaluate_target_health = true
    name                   = aws_api_gateway_domain_name.mtls.regional_domain_name
    zone_id                = aws_api_gateway_domain_name.mtls.regional_zone_id
  }
}

resource "aws_api_gateway_base_path_mapping" "mtls" {
  api_id      = aws_api_gateway_rest_api.mtls.id
  stage_name  = aws_api_gateway_stage.mtls.stage_name
  domain_name = aws_api_gateway_domain_name.mtls.domain_name
}

resource "aws_api_gateway_vpc_link" "mtls" {
  name = "mtls-${local.resource_name_suffix}"
  target_arns = [
    data.aws_lb.mtls.arn
  ]
}

data "aws_lb" "mtls" {
  arn = var.nlb_arn
}

resource "aws_api_gateway_method" "mtls_root_path" {
  rest_api_id   = aws_api_gateway_rest_api.mtls.id
  resource_id   = aws_api_gateway_rest_api.mtls.root_resource_id
  http_method   = "ANY"
  authorization = "CUSTOM"
  authorizer_id = aws_api_gateway_authorizer.mtls.id
}

resource "aws_api_gateway_integration" "mtls_root_path" {
  rest_api_id             = aws_api_gateway_rest_api.mtls.id
  resource_id             = aws_api_gateway_rest_api.mtls.root_resource_id
  http_method             = aws_api_gateway_method.mtls_root_path.http_method
  type                    = "HTTP_PROXY"
  connection_type         = "VPC_LINK"
  connection_id           = aws_api_gateway_vpc_link.mtls.id
  integration_http_method = "ANY"
  uri                     = "http://${data.aws_lb.mtls.dns_name}/"
}

resource "aws_api_gateway_resource" "mtls_proxy" {
  parent_id   = aws_api_gateway_rest_api.mtls.root_resource_id
  rest_api_id = aws_api_gateway_rest_api.mtls.id
  path_part   = "{proxy+}"
}

resource "aws_api_gateway_method" "mtls_proxy" {
  rest_api_id   = aws_api_gateway_rest_api.mtls.id
  resource_id   = aws_api_gateway_resource.mtls_proxy.id
  http_method   = "ANY"
  authorization = "CUSTOM"
  authorizer_id = aws_api_gateway_authorizer.mtls.id
  request_parameters = {
    "method.request.path.proxy" = true
  }
}

resource "aws_api_gateway_integration" "mtls_proxy" {
  rest_api_id             = aws_api_gateway_rest_api.mtls.id
  resource_id             = aws_api_gateway_resource.mtls_proxy.id
  http_method             = aws_api_gateway_method.mtls_proxy.http_method
  type                    = "HTTP_PROXY"
  connection_type         = "VPC_LINK"
  connection_id           = aws_api_gateway_vpc_link.mtls.id
  integration_http_method = "ANY"
  uri                     = "http://${data.aws_lb.mtls.dns_name}/{proxy}"
  cache_key_parameters = [
    "method.request.path.proxy",
  ]
  request_parameters = {
    "integration.request.path.proxy" = "method.request.path.proxy"
  }
}
