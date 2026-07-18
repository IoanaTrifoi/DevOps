# Homework for the topic "Learning Argo CD + CD"

## Task steps

1. Jenkins + Helm + Terraform

- Install Jenkins via Helm, automating the installation with Terraform.
- Make Jenkins work through a Kubernetes Agent (Kaniko + Git).
- Implement a pipeline (via a Jenkinsfile) that:
- Builds an image from the Dockerfile;
- Pushes it to ECR;
- Updates the tag in the values.yaml of another repository;
- Pushes the changes to main.

2. Argo CD + Helm + Terraform

- Install Argo CD via Helm using Terraform.
- Configure an Argo CD Application that watches for Helm chart updates.
- Argo CD must automatically synchronize changes in the cluster after a Git update.

## Configuring variables
Create a `terraform.tfvars` file with the following variables:

```
github_token  = <your github token>
github_username  = <your github username>
github_repo_url = "https://github.com/<repo>.git"
```

You can use `terraform.tfvars.example` as an example.

## Commands for initialization, running, and destroying

```bash
# Initialization
terraform init

# Review infrastructure changes
terraform plan

# Apply the infrastructure
terraform apply

# Destroy the infrastructure
terraform destroy
```

## Configuring kubectl

```bash
# Connect to the EKS cluster
aws eks update-kubeconfig --region us-west-2 --name [EKS_CLUSTER_NAME]

# Check access
kubectl get nodes
```

## Pushing the Docker image to the newly created ECR repository

```bash
# Go to the Django project folder
cd docker/django

# Build the image without cache
docker build --no-cache -t django-app .

# Log in to ECR
aws ecr get-login-password --region us-east-1 | docker login --username AWS --password-stdin [ACCOUNT_ID].dkr.ecr.us-west-2.amazonaws.com

# Tag the image
docker tag django-app:latest [ACCOUNT_ID].dkr.ecr.us-west-2.amazonaws.com/django-app:latest

# Push the image
docker push [ACCOUNT_ID].dkr.ecr.us-west-2.amazonaws.com/django-app:latest

# Return to the project root directory
cd ../..
```

## Applying Helm:

```bash
cd charts/django-app
helm install django-app .
```

where `django-app` is your helm chart name.

## Deleting resources:

Kubernetes (PODs, Services, Deployments etc.)
```bash
helm uninstall django-app
```

where `django-app` is your helm chart name.

Terraform (EKS, VPC, ECR etc.)

```bash
terraform destroy
```

## Additional information:

If you want to update the helm chart:

```bash
helm upgrade django-app .
```

If you want to update terraform:

```bash
terraform init -upgrade
terraform plan
terraform apply
```

### Accessing Jenkins

```bash
# Jenkins URL
kubectl get services -n jenkins

# Get the initial Jenkins password
kubectl exec --namespace jenkins -it svc/jenkins -c jenkins -- /bin/cat /run/secrets/additional/chart-admin-password && echo

# Whether the password is already set: admin123
```

### Accessing Argo CD
```
# Get the Argo CD URL
kubectl get services -n argocd

# Get the initial admin password
kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d
```

### Configuring the remote backend

After the initial deployment, to enable the remote backend:

1. Uncomment the backend configuration block in `backend.tf`.

2. Run `terraform init` with the flag to reconnect the backend:

```bash
terraform init -reconfigure
```

### Recovery
1. Comment out the backend configuration in `backend.tf`.
2. Run `terraform init`.
3. Apply the configuration with `terraform apply`.
4. Uncomment the backend and run `terraform init -reconfigure`.
---
