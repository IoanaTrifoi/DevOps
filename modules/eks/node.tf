# IAM role for the EC2 nodes (Worker Nodes)
resource "aws_iam_role" "nodes" {
  # Role name for the nodes
  name = "${var.cluster_name}-nodes"

  # Policy that allows EC2 to assume the role
  assume_role_policy = jsonencode({
    Version   = "2012-10-17"
    Statement = [
      {
        Effect    = "Allow"
        Action    = "sts:AssumeRole"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      }
    ]
  })
}

# Attach the policy for EKS Worker Nodes
resource "aws_iam_role_policy_attachment" "amazon_eks_worker_node_policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
  role       = aws_iam_role.nodes.name
}

# Attach the policy for the Amazon VPC CNI plugin
resource "aws_iam_role_policy_attachment" "amazon_eks_cni_policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
  role       = aws_iam_role.nodes.name
}

# Attach the policy for reading from Amazon ECR
resource "aws_iam_role_policy_attachment" "amazon_ec2_container_registry_read_only" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
  role       = aws_iam_role.nodes.name
}

#resource "aws_iam_role_policy_attachment" "amazon_ebs_csi_driver_policy" {
#  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEBSCSIDriverPolicy"
#  role       = aws_iam_role.nodes.name
#}
#
#resource "aws_iam_role_policy_attachment" "efs_csi_driver_policy" {
#  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEFSCSIDriverPolicy"
#  role       = aws_iam_role.nodes.name
#}
#
#resource "aws_iam_role_policy_attachment" "ssm_managed_instance_core" {
#  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
#  role       = aws_iam_role.nodes.name
#}

#resource "aws_iam_policy" "ebs_csi_custom_policy" {
#  name        = "AmazonEBSCSICustomPolicy-custom"
#  description = "Custom policy for EBS CSI driver"
#  policy      = jsonencode({
#    Version   = "2012-10-17",
#    Statement = [
#      {
#        Effect = "Allow",
#        Action = [
#          "ec2:CreateVolume",
#          "ec2:DeleteVolume",
#          "ec2:AttachVolume",
#          "ec2:DetachVolume",
#          "ec2:DescribeAvailabilityZones",
#          "ec2:DescribeVolumes",
#          "ec2:DescribeVolumesModifications",
#          "ec2:DescribeInstances",
#          "ec2:DescribeTags"
#        ],
#        Resource = "*"
#      }
#    ]
#  })
#}

#resource "aws_iam_role_policy_attachment" "attach_custom_ebs_policy" {
#  policy_arn = aws_iam_policy.ebs_csi_custom_policy.arn
#  role       = aws_iam_role.nodes.name
#}

# Create the Node Group for EKS
resource "aws_eks_node_group" "general" {
  # EKS cluster name
  cluster_name = aws_eks_cluster.eks.name

  # Node group name
  node_group_name = var.node_group_name

  # IAM role for the nodes
  node_role_arn = aws_iam_role.nodes.arn

  # Subnets where the EC2 nodes will be placed
  #  subnet_ids = var.subnet_ids
  subnet_ids = var.node_subnet_ids

  # EC2 instance type for the nodes
  capacity_type  = "ON_DEMAND"
  instance_types = [var.instance_type]

  # Scaling configuration
  scaling_config {
    desired_size = var.desired_size  # Desired number of nodes
    max_size     = var.max_size      # Maximum number of nodes
    min_size     = var.min_size      # Minimum number of nodes
  }

  # Node update configuration
  update_config {
    max_unavailable = 1  # Maximum number of nodes that can be updated at the same time
  }

  # Add labels to the nodes
  labels = {
    role = var.node_group_name
  }

  tags = {
    Name = var.node_group_name
  }

  # Dependencies for creating the Node Group
  depends_on = [
    aws_iam_role_policy_attachment.amazon_eks_worker_node_policy,
    aws_iam_role_policy_attachment.amazon_eks_cni_policy,
    aws_iam_role_policy_attachment.amazon_ec2_container_registry_read_only,
    #    aws_iam_role_policy_attachment.amazon_ebs_csi_driver_policy,
    #    aws_iam_role_policy_attachment.efs_csi_driver_policy,
    #    aws_iam_role_policy_attachment.ssm_managed_instance_core,
    #    aws_iam_role_policy_attachment.attach_custom_ebs_policy,
  ]

  lifecycle {
    ignore_changes = [scaling_config[0].desired_size]
  }
}
