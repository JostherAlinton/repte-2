variable "aws_region" {
  description = "Región de AWS a usar"
  default     = "us-east-1"
}

variable "project_name" {
  description = "Nom del projecte (s'utilitza per etiquetar recursos)"
  default     = "portfolio-repte2"
}

# Nom del teu repositori GitHub en format "usuari/repositori"
variable "github_repo" {
  description = "Repositori GitHub connectat a Amplify (format: user/repo)"
  default     = "josther-ozuna/portfolio-repte2"
}

# Token OAuth de GitHub (necessari per connectar Amplify)
variable "github_token" {
  description = "Personal Access Token de GitHub per a Amplify"
  type        = string
  sensitive   = true
}
