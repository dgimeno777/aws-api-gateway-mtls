resource "aws_api_gateway_rest_api" "mtls" {
  name = "mtls-${local.resource_name_suffix}"

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
  deployment_id = aws_api_gateway_deployment.mtls.id
  rest_api_id   = aws_api_gateway_rest_api.mtls.id
  stage_name    = "mtls-${local.resource_name_suffix}"
}

resource "aws_api_gateway_authorizer" "mtls" {
  name                   = "mtls-${local.resource_name_suffix}"
  type                   = "REQUEST"
  rest_api_id            = aws_api_gateway_rest_api.mtls.id
  authorizer_uri         = aws_lambda_function.mtls_authorizer.invoke_arn
  authorizer_credentials = aws_iam_role.mtls_authorizer.arn
}

resource "aws_api_gateway_domain_name" "mtls" {
  domain_name              = "api.mtls-example.com"
  security_policy          = "TLS_1_2"
  regional_certificate_arn = data.aws_acm_certificate.mtls.arn
  ownership_verification_certificate_arn = ""

  endpoint_configuration {
    types = ["REGIONAL"]
  }

  mutual_tls_authentication {
    truststore_uri = local.mtls_ca_truststore_uri
  }
}
