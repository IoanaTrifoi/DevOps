variable "name" {
  description = "Helm release name"
  type        = string
  default     = "argo-cd"
}

variable "namespace" {
  description = "K8s namespace for Argo CD"
  type        = string
  default     = "argocd"
}

variable "github_username" {
  description = "GitHub username"
  type        = string
  sensitive   = true
}

variable "github_token" {
  description = "GitHub Personal Access Token"
  type        = string
  sensitive   = true
}

variable "github_repo_url" {
  description = "GitHub repository name"
  type        = string
}

variable "chart_version" {
  description = "Argo CD chart version"
  type        = string
  default     = "5.46.4"
}

variable "rds_username" {
  description = "RDS username"
  type        = string
}
variable "rds_db_name" {
  description = "RDS database name"
  type        = string
}
variable "rds_password" {
  description = "RDS password"
  type        = string
  sensitive   = true
}
variable "rds_endpoint" {
  description = "RDS endpoint"
  type        = string
}
