data "aws_ecr_repository" "mtls_authorizer" {
  name = var.mtls_authorizer_image.ecr_repo_name
}

data "aws_ecr_image" "mtls_authorizer" {
  repository_name = data.aws_ecr_repository.mtls_authorizer
  image_tag       = var.mtls_authorizer_image.image_identifier_type == "TAG" ? var.mtls_authorizer_image.image_identifier : null
  image_digest    = var.mtls_authorizer_image.image_identifier_type == "SHA" ? var.mtls_authorizer_image.image_identifier : null
}

locals {
  mtls_authorizer_image_uri = "${data.aws_ecr_repository.mtls_authorizer.repository_url}@${data.aws_ecr_image.mtls_authorizer.id}"
}

resource "aws_iam_role" "mtls_authorizer" {
  name = "mtls-authorizer-${local.resource_name_suffix}"
  assume_role_policy = jsonencode({
    Version : "2012-10-17",
    Statement : [
      {
        Action : "sts:AssumeRole",
        Principal : {
          Service : "apigateway.amazonaws.com"
        },
        Effect : "Allow",
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "mtls_authorizer" {
  policy_arn = aws_iam_policy.mtls_authorizer.arn
  role       = aws_iam_role.mtls_authorizer.arn
}

resource "aws_iam_policy" "mtls_authorizer" {
  name = "mtls-authorizer-${local.resource_name_suffix}"
  policy = jsonencode({
    Version : "2012-10-17",
    Statement : [
      {
        Action : "lambda:InvokeFunction",
        Effect : "Allow",
        Resource : aws_lambda_function.mtls_authorizer.arn
      }
    ]
  })
}

resource "aws_lambda_function" "mtls_authorizer" {
  function_name = "mtls-authorizer-${local.resource_name_suffix}"
  role          = aws_iam_role.mtls_authorizer.arn
  image_uri     = local.mtls_authorizer_image_uri
  memory_size   = 512
}
