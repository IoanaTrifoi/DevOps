variable "bucket_name" {
  type        = string
  description = "S3 bucket for Terraform state"
}

variable "table_name" {
  type        = string
  description = "DynamoDB table name for state locking"
  default     = "terraform-locks"
}

variable "force_destroy" {
  type        = bool
  description = "Allow force destroy of S3 bucket"
  default     = false
}
