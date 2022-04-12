resource "aws_ecr_repository" "mtls_authorizer" {
  name = "api-gateway-mtls/mtls-authorizer"
  image_tag_mutability = "MUTABLE"
  image_scanning_configuration {
    scan_on_push = true
  }
  encryption_configuration {
    encryption_type = "KMS"
  }
}
