# Homework: Building a flexible Terraform module for databases

## Module functionality:

- `use_aurora` = `true` → creates an Aurora Cluster + writer;
- `use_aurora` = `false` → creates a single `aws_db_instance`;
- In both cases:
  - an `aws_db_subnet_group` is created;
  - an `aws_security_group` is created;
  - a `parameter group` is created with basic parameters (`max_connections`, `log_statement`, `work_mem`);
  - The parameters `engine`, `engine_version`, `instance_class`, `multi_az` are set via variables.

## Configuring variables
In the project root, create a `terraform.tfvars` file with the following variables:

```
github_token  = <github_token>
github_username  = <github_username>
github_repo_url = "https://github.com/<repo>.git"

rds_password = <rds_password>
rds_username = <rds_username>
rds_database_name = <rds_database_name>
rds_publicly_accessible = true

# true → creates an Aurora Cluster + writer
# false → creates a single aws_db_instance
rds_use_aurora = true

rds_multi_az = false
rds_backup_retention_period = "0"
```

Or you can use `terraform.tfvars.example` as an example.

## Environment setup
`region` defaults to `us-east-1`

```
terraform init
terraform plan
terraform apply
```

## Configuring kubectl

```bash
# Connect to the EKS cluster
aws eks update-kubeconfig --region us-west-2 --name <your_cluster_name>

# Check access
kubectl get nodes

# or check the services in the cluster:
kubectl get svc -A
```
![bash](./assets/bash.png)
![jenkins](./assets/jenkins.png)

## Deleting resources
```bash
terraform destroy
```

## Configuring the remote backend

After the initial deployment, to enable the remote backend:

1. Uncomment the backend configuration block in `backend.tf`.

2. Run `terraform init` with the flag to reconnect the backend:

```bash
terraform init -reconfigure
```

## Recovery
1. Comment out the backend configuration in `backend.tf`.
2. Run `terraform init`.
3. Apply the configuration with `terraform apply`.
4. Uncomment the backend and run `terraform init -reconfigure`.
