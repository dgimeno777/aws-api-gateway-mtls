output "mtls_authorizer_ecr_uri" {
  value = aws_ecr_repository.mtls_authorizer.repository_url
}
