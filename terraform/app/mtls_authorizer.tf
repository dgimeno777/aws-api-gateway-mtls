data "aws_ecr_repository" "" {
  name = ""
}

data "aws_ecr_image" "" {
  repository_name = data.aws_ecr_repository.
}

resource "aws_iam_role" "mtls_authorizer" {
  name = "mtls-authorizer-${local.resource_name_suffix}"
  assume_role_policy = jsonencode({
    Version: "2012-10-17",
    Statement: [
      {
        Action: "sts:AssumeRole",
        Principal: {
          Service: "apigateway.amazonaws.com"
        },
        Effect: "Allow",
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
    Version: "2012-10-17",
    Statement: [
      {
        Action: "lambda:InvokeFunction",
        Effect: "Allow",
        Resource: aws_lambda_function.mtls_authorizer.arn
      }
    ]
  })
}

resource "aws_lambda_function" "mtls_authorizer" {
  function_name = "mtls-authorizer-${local.resource_name_suffix}"
  role          = aws_iam_role.mtls_authorizer.arn
  image_uri = ""
  memory_size = 512
}