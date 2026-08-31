resource "aws_amplify_app" "frontend" {
  name         = var.amplify_app_name
  repository   = var.amplify_repository_url
  access_token = var.amplify_oauth_token
  platform     = "WEB"

  build_spec = <<-EOT
    version: 1
    frontend:
      phases:
        preBuild:
          commands:
            - echo "Static HTML site"
      artifacts:
        baseDirectory: frontend
        files:
          - "**/*"
      cache:
        paths: []
  EOT

  custom_rule {
    source = "/<*>"
    status = "404-200"
    target = "/index.html"
  }

  tags = {
    Project = var.project_name
  }
}

resource "aws_amplify_branch" "main" {
  app_id      = aws_amplify_app.frontend.id
  branch_name = var.amplify_branch_name
  stage       = "PRODUCTION"

  tags = {
    Project = var.project_name
  }
}

resource "aws_amplify_domain_association" "frontend" {
  count = var.amplify_domain_name != "" ? 1 : 0

  app_id      = aws_amplify_app.frontend.id
  domain_name = var.amplify_domain_name

  sub_domain {
    branch_name = aws_amplify_branch.main.branch_name
    prefix      = var.amplify_subdomain_prefix
  }
}
