variable "aws_region" {
  type        = string
  description = "AWS region"
  default     = "us-west-2"
}

# State bucket name (globally unique across S3).
variable "tf_state_bucket_name" {
  type        = string
  description = "S3 bucket name for Terraform state"
  # Use a unique name that includes your Account ID:
  default = "clp-tfstate-938094936571-dev"
}
