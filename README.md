# Lesson-5 — Terraform (S3 Backend + DynamoDB Locks, VPC, ECR)

Infrastructure for **AWS `us-west-2` (Oregon)**.  
State is stored in **S3** with **DynamoDB** used for locking.

- **S3 bucket (for state):** `clp-tfstate-938094936571-dev`  
- **DynamoDB table (locks):** `terraform-locks`  
- **VPC:** `lesson-5-vpc` (CIDR `10.0.0.0/16`, **3 public + 3 private**)  
- **ECR:** `lesson-5-ecr` (**Scan on push: Enabled**)

> ⚠️ **NAT Gateway is a paid resource.** After the homework is reviewed, run `terraform destroy`.

---

## Requirements

- **Terraform ≥ 1.6**
- **AWS CLI**, configured for an account with region `us-west-2`
- **PowerShell** (the commands below are for PowerShell)

### Check
~~~powershell
terraform -version
aws --version
aws sts get-caller-identity
~~~

---

## Project structure

~~~text
lesson-5/
├── backend.tf
├── variables.tf
├── outputs.tf
└── modules/
    ├── s3-backend/
    │   ├── s3.tf
    │   ├── dynamodb.tf
    │   ├── variables.tf
    │   └── outputs.tf
    ├── vpc/
    │   ├── vpc.tf
    │   ├── routes.tf
    │   ├── variables.tf
    │   └── outputs.tf
    └── ecr/
        ├── ecr.tf
        ├── variables.tf
        └── outputs.tf
~~~

---

## Run order (bootstrap → backend migration → full apply)

Terraform has a "chicken-and-egg" problem: to store state in S3, you first need to create S3 and DynamoDB. So the first `apply` is done with **local state**, then we **migrate to S3**.

### 1) Initial run (local state)
~~~powershell
cd lesson-5
terraform fmt -recursive
terraform init
terraform validate

# If needed — only the backend resources (to be faster):
# terraform plan -target=module.s3_backend -out tf.plan
# terraform apply tf.plan

# Or the full plan:
terraform plan -out tf.plan
terraform apply tf.plan
~~~

### 2) Enable the remote backend (S3) and migrate the state

Make sure `backend.tf` contains exactly these values:

~~~hcl
terraform {
  backend "s3" {
    bucket         = "clp-tfstate-938094936571-dev"
    key            = "lesson-5/terraform.tfstate"
    region         = "us-west-2"
    dynamodb_table = "terraform-locks"
    encrypt        = true
  }
}
~~~

**Migrate the state to S3:**
~~~powershell
terraform init -migrate-state
~~~

### 3) Re-check / follow-up applies
~~~powershell
terraform plan
terraform apply
terraform output
~~~

---

## Expected outputs (example)

- `dynamodb_table_name = "terraform-locks"`
- `ecr_repository_url  = "938094936571.dkr.ecr.us-west-2.amazonaws.com/lesson-5-ecr"`
- `public_subnet_ids   = ["subnet-…", "subnet-…", "subnet-…"]`
- `private_subnet_ids  = ["subnet-…", "subnet-…", "subnet-…"]`
- `s3_bucket_name      = "clp-tfstate-938094936571-dev"`
- `vpc_id              = "vpc-…"`

---

## Verification in the AWS Console

**S3 → Buckets → `clp-tfstate-938094936571-dev`**
- Contains `lesson-5/terraform.tfstate`
- `Versioning: Enabled`
- `Block public access: On`

**DynamoDB → Tables → `terraform-locks`**
- During `plan/apply` a `LockID` record (lock) is created

**VPC → `lesson-5-vpc`**
- 6 subnets (**3 public**, **3 private**) in `us-west-2a/b/c`
- IGW attached to the VPC, **1 NAT Gateway** in a public subnet
- Route Tables: ``*-rt-public`` with `0.0.0.0/0` via **IGW**; ``*-rt-private`` via **NAT**

**ECR → `lesson-5-ecr`**
- `Scan on push: Enabled`
- Repository policy: access for `arn:aws:iam::<account-id>:root`

---

## Common commands

~~~powershell
terraform fmt -recursive
terraform init
terraform validate
terraform plan
terraform apply
terraform state list
terraform output
terraform destroy
~~~

---

## If the resources already existed (import into state)

For errors like `AlreadyExists` / `ResourceInUse`:

~~~powershell
# Import the DynamoDB locks table
terraform import module.s3_backend.aws_dynamodb_table.tf_locks terraform-locks

# Import the ECR repository
terraform import module.ecr.aws_ecr_repository.repo lesson-5-ecr
~~~

After importing — `terraform plan` → `terraform apply`.

---

## Cost and cleanup

- **The NAT Gateway is billed hourly.**  
- After the homework is reviewed:

~~~powershell
cd lesson-5
terraform destroy
~~~
