data "archive_file" "lambda_zip" {
  type        = "zip"
  source_file = "${path.module}/../../backend/lambda_function.py"
  output_path = "${path.module}/lambda.zip"
}

resource "aws_lambda_function" "cloud_fun_facts" {
  function_name = "CloudFunFacts"

  role = aws_iam_role.lambda_role.arn

  runtime = "python3.13"
  handler = "lambda_function.lambda_handler"

  filename         = data.archive_file.lambda_zip.output_path
  source_code_hash = data.archive_file.lambda_zip.output_base64sha256

  timeout     = var.lambda_timeout
  memory_size = var.lambda_memory

  environment {
    variables = {
      TABLE_NAME      = aws_dynamodb_table.cloud_facts.name
      BEDROCK_MODEL_ID = var.bedrock_model_id
    }
  }

  depends_on = [
    aws_iam_role_policy.lambda_logs,
    aws_iam_role_policy.lambda_dynamodb,
    aws_iam_role_policy.lambda_bedrock
  ]

  tags = {
    Project = var.project_name
  }
}