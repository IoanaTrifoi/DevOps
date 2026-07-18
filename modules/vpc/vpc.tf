# Create the main VPC
resource "aws_vpc" "main" {
  cidr_block           = var.vpc_cidr_block   # CIDR block for our VPC (for example, 10.0.0.0/16)
  enable_dns_support   = true                 # Enables DNS support in the VPC
  enable_dns_hostnames = true                 # Enables the use of DNS names for resources in the VPC

  tags = {
    Name = var.vpc_name                       # Add a tag that includes the VPC name
  }
}

# Create the public subnets
resource "aws_subnet" "public" {
  count                   = length(var.public_subnets)
  # Create several subnets; the count is defined by the length of public_subnets
  vpc_id                  = aws_vpc.main.id              # Attach each subnet to the VPC created earlier
  cidr_block              = var.public_subnets[count.index]
  # CIDR block for the specific subnet from public_subnets
  availability_zone       = var.availability_zones[count.index] # Set the availability zone for each subnet
  map_public_ip_on_launch = true                         # Automatically assign public IP addresses to instances in the subnet

  tags = {
    Name = "${var.vpc_name}-public-subnet-${count.index + 1}"  # Tag with the subnet number
    "kubernetes.io/role/elb" = "1"
  }
}

# Create the private subnets
resource "aws_subnet" "private" {
  count             = length(var.private_subnets)
  # Create several private subnets; the count matches the length of private_subnets
  vpc_id            = aws_vpc.main.id               # Attach each private subnet to the VPC
  cidr_block        = var.private_subnets[count.index] # CIDR block for the specific subnet from private_subnets
  availability_zone = var.availability_zones[count.index] # Set the availability zone for the subnets

  tags = {
    Name = "${var.vpc_name}-private-subnet-${count.index + 1}"  # Tag for the subnet with a number
    "kubernetes.io/cluster/dev" = "shared"
  }
}

# Create an Internet Gateway for the public subnets
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main.id   # Attach the Internet Gateway to the VPC for internet access

  tags = {
    Name = "${var.vpc_name}-igw"   # Tag to identify the Internet Gateway
  }
}

## Create an Elastic IP for the NAT instance
#resource "aws_eip" "nat_eip" {
#  tags = {
#    Name = "${var.vpc_name}-nat-eip"
#  }
#}

## Create a NAT instance
#resource "aws_nat_gateway" "nat" {
#  allocation_id = aws_eip.nat_eip.id
#  subnet_id     = aws_subnet.public[0].id  # The NAT Gateway must be in a public subnet
#  tags = {
#    Name = "${var.vpc_name}-nat-gw"
#  }
#
#  depends_on = [aws_internet_gateway.igw]
#}
