variable "cluster_name" { type = string }
variable "vpc_id" { type = string }
variable "public_subnet_ids" { type = list(string) }
variable "region" { type = string }
variable "desired_size" { type = number }
variable "min_size" { type = number }
variable "max_size" { type = number }
variable "instance_types" { type = list(string) }
