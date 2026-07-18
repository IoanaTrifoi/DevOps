resource "aws_ecr_repository" "ecr" {
  name                 = var.repository_name
  force_delete         = var.force_delete              # Allows deleting the repo together with its images
  image_tag_mutability = var.image_tag_mutability      # IMMUTABLE or MUTABLE

  image_scanning_configuration {
    scan_on_push = var.scan_on_push
  }

  tags = {
    Name        = var.repository_name
  }
}

# ECR Repository Policy
# Access only for accounts/roles from your AWS tenant.
data "aws_caller_identity" "current" {}

locals {
  default_policy = jsonencode({
    Version   = "2012-10-17"
    Statement = [
      {
        Sid       = "AllowPushPullWithinAccount"
        Effect    = "Allow"
        Principal = {
          AWS = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"
        }
        Action = [
          "ecr:BatchCheckLayerAvailability",
          "ecr:GetDownloadUrlForLayer",
          "ecr:BatchGetImage",
          "ecr:PutImage",
          "ecr:InitiateLayerUpload",
          "ecr:UploadLayerPart",
          "ecr:CompleteLayerUpload"
        ]
      }
    ]
  })
}

resource "aws_ecr_repository_policy" "ecr_policy" {
  repository = aws_ecr_repository.ecr.name
  policy = coalesce(var.repository_policy, local.default_policy)
}
