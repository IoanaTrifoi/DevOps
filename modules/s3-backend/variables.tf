variable "region" {
  type        = string
  description = "AWS region"
}

variable "bucket_name" {
  type        = string
  description = "Unique S3 bucket name for TF state"
}

variable "dynamodb_table" {
  type        = string
  description = "DynamoDB table name for TF locks"
}
