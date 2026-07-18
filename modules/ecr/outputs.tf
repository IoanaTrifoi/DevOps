output "repository_url" {
  description = "ECR repository URL"
  value       = aws_ecr_repository.ecr.repository_url
}

output "repository_arn" {
  description = "ECR repository ARN"
  value       = aws_ecr_repository.ecr.arn
}

output "registry_id" {
  description = "ECR registry ID"
  value       = aws_ecr_repository.ecr.registry_id
}
