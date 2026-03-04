provider "aws" {
  region = "us-east-1"
}

# Declaració de providers necessaris
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
    archive = {
      source  = "hashicorp/archive"
      version = "~> 2.0"
    }
  }
}

# ==========================================
# DYNAMODB TABLE
# ==========================================
resource "aws_dynamodb_table" "contact_messages" {
  name         = "contact_messages"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "id"

  attribute {
    name = "id"
    type = "S"
  }

  tags = {
    Name    = "jostherOzuna-repte2-dynamodb"
    Project = "jostherOzuna-repte2"
  }
}

# ==========================================
# LAMBDA FUNCTION
# ==========================================
data "archive_file" "lambda_zip" {
  type        = "zip"
  source_file = "${path.module}/../lambda/contact_handler.js"
  output_path = "${path.module}/lambda_function.zip"
}

data "aws_caller_identity" "current" {}

resource "aws_lambda_function" "contact_handler" {
  function_name    = "jostherOzuna-repte2-contact-handler"
  filename         = data.archive_file.lambda_zip.output_path
  source_code_hash = data.archive_file.lambda_zip.output_base64sha256
  
  # Runtime NodeJS
  runtime = "nodejs20.x"
  handler = "contact_handler.handler"

  # Rol IAM d'AWS Academy
  role = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/LabRole"

  environment {
    variables = {
      TABLE_NAME = aws_dynamodb_table.contact_messages.name
    }
  }

  timeout = 10

  tags = {
    Project = "jostherOzuna-repte2"
  }
}

# ==========================================
# API GATEWAY
# ==========================================
resource "aws_api_gateway_rest_api" "contact_api" {
  name        = "jostherOzuna-repte2-api"
  description = "API de contacte per al Repte 2"
}

resource "aws_api_gateway_resource" "contact_resource" {
  rest_api_id = aws_api_gateway_rest_api.contact_api.id
  parent_id   = aws_api_gateway_rest_api.contact_api.root_resource_id
  path_part   = "contact"
}

resource "aws_api_gateway_method" "post_method" {
  rest_api_id   = aws_api_gateway_rest_api.contact_api.id
  resource_id   = aws_api_gateway_resource.contact_resource.id
  http_method   = "POST"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "lambda_integration" {
  rest_api_id             = aws_api_gateway_rest_api.contact_api.id
  resource_id             = aws_api_gateway_resource.contact_resource.id
  http_method             = aws_api_gateway_method.post_method.http_method
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = aws_lambda_function.contact_handler.invoke_arn
}

resource "aws_lambda_permission" "allow_api_gw" {
  statement_id  = "AllowAPIGatewayInvoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.contact_handler.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_rest_api.contact_api.execution_arn}/*/*"
}

resource "aws_api_gateway_deployment" "api_deployment" {
  rest_api_id = aws_api_gateway_rest_api.contact_api.id

  triggers = {
    redeployment = sha1(jsonencode([
      aws_api_gateway_resource.contact_resource.id,
      aws_api_gateway_method.post_method.id,
      aws_api_gateway_integration.lambda_integration.id,
    ]))
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_api_gateway_stage" "prod" {
  deployment_id = aws_api_gateway_deployment.api_deployment.id
  rest_api_id   = aws_api_gateway_rest_api.contact_api.id
  stage_name    = "prod"
}

# ==========================================
# OUTPUTS
# ==========================================
output "api_gateway_endpoint" {
  description = "URL de l'API Gateway"
  value       = "${aws_api_gateway_stage.prod.invoke_url}/contact"
}
