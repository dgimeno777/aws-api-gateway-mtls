data "aws_ecr_repository" "web" {
  name = var.web_image.ecr_repo_name
}

data "aws_ecr_image" "web" {
  repository_name = data.aws_ecr_repository.web.name
  image_tag       = var.web_image.image_identifier_type == "TAG" ? var.web_image.image_identifier : null
  image_digest    = var.web_image.image_identifier_type == "SHA" ? var.web_image.image_identifier : null
}

locals {
  web_image_uri = "${data.aws_ecr_repository.web.repository_url}@${data.aws_ecr_image.web.id}"
}
