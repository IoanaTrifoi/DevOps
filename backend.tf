terraform {
  backend "s3" {
    bucket       = "clp-tfstate-938094936571-dev"
    key          = "terraform.tfstate"
    region       = "us-west-2"
    encrypt      = true
    use_lockfile = true
  }
}
