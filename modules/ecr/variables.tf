# Required
variable "repository_name" {
  type        = string
  description = "ECR repository name"
}

# Optional
variable "scan_on_push" {
  type        = bool
  description = "Whether to scan images for vulnerabilities right after push."
  default     = true
}

variable "image_tag_mutability" {
  type        = string
  description = "IMMUTABLE locks changes to existing tags; MUTABLE allows overwriting."
  default     = "MUTABLE"
}

variable "force_delete" {
  type        = bool
  description = "If true, deleting the repo automatically deletes all images inside it."
  default     = true
}

variable "repository_policy" {
  type        = string
  description = "Repository JSON policy."
  default     = null
}
