locals {
  resource_name_suffix = terraform.workspace
}

variable "aws_profile" {
  default = "aws_api_gateway_mtls"
}

variable "aws_region" {
  default = "us-east-1"
}
