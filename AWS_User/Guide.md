# IAM User Setup Guide (Best Practice)

This guide outlines the recommended AWS IAM setup for running Terraform and managing infrastructure following security best practices.

---

# 1. Goals

* Do **not** use the AWS root account for any infrastructure operations.
* Separate **console administration** and **Terraform automation**.
* Enforce least-privilege IAM.

---

# 2. IAM Users Overview

You will create exactly **two** IAM users:

## 1. `admin` — Console Administrator

**Purpose:** Human login to AWS Console.

**Permissions:**

* `AdministratorAccess`

**Security Requirements:**

* MFA: **Enabled** (Google Authenticator)
* Access Key: **NOT allowed** (console-only)

**Usage:**

* Inspect resources
* View CloudWatch logs, networking, RDS, EKS
* Approve or debug deployments

---

## 2. `terraform` — Terraform Automation User

**Purpose:** Executes `terraform init/plan/apply` to provision infrastructure.

**Permissions:**

* `PowerUserAccess` (full access to all AWS services **except** IAM & billing)
* Additional managed policies required by Terraform for EKS, EC2, and VPC:

  * `AmazonEKSClusterPolicy`
  * `AmazonEKSWorkerNodePolicy`
  * `AmazonEC2ContainerRegistryReadOnly`
  * `AmazonEC2FullAccess`
  * `AmazonVPCFullAccess`

**Security Requirements:**

* MFA: Optional
* Access Key: **Required** (Terraform needs programmatic access)
* Console login: **Disabled**

**Usage:**

* Run Terraform locally or in CI/CD
* Deploy VPC, EKS, RDS, ALB, IAM roles (except IAM users)

---

# 3. Why This Structure?

### Separation of Duties

* `admin`: Human oversight
* `terraform`: Automated infrastructure provisioning

### Least Privilege

* Terraform cannot modify IAM users or sensitive account settings
* Admin account does not use long-lived access keys

### Security Best Practice

* Root account never used
* MFA enforced on privileged users
* Terraform has exactly the permissions it needs, nothing more

---

# 4. Steps to Create IAM Users

## 4.1 Create `admin`

1. Go to **IAM → Users → Create User**
2. Name: `admin`
3. Enable console access
4. Attach policy: `AdministratorAccess`
5. Require MFA
6. Do NOT create access keys

---

## 4.2 Create `terraform`

1. IAM → Users → Create User
2. Name: `terraform`
3. Programmatic access only (access key)
4. Disable console login
5. Attach policies:

   * `PowerUserAccess`
   * `AmazonEKSClusterPolicy`
   * `AmazonEKSWorkerNodePolicy`
   * `AmazonECSContainerRegistryReadOnly`
   * `AmazonEC2FullAccess`
   * `AmazonVPCFullAccess`
6. Download access key + secret key for Terraform backend

---

# 5. Notes for Production

* Store Terraform access key in SSM Parameter Store or Secrets Manager
* Rotate access keys regularly (every 90 days)
* Prefer Terraform Cloud or GitHub OIDC instead of long-lived keys
* Use IAM Roles for Service Accounts (IRSA) for fine-grained EKS pod permissions

---

# 6. Summary

| User          | For                | Permissions                            | MFA      | Access Key |
| ------------- | ------------------ | -------------------------------------- | -------- | ---------- |
| **admin**     | Console management | AdministratorAccess                    | Yes      | No         |
| **terraform** | Terraform IaC      | PowerUserAccess + EKS/VPC/EC2 policies | Optional | Yes        |

---

This IAM structure follows AWS security best practices, supports Terraform automation, and ensures a clean separation between human and machine access.
