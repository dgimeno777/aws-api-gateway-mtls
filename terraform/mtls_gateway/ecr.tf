data "aws_ecr_repository" "mtls_authorizer" {
  name = var.mtls_authorizer_image.ecr_repo_name
}

data "aws_ecr_image" "mtls_authorizer" {
  repository_name = data.aws_ecr_repository.mtls_authorizer.name
  image_tag       = var.mtls_authorizer_image.image_identifier_type == "TAG" ? var.mtls_authorizer_image.image_identifier : null
  image_digest    = var.mtls_authorizer_image.image_identifier_type == "SHA" ? var.mtls_authorizer_image.image_identifier : null
}

locals {
  mtls_authorizer_image_uri = "${data.aws_ecr_repository.mtls_authorizer.repository_url}@${data.aws_ecr_image.mtls_authorizer.id}"
}
