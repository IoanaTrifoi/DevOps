# Uncomment to connect the backend to Terraform

# terraform {
#   backend "s3" {
#     bucket         = "clp-tfstate-938094936571-dev"               # S3 bucket name
#     key            = "lesson-8-9/terraform.tfstate"               # Path to the state file
#     region         = "us-west-2"                                  # AWS region
#     dynamodb_table = "terraform-locks"                            # DynamoDB table name
#     encrypt        = true                                         # Encrypt the state file
#   }
# }
