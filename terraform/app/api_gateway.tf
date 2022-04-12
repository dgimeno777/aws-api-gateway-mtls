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

resource "aws_wafregional_web_acl_association" "mtls" {
  resource_arn = aws_api_gateway_stage.mtls.arn
  web_acl_id   = aws_wafregional_web_acl.mtls.id
}

resource "aws_wafregional_web_acl" "mtls" {
  metric_name = "AGWMTLSIPSet"
  name        = "mtls-${local.resource_name_suffix}"

  default_action {
    type = "BLOCK"
  }

  rule {
    action {
      type = "ALLOW"
    }
    priority = 100
    rule_id  = aws_wafregional_rule.mtls.id
  }
}

resource "aws_wafregional_rule" "mtls" {
  metric_name = "AGWMTLSIPSet"
  name        = "mtls-ip-${local.resource_name_suffix}"

  predicate {
    data_id = aws_wafregional_ipset.mtls.id
    negated = false
    type    = "IPMatch"
  }
}

resource "aws_wafregional_ipset" "mtls" {
  name = "mtls-ipset-${local.resource_name_suffix}"

  ip_set_descriptor {
    type  = "IPV4"
    value = local.my_public_ip_cidr_block
  }
}
