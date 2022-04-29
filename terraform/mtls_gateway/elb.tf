data "aws_lb" "mtls" {
  arn = var.internal_nlb_arn
}
