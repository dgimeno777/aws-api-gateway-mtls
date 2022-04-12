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
