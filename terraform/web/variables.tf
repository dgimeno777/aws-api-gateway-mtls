locals {
  resource_name_prefix = "mtls-web"
  resource_name_suffix = terraform.workspace
}

variable "aws_profile" {
  type        = string
  description = "AWS Profile"
  default     = "aws_api_gateway_mtls"
}

variable "aws_region" {
  type        = string
  description = "AWS Region"
  default     = "us-east-1"
}

variable "mtls_gateway" {
  type = object({
    mtls_domain_name                               = string
    ownership_verification_certificate_domain_name = string
    hosted_zone_id                                 = string
    waf_whitelisted_ipv4_cidr_blocks               = list(string)
    waf_whitelisted_country_codes                  = list(string)
    mtls_s3_bucket_name                            = string
    truststore_local_filepath                      = string
    mtls_authorizer_image = object({
      ecr_repo_name         = string
      image_identifier_type = string
      image_identifier      = string
    })
  })
  description = "MTLS Gateway info"
}

variable "web_image" {
  type = object({
    ecr_repo_name         = string
    image_identifier_type = string
    image_identifier      = string
  })
  description = "Web Image info"
}

variable "web_subnet_id" {
  type        = string
  description = "ID of the Subnet for the web service"
}
