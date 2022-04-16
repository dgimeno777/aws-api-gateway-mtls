data "aws_s3_bucket" "mtls" {
  bucket = var.mtls_s3_bucket_name
}

resource "aws_s3_object" "mtls_ca_truststore" {
  bucket = data.aws_s3_bucket.mtls.bucket
  key    = "aws-api-gateway-mtls/ca_cert.pem"
  source = var.truststore_local_filepath
}

locals {
  mtls_ca_truststore_uri = "s3://${aws_s3_object.mtls_ca_truststore.bucket}/${aws_s3_object.mtls_ca_truststore.key}"
}
