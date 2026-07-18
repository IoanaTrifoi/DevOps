terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 4.0.0"
    }
    helm = {
      source  = "hashicorp/helm"
      version = ">= 2.0.0"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = ">= 2.0.0"
    }
  }
}

provider "aws" {
    profile = "default"  # or another profile from ~/.aws/credentials
    region  = var.region
}

# Connect the module for S3 and DynamoDB
# module "s3_backend" {
#   source = "./modules/s3-backend"
#   bucket_name = "clp-tfstate-938094936571-dev"
#   table_name = "terraform-locks"
# }

# Connect the VPC module
module "vpc" {
  source              = "./modules/vpc"           # Path to the VPC module
  vpc_cidr_block      = "10.0.0.0/16"             # CIDR block for the VPC
  public_subnets      = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]        # Public subnets
  private_subnets     = ["10.0.4.0/24", "10.0.5.0/24", "10.0.6.0/24"]         # Private subnets
  availability_zones  = ["us-east-1a", "us-east-1b", "us-east-1c"]            # Availability zones
  vpc_name            = "lesson-8-9-vpc"              # VPC name
}

# Connect the ECR module
module "ecr" {
  source = "./modules/ecr"
  repository_name = var.repository_name          # Repository name
  scan_on_push = true
}

module "eks" {
  source          = "./modules/eks"
  cluster_name    = var.cluster_name                    # Cluster name
  subnet_ids      = module.vpc.public_subnet_ids        # Subnet IDs
  instance_type   = var.instance_type                   # Instance type
  desired_size    = 1                                   # Desired number of nodes
  max_size        = 2                                   # Maximum number of nodes
  min_size        = 1                                   # Minimum number of nodes
}

data "aws_eks_cluster" "eks" {
  name       = module.eks.cluster_name
  depends_on = [module.eks]
}

data "aws_eks_cluster_auth" "eks" {
  name       = module.eks.cluster_name
  depends_on = [module.eks]
}

provider "kubernetes" {
  host                   = data.aws_eks_cluster.eks.endpoint
  cluster_ca_certificate = base64decode(data.aws_eks_cluster.eks.certificate_authority[0].data)
  token                  = data.aws_eks_cluster_auth.eks.token
}

provider "helm" {
  kubernetes = {
    host                   = data.aws_eks_cluster.eks.endpoint
    cluster_ca_certificate = base64decode(data.aws_eks_cluster.eks.certificate_authority[0].data)
    token                  = data.aws_eks_cluster_auth.eks.token
  }
}

module "jenkins" {
  source            = "./modules/jenkins"
  kubeconfig        = data.aws_eks_cluster.eks.endpoint
  cluster_name      = module.eks.cluster_name
  oidc_provider_arn = module.eks.oidc_provider_arn
  oidc_provider_url = module.eks.oidc_provider_url
  github_username   = var.github_username
  github_token      = var.github_token
  github_repo_url   = var.github_repo_url

  depends_on = [module.eks]

  providers = {
    helm       = helm
    kubernetes = kubernetes
  }
}

module "argo_cd" {
  source          = "./modules/argo_cd"
  namespace       = "argocd"
  chart_version   = "5.46.4"
  github_username = var.github_username
  github_token    = var.github_token
  github_repo_url = var.github_repo_url

  depends_on = [module.eks]
}
