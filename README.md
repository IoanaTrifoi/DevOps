# Step-by-step guide for completing the final project

## Task description
Technical requirements:

 1. Infrastructure: AWS using Terraform
 2. Components: VPC, EKS, RDS, ECR, Jenkins, Argo CD, Prometheus, Grafana

---

## Project structure

```
Project/
│
├── main.tf         # Main file for connecting the modules
├── backend.tf        # Backend configuration for state (S3 + DynamoDB)
├── outputs.tf        # General resource outputs
│
├── modules/         # Directory with all modules
│  ├── s3-backend/     # Module for S3 and DynamoDB
│  │  ├── s3.tf      # Create the S3 bucket
│  │  ├── dynamodb.tf   # Create DynamoDB
│  │  ├── variables.tf   # Variables for S3
│  │  └── outputs.tf    # Output information about S3 and DynamoDB
│  │
│  ├── vpc/         # Module for VPC
│  │  ├── vpc.tf      # Create the VPC, subnets, Internet Gateway
│  │  ├── routes.tf    # Routing configuration
│  │  ├── variables.tf   # Variables for VPC
│  │  └── outputs.tf  
│  ├── ecr/         # Module for ECR
│  │  ├── ecr.tf      # Create the ECR repository
│  │  ├── variables.tf   # Variables for ECR
│  │  └── outputs.tf    # Output the repository URL
│  │
│  ├── eks/           # Module for the Kubernetes cluster
│  │  ├── eks.tf        # Create the cluster
│  │  ├── aws_ebs_csi_driver.tf # Install the CSI driver plugin
│  │  ├── variables.tf   # Variables for EKS
│  │  └── outputs.tf    # Output information about the cluster
│  │
│  ├── rds/         # Module for RDS
│  │  ├── rds.tf      # Create the RDS database  
│  │  ├── aurora.tf    # Create the Aurora database cluster  
│  │  ├── shared.tf    # Shared resources  
│  │  ├── variables.tf   # Variables (resources, credentials, values)
│  │  └── outputs.tf  
│  │ 
│  ├── jenkins/       # Module for the Helm install of Jenkins
│  │  ├── jenkins.tf    # Helm release for Jenkins
│  │  ├── variables.tf   # Variables (resources, credentials, values)
│  │  ├── providers.tf   # Provider declarations
│  │  ├── values.yaml   # Jenkins configuration
│  │  └── outputs.tf    # Outputs (URL, admin password)
│  │ 
│  └── argo_cd/       # ✅ New module for the Helm install of Argo CD
│    ├── jenkins.tf    # Helm release for Jenkins
│    ├── variables.tf   # Variables (chart version, namespace, repo URL, etc.)
│    ├── providers.tf   # Kubernetes+Helm. carried over from the jenkins module
│    ├── values.yaml   # Custom Argo CD configuration
│    ├── outputs.tf    # Outputs (hostname, initial admin password)
│		  └──charts/         # Helm chart for creating apps
│ 	 	  ├── Chart.yaml
│	 	  ├── values.yaml     # List of applications, repositories
│			  └── templates/
│		    ├── application.yaml
│		    └── repository.yaml
├── charts/
│  └── django-app/
│    ├── templates/
│    │  ├── deployment.yaml
│    │  ├── service.yaml
│    │  ├── configmap.yaml
│    │  └── hpa.yaml
│    ├── Chart.yaml
│    └── values.yaml   # ConfigMap with environment variables
└──Django
			 ├── app\
			 ├── Dockerfile
			 ├── Jenkinsfile
			 └── docker-compose.yaml

```
# Execution steps

## Preparing the environment:

Initialize Terraform.
Check all the required variables and parameters.

    github_pat  = <github token>
    github_user  = <github username>
    github_repo_url = "https://github.com/<repo>.git"
    github_branch = "main"

    rds_password = <rds_password>
    rds_username = <rds_username>
    rds_database_name = <rds_database_name>
    rds_publicly_accessible = true

    # true → creates an Aurora Cluster + writer
    # false → creates a single aws_db_instance
    rds_use_aurora = true
    rds_multi_az = false
    rds_backup_retention_period = "0"

## Deploying the infrastructure:

region defaults to us-west-2

```bash

terraform init
terraform plan
terraform apply

```

## Configuring kubectl

```bash

aws eks update-kubeconfig --region us-west-2 --name <your_cluster_name>

kubectl get nodes

kubectl get svc -A

```

Open the Jenkins LoadBalancer URL (username: admin; password: admin123)

Run the seed-job task (this creates a new django-docker job)
Run the django-docker job:
  Builds and pushes the Docker image to ECR
  Merges an MR in your repository updating the application version (based on the build number of the Jenkins django-docker job)

## Checking availability:

  Jenkins:

```bash

kubectl port-forward svc/jenkins 8080:8080 -n jenkins

```

  Argo CD:

```bash

kubectl port-forward svc/argocd-server 8081:443 -n argocd

```

## Monitoring and checking metrics:

  Grafana:

```bash

kubectl port-forward svc/grafana 3000:80 -n monitoring

```

  open http://localhost:3000
  enter the username admin and the password obtained with the following command: kubectl get secret --namespace monitoring kube-prometheus-stack-grafana -o jsonpath="{.data.admin-password}" | base64 --decode
  Check the state of the metrics in the Grafana Dashboard.

## Deleting resources

```bash

terraform destroy

```
