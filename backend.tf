terraform {
  backend "s3" {
    bucket         = "clp-tfstate-938094936571-dev"
    key            = "lesson-5/terraform.tfstate"
    region         = "us-west-2"
    dynamodb_table = "terraform-locks"
    encrypt        = true
  }
}
