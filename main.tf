terraform {
  required_version = ">= 1.6.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.100"
    }
  }
}

provider "aws" {
  region = var.region
}

module "vpc" {
  source         = "./modules/vpc"
  name           = var.project_name
  cidr_block     = "10.0.0.0/16"
  az_count       = 2
  create_private = false # minimize costs: public subnets only
}

module "ecr" {
  source               = "./modules/ecr"
  repository_name      = "${var.project_name}-django"
  image_tag_mutability = "MUTABLE"
  scan_on_push         = true
}

module "eks" {
  source            = "./modules/eks"
  cluster_name      = "${var.project_name}-eks"
  vpc_id            = module.vpc.vpc_id
  public_subnet_ids = module.vpc.public_subnet_ids
  region            = var.region
  desired_size      = 2
  min_size          = 2
  max_size          = 3
  instance_types    = ["t3.small"]
}

output "ecr_repository_url" {
  value = module.ecr.repository_url
}

output "cluster_name" {
  value = module.eks.cluster_name
}
