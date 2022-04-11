locals {
  resource_name_suffix = terraform.workspace
}

variable "aws_profile" {
  default = "aws_api_gateway_mtls"
}

variable "aws_region" {
  default = "us-east-1"
}

variable "mtls_authorizer_image" {
  description = "MTLS Authorizer Docker Image info"
  type = object({
    ecr_repo_name         = string,
    image_identifier_type = string,
    image_identifier      = string,
  })
}
