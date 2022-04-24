terraform {
  backend "s3" {
    # Variables not allowed so hardcode
    key     = "aws-api-gateway-mtls/setup/terraform.tfstate"
    region  = "us-east-1"
    profile = "aws_api_gateway_mtls"
  }
}

provider "aws" {
  region  = var.aws_region
  profile = var.aws_profile
}
