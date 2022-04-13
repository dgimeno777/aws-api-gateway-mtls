resource "aws_api_gateway_rest_api" "mtls" {
  name                         = "mtls-${local.resource_name_suffix}"
  disable_execute_api_endpoint = true

  endpoint_configuration {
    types = ["REGIONAL"]
  }

  body = jsonencode({
    openapi = "3.0.1"
    info = {
      title   = "AGWMTLS"
      version = "1.0"
    }
    paths = {
      "/path1" = {
        get = {
          x-amazon-apigateway-integration = {
            httpMethod           = "GET"
            payloadFormatVersion = "1.0"
            type                 = "HTTP_PROXY"
            uri                  = "https://ip-ranges.amazonaws.com/ip-ranges.json"
          }
        }
      }
    }
  })
}

resource "aws_api_gateway_deployment" "mtls" {
  rest_api_id = aws_api_gateway_rest_api.mtls.id

  triggers = {
    redeployment = sha1(jsonencode(aws_api_gateway_rest_api.mtls.body))
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
  name                   = "mtls-${local.resource_name_suffix}"
  type                   = "REQUEST"
  rest_api_id            = aws_api_gateway_rest_api.mtls.id
  authorizer_uri         = aws_lambda_function.mtls_authorizer.invoke_arn
  authorizer_credentials = aws_iam_role.mtls_authorizer.arn
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

resource "aws_route53_record" "example" {
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
