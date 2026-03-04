# Taula DynamoDB per emmagatzemar els missatges del formulari de contacte
resource "aws_dynamodb_table" "contact_messages" {
  name         = "contact_messages"
  billing_mode = "PAY_PER_REQUEST" # Mode on-demand: pagues per petició, ideal per a tràfic baix

  # Clau primària: l'identificador únic de cada missatge (timestamp)
  hash_key = "id"

  attribute {
    name = "id"
    type = "S" # "S" = String
  }

  tags = {
    Name    = "${var.project_name}-dynamodb"
    Project = var.project_name
  }
}
