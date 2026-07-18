output "s3_bucket_name" {
  value       = module.s3_backend.bucket_name
  description = "Terraform state bucket name"
}

output "dynamodb_table_name" {
  value       = module.s3_backend.dynamodb_table_name
  description = "DynamoDB table for state locking"
}

output "vpc_id" {
  value       = module.vpc.vpc_id
  description = "VPC ID"
}

output "public_subnet_ids" {
  value       = module.vpc.public_subnet_ids
  description = "Public subnets"
}

output "private_subnet_ids" {
  value       = module.vpc.private_subnet_ids
  description = "Private subnets"
}

output "ecr_repository_url" {
  value       = module.ecr.repository_url
  description = "ECR repository URL"
}
