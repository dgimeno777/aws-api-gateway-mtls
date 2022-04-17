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

variable "mtls_domain_name" {
  type        = string
  description = "Name of the MTLS API Gateway Domain"
}

variable "ownership_verification_certificate_domain_name" {
  type        = string
  description = "Name of the Ownership Certificate Domain Name"
}

variable "hosted_zone_id" {
  type        = string
  description = "ID of Route53 Hosted Zone for the MTLS Custom Domain"
}

variable "truststore_local_filepath" {
  type        = string
  description = "Local filepath of the truststore"
}

variable "whitelisted_ipv4_cidr_blocks" {
  type        = list(string)
  description = "IPv4 CIDR Blocks to whitelist on the API Gateway"
}
