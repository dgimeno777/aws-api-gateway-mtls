resource "aws_wafv2_web_acl_association" "mtls" {
  resource_arn = aws_api_gateway_stage.mtls.arn
  web_acl_arn  = aws_wafv2_web_acl.mtls.arn
}

resource "aws_wafv2_web_acl" "mtls" {
  name  = "mtls-${local.resource_name_suffix}"
  scope = "REGIONAL"
  visibility_config {
    metric_name                = "AgwMtls"
    cloudwatch_metrics_enabled = false
    sampled_requests_enabled   = false
  }
  default_action {
    block {}
  }
  rule {
    name     = "rule-100"
    priority = 100
    action {
      allow {}
    }
    statement {
      and_statement {
        statement {
          ip_set_reference_statement {
            arn = aws_wafv2_ip_set.mtls.arn
          }
        }
        statement {
          geo_match_statement {
            country_codes = var.waf_whitelisted_country_codes
          }
        }
      }
    }
    visibility_config {
      metric_name                = "AgwMtlsIPSet"
      cloudwatch_metrics_enabled = false
      sampled_requests_enabled   = false
    }
  }
}

resource "aws_wafv2_ip_set" "mtls" {
  name               = "mtls-${local.resource_name_suffix}"
  scope              = "REGIONAL"
  ip_address_version = "IPV4"
  addresses          = var.waf_whitelisted_ipv4_cidr_blocks
}
