output "api_gateway_endpoint" {
  description = "URL de l'API Gateway per al formulari. Posa-la a app.js!"
  value       = "${aws_api_gateway_stage.prod.invoke_url}/contact"
}
