#output "s3_bucket_name" {
#    description = "S3 bucket name for state files"
#    value       = aws_s3_bucket.terraform_state.bucket
#}
#
#output "s3_bucket_url" {
#  description = "S3 bucket URL for state files"
#  value       = "https://${aws_s3_bucket.terraform_state.bucket_regional_domain_name}"
#}
#
#output "dynamodb_table_name" {
#  description = "DynamoDB table name for state locking"
#  value       = aws_dynamodb_table.terraform_locks.name
#}