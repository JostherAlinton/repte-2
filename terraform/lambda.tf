# Empaquetem el codi de la Lambda en un fitxer ZIP perquè Terraform el pugui pujar
data "archive_file" "lambda_zip" {
  type        = "zip"
  source_file = "${path.module}/../lambda/contact_handler.js"
  output_path = "${path.module}/lambda_function.zip"
}

# Funció Lambda
resource "aws_lambda_function" "contact_handler" {
  function_name    = "${var.project_name}-contact-handler"
  filename         = data.archive_file.lambda_zip.output_path
  source_code_hash = data.archive_file.lambda_zip.output_base64sha256

  # Runtime triat: Node.js 20.x
  # MOTIU: fàcil d'aprendre, ràpida (cold start baix), sintaxi async/await clara
  runtime = "nodejs20.x"
  handler = "contact_handler.handler"

  # Rol IAM: a AWS Academy usem el LabRole existent
  role = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/LabRole"

  # Variables d'entorn: el nom de la taula DynamoDB
  environment {
    variables = {
      TABLE_NAME = aws_dynamodb_table.contact_messages.name
    }
  }

  # Timeout de 10 seg és més que suficient per a una operació de DynamoDB senzilla
  timeout = 10

  tags = {
    Project = var.project_name
  }
}

# Obtenim l'account ID actual (necessari per construir el ARN del LabRole)
data "aws_caller_identity" "current" {}
