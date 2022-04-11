resource "aws_api_gateway_rest_api" "mtls" {
  name = "mtls-${local.resource_name_suffix}"
}

resource "aws_api_gateway_authorizer" "mtls" {
  name                   = "mtls-${local.resource_name_suffix}"
  rest_api_id            = aws_api_gateway_rest_api.mtls.id
  authorizer_uri         = aws_lambda_function.mtls_authorizer.invoke_arn
  authorizer_credentials = aws_iam_role.mtls_authorizer.arn
}
