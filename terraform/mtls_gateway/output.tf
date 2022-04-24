output "api_gateway_id" {
  value = aws_api_gateway_rest_api.mtls.id
}

output "api_gateway_url" {
  value = aws_api_gateway_stage.mtls.invoke_url
}

output "domain_name" {
  value = aws_api_gateway_domain_name.mtls.domain_name
}

output "proxy_resource_id" {
  value = aws_api_gateway_resource.mtls_proxy.id
}

output "proxy_method" {
  value = aws_api_gateway_method.mtls_proxy.http_method
}
