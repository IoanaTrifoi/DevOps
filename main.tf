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

data "aws_eks_cluster" "eks" {
  name       = module.eks.eks_cluster_name
  depends_on = [module.eks]
}

data "aws_eks_cluster_auth" "eks" {
  name       = module.eks.eks_cluster_name
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

provider "aws" {
  region = var.region
}

# Connect the module for S3 and DynamoDB
#module "s3_backend" {
#  source      = "./modules/s3-backend"
#  bucket_name = var.bucket_name
#  table_name  = var.table_name
#}

# Connect the VPC module
module "vpc" {
  source             = "./modules/vpc"                                      # Path to the VPC module
  vpc_cidr_block     = "10.0.0.0/16"                                        # CIDR block for the VPC
  public_subnets     = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]        # Public subnets
  private_subnets    = ["10.0.4.0/24", "10.0.5.0/24", "10.0.6.0/24"]        # Private subnets
  availability_zones = ["us-west-2a", "us-west-2b", "us-west-2c"]           # Availability zones
  vpc_name           = "${var.name}-vpc"                                    # VPC name
  name               = var.name
}

# Connect the ECR module
module "ecr" {
  source = "./modules/ecr"

  repository_name = var.repository_name          # Repository name
  scan_on_push    = true                         # true → enable
}

module "eks" {
  source          = "./modules/eks"
  cluster_name    = "${var.name}-eks"             # Cluster name
  subnet_ids      = module.vpc.public_subnets     # Subnet IDs
  node_subnet_ids = module.vpc.private_subnets    # Private subnet IDs
  instance_type   = var.instance_type             # Instance type
  desired_size    = 2                             # Desired number of nodes
  max_size        = 4                             # Maximum number of nodes
  min_size        = 2                             # Minimum number of nodes
  depends_on      = [
    module.vpc.nat_instance_id
  ]
}

module "monitoring" {
  source = "./modules/monitoring"
  depends_on = [
    module.eks
  ]
}

module "jenkins" {
  source            = "./modules/jenkins"
  github_repo_url   = var.github_repo_url
  github_user       = var.github_user
  github_pat        = var.github_pat
  github_branch     = var.github_branch
  cluster_name      = module.eks.eks_cluster_name
  oidc_provider_arn = module.eks.oidc_provider_arn
  oidc_provider_url = module.eks.oidc_provider_url
  depends_on        = [module.eks]
  providers         = {
    kubernetes = kubernetes
  }
}

module "argo_cd" {
  source        = "./modules/argo_cd"
  namespace     = "argocd"
  chart_version = "8.1.3"
  rds_db_name   = var.rds_database_name
  rds_username  = var.rds_username
  rds_password  = var.rds_password
  rds_endpoint  = module.rds.rds_endpoint
  depends_on    = [module.eks]
}

module "rds" {
  source = "./modules/rds"

  name                  = "${var.name}-db"
  use_aurora            = var.rds_use_aurora
  aurora_instance_count = 2
  vpc_cidr_block        = module.vpc.vpc_cidr_block

  # --- Aurora-only ---
  engine_cluster                = var.rds_aurora_engine
  engine_version_cluster        = var.rds_aurora_engine_version
  parameter_group_family_aurora = var.rds_aurora_parameter_group_family


  # --- RDS-only ---
  engine                     = var.rds_instance_engine
  engine_version             = var.rds_instance_engine_version
  parameter_group_family_rds = var.rds_instance_parameter_group_family

  # Common
  instance_class          = var.rds_instance_class
  allocated_storage       = 20
  db_name                 = var.rds_database_name
  username                = var.rds_username
  password                = var.rds_password
  subnet_private_ids      = module.vpc.private_subnets
  subnet_public_ids       = module.vpc.public_subnets
  publicly_accessible     = var.rds_publicly_accessible
  vpc_id                  = module.vpc.vpc_id
  multi_az                = var.rds_multi_az
  backup_retention_period = var.rds_backup_retention_period
  parameters              = {
    max_connections            = "200"
    log_min_duration_statement = "500"
  }

  tags = {
    Environment = "dev"
    Project     = var.name
  }
  depends_on = [
    module.vpc
  ]
}
