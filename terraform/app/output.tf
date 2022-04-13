output "api_gateway_url" {
  value = aws_api_gateway_stage.mtls.invoke_url
}

output "domain_name" {
  value = aws_api_gateway_domain_name.mtls.domain_name
}
