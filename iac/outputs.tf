output "api_endpoint" {
  description = "La URL publica del API Gateway para enviar el POST de la imagen"
  value       = "${aws_apigatewayv2_api.http_api.api_endpoint}/upload"
}

output "s3_bucket_name" {
  description = "El nombre del bucket donde se guardan las imagenes"
  value       = aws_s3_bucket.image_bucket.bucket
}

output "sqs_queue_url" {
  description = "La URL de la cola principal"
  value       = aws_sqs_queue.main_queue.url
}
