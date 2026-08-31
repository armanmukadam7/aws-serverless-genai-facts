variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "us-east-1"
}

variable "project_name" {
  description = "Cloud Fun Fact Generator"
  type        = string
  default     = "cloud-fun-facts"
}

variable "lambda_timeout" {
  description = "Lambda timeout in seconds"
  type        = number
  default     = 30
}

variable "lambda_memory" {
  description = "Lambda memory in MB"
  type        = number
  default     = 256
}

variable "bedrock_model_id" {
  description = "Bedrock model or inference profile ID"
  type        = string

  # Course model:
  # anthropic.claude-3-5-sonnet-20240620-v1:0

  default = "anthropic.claude-3-5-sonnet-20240620-v1:0"
}

variable "amplify_app_name" {
  description = "Name of the Amplify app hosting the frontend"
  type        = string
  default     = "cloud-fun-facts-ui"
}

variable "amplify_repository_url" {
  description = "GitHub repository URL for the frontend app. Set locally with TF_VAR_amplify_repository_url to avoid committing secrets."
  type        = string
  default     = ""
}

variable "amplify_oauth_token" {
  description = "GitHub OAuth token used by Amplify. Set locally with TF_VAR_amplify_oauth_token and do not commit it."
  type        = string
  default     = ""
  sensitive   = true
}

variable "amplify_branch_name" {
  description = "Git branch that Amplify should deploy"
  type        = string
  default     = "main"
}

variable "amplify_domain_name" {
  description = "Custom domain name for the frontend app, e.g. example.com"
  type        = string
  default     = ""
}

variable "amplify_subdomain_prefix" {
  description = "Subdomain prefix for the custom domain, e.g. www"
  type        = string
  default     = "www"
}

