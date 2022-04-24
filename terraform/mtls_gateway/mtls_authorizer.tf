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
  role       = aws_iam_role.mtls_authorizer.name
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

resource "aws_iam_role" "mtls_authorizer_lambda" {
  name = "mtls-authorizer-lambda-${local.resource_name_suffix}"
  assume_role_policy = jsonencode({
    Version : "2012-10-17",
    Statement : [
      {
        Action : "sts:AssumeRole",
        Principal : {
          Service : "lambda.amazonaws.com"
        },
        Effect : "Allow",
      }
    ]
  })
}

resource "aws_iam_policy" "mtls_authorizer_lambda" {
  name = "mtls-authorizer-lambda-${local.resource_name_suffix}"
  policy = jsonencode({
    Version : "2012-10-17",
    Statement : [
      {
        "Action" : [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ],
        "Resource" : "arn:aws:logs:*:*:*",
        "Effect" : "Allow"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "mtls_authorizer_lambda" {
  policy_arn = aws_iam_policy.mtls_authorizer_lambda.arn
  role       = aws_iam_role.mtls_authorizer_lambda.name
}

resource "aws_lambda_function" "mtls_authorizer" {
  depends_on    = [aws_cloudwatch_log_group.mtls_authorizer]
  function_name = "mtls-authorizer-${local.resource_name_suffix}"
  role          = aws_iam_role.mtls_authorizer_lambda.arn
  image_uri     = local.mtls_authorizer_image_uri
  package_type  = "Image"
  memory_size   = 512
  architectures = ["x86_64"]

  image_config {
    working_directory = "/src"
    command           = ["mtls_authorizer.lambda_handler.lambda_handler"]
  }
}

resource "aws_cloudwatch_log_group" "mtls_authorizer" {
  name = "/aws/lambda/mtls-authorizer-${local.resource_name_suffix}"
}
