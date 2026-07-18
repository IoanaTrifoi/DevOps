# Lesson 7 — EKS + ECR + Helm (Django)

Region: **us-west-2**  
AWS account: **938094936571**  
Cluster: **lesson-6-eks**  
ECR repository: **938094936571.dkr.ecr.us-west-2.amazonaws.com/lesson-6-django**  
Image tag: **0.1.0**

---

## 1) Prerequisites

- Terraform ≥ 1.13
- AWS CLI 2.x (profile configured with permissions for EKS/ECR/IAM/EC2/S3)
- kubectl, Helm v3, Docker Desktop (Linux engine)
- `backend.tf` uses an **S3 backend** with `use_lockfile = true` (no DynamoDB)

> Example `backend.tf`:
>
> ```hcl
> terraform {
>   backend "s3" {
>     bucket       = "clp-tfstate-938094936571-dev"
>     key          = "terraform.tfstate"
>     region       = "us-west-2"
>     encrypt      = true
>     use_lockfile = true
>   }
> }
> ```

> If the S3 bucket does not exist yet:
> ```powershell
> $REGION="us-west-2"; $ACCOUNT="938094936571"
> $BUCKET="clp-tfstate-$ACCOUNT-dev"
> aws s3api create-bucket --bucket $BUCKET --region $REGION --create-bucket-configuration LocationConstraint=$REGION
> aws s3api put-bucket-versioning --bucket $BUCKET --versioning-configuration Status=Enabled
> aws s3api put-bucket-encryption --bucket $BUCKET --server-side-encryption-configuration '{ "Rules": [ { "ApplyServerSideEncryptionByDefault": { "SSEAlgorithm": "AES256" } } ] }'
> aws s3api put-public-access-block --bucket $BUCKET --public-access-block-configuration BlockPublicAcls=true,IgnorePublicAcls=true,BlockPublicPolicy=true,RestrictPublicBuckets=true
> ```

---

## 2) Infrastructure (Terraform)

```powershell
terraform init -reconfigure
terraform plan -out=tfplan
terraform apply tfplan

# kubeconfig to access the cluster
aws eks update-kubeconfig --region us-west-2 --name lesson-6-eks

# check the nodes
kubectl get nodes
```

---

## 3) Image (Docker + ECR)

```powershell
$REGION = "us-west-2"
$ACCOUNT = "938094936571"
$ECR = "$ACCOUNT.dkr.ecr.$REGION.amazonaws.com/lesson-6-django"
$TAG = "0.1.0"

# log in to ECR
$PASS = (aws ecr get-login-password --region $REGION).Trim()
docker login --username AWS --password $PASS "$ACCOUNT.dkr.ecr.$REGION.amazonaws.com"

# build and push
docker build -t django-app:$TAG -f .\django\Dockerfile .\django
docker tag django-app:$TAG "$ECR:$TAG"
docker push "$ECR:$TAG"

# check the tags
aws ecr list-images --repository-name lesson-6-django --query 'imageIds[].imageTag'
```

## 4) PostgreSQL in the cluster

```powershell
kubectl apply -f .\k8s\postgres.yaml
kubectl get pods -w
kubectl get svc db
```

Environment variables used by the application (via a ConfigMap in Helm):

```text
POSTGRES_DB=appdb
POSTGRES_USER=appuser
POSTGRES_PASSWORD=apppassword
DB_HOST=db
DB_PORT=5432
DJANGO_DEBUG=True
```

## 5) Deploy via Helm

In `charts\django-app\values.yaml` the following must be configured:

```text
image.repository = 938094936571.dkr.ecr.us-west-2.amazonaws.com/lesson-6-django
image.tag = "0.1.0"
service: type LoadBalancer, port 80, targetPort 8000
autoscaling: min 2, max 6, targetCPU 70
envConfig with the variables above
```

```powershell
# metrics-server (for HPA)
helm repo add metrics-server https://kubernetes-sigs.github.io/metrics-server/
helm repo update
helm install metrics-server metrics-server/metrics-server -n kube-system
kubectl rollout status deployment/metrics-server -n kube-system

# deploy the application
helm install django-app .\charts\django-app\

# check the resources
kubectl get pods
kubectl get svc
kubectl get hpa
```

## 6) Access

Get the external address (DNS) of the LoadBalancer service:

```powershell
kubectl get svc django-app
```

Open it in a browser:

```text
http://<EXTERNAL-IP>/
```

## 7) Acceptance checks

```powershell
# the cluster is running
kubectl get nodes -o wide

# ECR contains the image
aws ecr describe-repositories --repository-names lesson-6-django
aws ecr list-images --repository-name lesson-6-django --query 'imageIds[].imageTag'

# resources from Helm
helm list
kubectl get deploy,rs,pods
kubectl get svc django-app
kubectl get hpa django-app

# ConfigMap and env inside the container
kubectl get cm -l app.kubernetes.io/name=django-app -o name
kubectl exec -it deploy/django-app -- sh -lc 'env | grep -E "POSTGRES|DB_HOST|DJANGO_DEBUG"'
```

## 8) Cleanup

```powershell
helm uninstall django-app
kubectl delete -f .\k8s\postgres.yaml
helm uninstall metrics-server -n kube-system
terraform destroy -auto-approve
```
