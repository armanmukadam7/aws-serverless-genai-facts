resource "aws_apigatewayv2_api" "funfacts" {
  name          = "FunfactsAPI"
  protocol_type = "HTTP"

  cors_configuration {

    allow_origins = [
      # "https://${var.amplify_domain_name}",
      "https://${aws_amplify_app.frontend.default_domain}"
    ]

    allow_methods = [
      "GET",
      "OPTIONS",
    ]

    allow_headers = [
      "Content-Type",
      "Authorization",
      "X-Amz-Date",
      "X-Api-Key",
      "X-Amz-Security-Token"
    ]

    max_age = 3600
  }

  tags = {
    Project = var.project_name
  }
}
# The $default stage exposes API routes without adding a stage prefix
# such as /prod. With auto_deploy enabled, route and integration changes
# are deployed automatically.
#With the $default stage, the URL is:https://v5zrxervgl.execute-api.us-east-1.amazonaws.com/funfact
resource "aws_apigatewayv2_stage" "default" {
  api_id = aws_apigatewayv2_api.funfacts.id
  # If you used a named stage:the url will be:https://v5zrxervgl.execute-api.us-east-1.amazonaws.com/prod/funfact
  name        = "$default"
  auto_deploy = true

  tags = {
    Project = var.project_name
  }
}

resource "aws_apigatewayv2_integration" "lambda" {
  api_id                 = aws_apigatewayv2_api.funfacts.id
  integration_type       = "AWS_PROXY"
  integration_uri        = aws_lambda_function.cloud_fun_facts.invoke_arn
  payload_format_version = "2.0"
}

resource "aws_apigatewayv2_route" "funfact" {
  api_id    = aws_apigatewayv2_api.funfacts.id
  route_key = "GET /funfact"
  target    = "integrations/${aws_apigatewayv2_integration.lambda.id}"
}

resource "aws_lambda_permission" "api_gateway" {
  statement_id  = "AllowAPIGatewayInvoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.cloud_fun_facts.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_apigatewayv2_api.funfacts.execution_arn}/*/*"
}
