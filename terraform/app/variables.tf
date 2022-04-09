locals {
  resource_name_suffix = terraform.workspace
}

variable "mtls_authorizer_image" {
  description = "MTLS Authorizer Docker Image info"
  type = object({
    ecr_repo_name = string,
    image_identifier_type = string,
    image_identifier = string,
  })
}
