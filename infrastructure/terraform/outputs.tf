output "lambda_function_name" {
  description = "Name of the deployed Lambda function"
  value       = aws_lambda_function.cloud_fun_facts.function_name
}

output "dynamodb_table_name" {
  description = "Name of the DynamoDB table"
  value       = aws_dynamodb_table.cloud_facts.name
}

output "api_url" {
  description = "Complete invocation URL for the funfact API route"
  value       = "${trimsuffix(aws_apigatewayv2_stage.default.invoke_url, "/")}/funfact"
}

output "frontend_url" {
  value = "https://${aws_amplify_app.frontend.default_domain}"
}

output "frontend_custom_url" {
  value = var.amplify_domain_name != "" ? "https://${var.amplify_domain_name}" : null
}
