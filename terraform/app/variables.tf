locals {
  resource_name_suffix = terraform.workspace
}

variable "aws_profile" {
  type    = string
  default = "aws_api_gateway_mtls"
}

variable "aws_region" {
  type    = string
  default = "us-east-1"
}

variable "mtls_authorizer_image" {
  type = object({
    ecr_repo_name         = string,
    image_identifier_type = string,
    image_identifier      = string,
  })
  description = "MTLS Authorizer Docker Image info"
}

variable "mtls_s3_bucket_name" {
  type        = string
  description = "MTLS S3 Bucket name"
}

variable "mtls_domain_acm_certificate_id" {
  type        = string
  description = "ID of the ACM Certificate for the MTLS API Gateway Domain"
}
