variable "kubeconfig" {
  description = "Path to the kubeconfig file"
  type        = string
}

variable "cluster_name" {
  description = "Kubernetes cluster name"
  type        = string
}

variable "oidc_provider_arn" {
  description = "OIDC provider ARN for IRSA"
  type        = string
}

variable "oidc_provider_url" {
  description = "OIDC provider URL for IRSA"
  type        = string
}

variable "github_username" {
  description = "GitHub username"
  type        = string
  default     = ""
  sensitive   = true
}

variable "github_token" {
  description = "GitHub Personal Access Token"
  type        = string
  default     = ""
  sensitive   = true
}

variable "github_repo_url" {
  description = "GitHub repository URL"
  type        = string
}
