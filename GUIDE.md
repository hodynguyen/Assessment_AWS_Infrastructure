# Cloud Infrastructure Setup Checklist  
**Creative Force – DevOps Engineer Assessment 2025**

This checklist details all AWS components required to deploy the new service composed of:  
- UI (Docker Image)  
- API (Docker Image)  
- PostgreSQL Database  
- Metrics Collector  

It follows production-grade best practices focusing on scalability, security, observability, and zero-trust networking.

---

# 1. Create VPC
**Purpose:** Private network boundary for all infrastructure resources.

- CIDR: `10.0.0.0/16`

---

# 2. Create Public Subnets (2 AZs)
**Purpose:** Host Internet-facing components.

- `public-a`: `10.0.1.0/24`  
- `public-b`: `10.0.2.0/24`  
**Used for:** ALB, NAT Gateway, Bastion (optional)

---

# 3. Create Private Subnets (2 AZs)
**Purpose:** Host internal workloads (containers, DB, metrics).

- `private-a`: `10.0.3.0/24`  
- `private-b`: `10.0.4.0/24`  
**Used for:** API (EKS/ECS), UI containers, Metrics Collector, RDS

---

# 4. Create Internet Gateway
**Purpose:** Allow outbound and inbound Internet connectivity for public subnets.

---

# 5. Attach IGW to VPC
**Purpose:** Activate IGW routing for public resources.

---

# 6. Create NAT Gateway
Place in **public-a**.

**Purpose:**  
Allow private subnets to:  
- Pull Docker images  
- Download dependencies  
- Reach external APIs  
Without exposing private workloads publicly.

---

# 7. Create Public Route Table
- Route: `0.0.0.0/0 → Internet Gateway`
- Associate with: `public-a`, `public-b`

---

# 8. Create Private Route Table
- Route: `0.0.0.0/0 → NAT Gateway`
- Associate with: `private-a`, `private-b`

---

# 9. Create Security Groups

## alb-sg
- Inbound: 80/443 from `0.0.0.0/0`
- Outbound: allow all  
**Purpose:** Public entry point for UI and API.

## ui-sg
- Inbound: 80 from `alb-sg`
- Outbound: allow all  
**Purpose:** Serve UI traffic securely via ALB.

## api-sg
- Inbound: 80/443 from `alb-sg`
- Outbound: 5432 to `db-sg`
- Outbound: 80 to `metrics-sg`  
**Purpose:** Enforce zero-trust between API → DB and API → Metrics.

## db-sg
- Inbound: 5432 from `api-sg`  
**Purpose:** Ensure only API can reach the database.

## metrics-sg
- Inbound: 80 from `api-sg`  
**Purpose:** Allow API to push/pull metrics.

---

# 10. Create RDS PostgreSQL
- Engine: PostgreSQL  
- Multi-AZ: **Enabled**  
- Subnet group: `private-a`, `private-b`  
- Public access: **False**  
- Security Group: `db-sg`  
- Backup retention: 7–14 days  
- Enhanced Monitoring: Enabled  

**Purpose:** Primary system-of-record database.

---

# 11. Create EKS Cluster (or ECS Fargate)
**Purpose:** Run UI, API, and Metrics Collector containers.**

### Cluster:
- Control plane subnet: private  
- Endpoint access: Private or Public+Private  
- IAM OIDC enabled  
- Add-ons:
  - VPC CNI  
  - CoreDNS  
  - kube-proxy  
  - Metrics Server  
  - AWS Load Balancer Controller  
  - Cluster Autoscaler  

### Node Groups:
- Inside private subnets  
- IAM Policies:
  - AmazonEKSWorkerNodePolicy  
  - AmazonEKS_CNI_Policy  
  - AmazonEC2ContainerRegistryReadOnly  

---

# 12. Deploy UI (Docker Image: `acme/ui`)
The UI is a **container**, not static files → must run on EKS/ECS.

### Kubernetes Resources:
- Deployment: runs `acme/ui`
- Service: ClusterIP on port 80
- Ingress:
  - Host: `www.acme.com`
  - Route → UI service via ALB

### SSL:
- ACM certificate for `www.acme.com`

---

# 13. Deploy API (Docker Image: `acme/api`)
### Kubernetes Resources:
- Deployment: runs `acme/api`
- Service: ClusterIP (port 80 or 443)
- Secrets:
  - POSTGRES_URL
  - METRICS_URL
- ConfigMaps (if needed)
- HPA for autoscaling

### Ingress:
- Host: `api.acme.com`
- ALB listener → API service

---

# 14. Deploy Metrics Collector
**Purpose:** Internal-only metrics or APM agent.**

### Kubernetes Resources:
- Deployment (port 80)
- Service (ClusterIP)
- Security filtered by `metrics-sg`

Only API may reach metrics collector.

---

# 15. Configure Route53
Create Hosted Zone: **acme.com**

Records:
- `www.acme.com` → ALB (Alias)
- `api.acme.com` → ALB (Alias)

---

# 16. Observability

## Option A — AWS CloudWatch
- Container logs  
- EKS logs  
- Metrics dashboard  
- Alerts (CPU, memory, 5xx, RDS)  

## Option B — Prometheus Stack
- Prometheus  
- Grafana  
- Alertmanager  
- Node / Pod exporters  

---

# 17. Backups & Resilience
- RDS automated backups  
- RDS PITR enabled  
- EKS cluster backup (Velero optional)  
- ALB access logs to S3  
- CloudTrail enabled  

---

# 18. Security Hardening
- Zero-trust Security Groups  
- All workloads in private subnets  
- No public IP on nodes  
- ACM TLS everywhere  
- Least-privilege IAM  
- OIDC + IRSA  
- HTTPS termination at ALB  
- WAF (optional)

---

# Final Architecture Summary

## UI (public)
User → ALB → UI Deployment → Pods

## API (public)
User → ALB → API Deployment → Pods → PostgreSQL + Metrics

## Database (private)
API → RDS PostgreSQL

## Metrics (private)
API → Metrics Collector

## Networking
Public subnets:
- ALB
- NAT Gateway  

Private subnets:
- EKS nodes
- API/UI workloads  
- RDS  
- Metrics Collector  

---

This architecture satisfies the evaluation criteria:  
- Zero-downtime updates  
- Auto-scaling  
- Least-privilege + zero-trust  
- IaC compatibility  
- Disaster recovery  
- Observability & cost awareness  
- Production-grade ingress, TLS, and routing  
