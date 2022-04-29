output "api_gateway_id" {
  value = aws_api_gateway_rest_api.mtls.id
}

output "domain_name" {
  value = aws_api_gateway_domain_name.mtls.domain_name
}
