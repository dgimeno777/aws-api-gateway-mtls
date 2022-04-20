resource "aws_ecr_repository" "mtls_authorizer" {
  name = "api-gateway-mtls/mtls-authorizer-${local.resource_name_suffix}"
  image_tag_mutability = "MUTABLE"
  image_scanning_configuration {
    scan_on_push = true
  }
  encryption_configuration {
    encryption_type = "KMS"
  }
}

resource "aws_ecr_repository" "web" {
  name = "api-gateway-mtls/web-${local.resource_name_suffix}"
  image_tag_mutability = "MUTABLE"
  image_scanning_configuration {
    scan_on_push = true
  }
  encryption_configuration {
    encryption_type = "KMS"
  }
}

resource "aws_ecr_repository" "web_prod" {
  name = "api-gateway-mtls/web-prod-${local.resource_name_suffix}"
  image_tag_mutability = "MUTABLE"
  image_scanning_configuration {
    scan_on_push = true
  }
  encryption_configuration {
    encryption_type = "KMS"
  }
}
