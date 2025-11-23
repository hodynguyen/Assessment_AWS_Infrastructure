# Cloud Infrastructure Setup Checklist (Creative Force Assessment)

This checklist outlines all AWS resources required to build the cloud infrastructure for the new service.  
Each step includes **what to create** and **why**, following industry best practices for production systems.

---

## 1. Create VPC
**Purpose:** Define the private network boundary for all resources.  
- CIDR: `10.0.0.0/16`

---

## 2. Create Public Subnets (2 AZs)
**Purpose:** Host all Internet-facing components.  
- public-a: `10.0.1.0/24`  
- public-b: `10.0.2.0/24`  
**Used for:** Load Balancer, NAT Gateway

---

## 3. Create Private Subnets (2 AZs)
**Purpose:** Host internal workloads that must not be exposed publicly.  
- private-a: `10.0.3.0/24`  
- private-b: `10.0.4.0/24`  
**Used for:** API (EKS/ECS), RDS, Metrics Collector, internal services

---

## 4. Create Internet Gateway (IGW)
**Purpose:** Allow public subnets to communicate with the Internet.

---

## 5. Attach IGW to the VPC
**Purpose:** Activate outbound/inbound Internet access for resources in public subnets.

---

## 6. Create NAT Gateway (in Public Subnet A)
**Purpose:** Allow private subnets to access the Internet for pulling images, package updates, etc., without exposing them publicly.

---

## 7. Create Public Route Table
**Purpose:** Route public subnet traffic to the Internet.  
- Route: `0.0.0.0/0 → Internet Gateway`  
- Associate with: public-a, public-b

---

## 8. Create Private Route Table
**Purpose:** Allow private subnets to reach the Internet through NAT Gateway.  
- Route: `0.0.0.0/0 → NAT Gateway`  
- Associate with: private-a, private-b

---

## 9. Create Security Groups

### **alb-sg**
- Inbound: 80/443 from `0.0.0.0/0`  
- Outbound: allow all  
**Purpose:** Public entrypoint (UI/API) through ALB.

### **api-sg**
- Inbound: 80/443 from alb-sg  
- Outbound: 5432 to db-sg  
**Purpose:** Protect API pods/containers.

### **db-sg**
- Inbound: 5432 from api-sg  
**Purpose:** Restrict DB access to API only (zero-trust).

---

## 10. Create S3 Bucket for UI
**Purpose:** Store static frontend assets.  
- Enable versioning

---

## 11. Create CloudFront Distribution
**Purpose:** CDN for UI, improves latency and serves HTTPS.  
- Origin: S3 bucket  
- Domain: `www.acme.com`  
- SSL: ACM certificate

---

## 12. Create RDS PostgreSQL
**Purpose:** Backend relational database for the API.  
- Engine: PostgreSQL  
- Subnet Group: private subnets  
- Public access: False  
- Multi-AZ: Enabled  
- Security Group: db-sg  
- Automated backups enabled

---

## 13. Create EKS Cluster (or ECS Fargate)
**Purpose:** Run API containers in a scalable, resilient environment.  
- Node Groups in private subnets  
- Recommended add-ons:  
  - VPC CNI  
  - CoreDNS  
  - kube-proxy  
  - ALB Ingress Controller  
  - Cluster Autoscaler

---

## 14. Deploy API to EKS
**Purpose:** Deploy backend application with proper scaling and routing.  
Includes:
- Deployment (image: `acme/api`)  
- Service (ClusterIP)  
- Ingress (ALB) mapping `api.acme.com`  
- Secrets: POSTGRES_URL  
- ConfigMap: METRICS_URL  
- HPA for autoscaling

---

## 15. Set Up Observability

### **Option A — AWS CloudWatch**
- Logs  
- Metrics  
- Dashboards  
- Alarms  

### **Option B — Prometheus Stack**
- Prometheus Server / Agent  
- Grafana  
- Alertmanager  
- Node Exporter  

**Purpose:** Maintain visibility, alerting, and operational health.

---

## 16. (Optional) Add AWS WAF
**Purpose:** Protect the application from common web attacks (SQLi, XSS, bots, etc.) when exposed via the ALB.

---

# Final Notes
Completing this checklist results in a production-ready infrastructure:
- UI: CloudFront → S3  
- API: Route53 → ALB → EKS (Pods)  
- DB: Private RDS PostgreSQL  
- Metrics: CloudWatch or Prometheus  
- Secure VPC with public/private subnets, NAT, IGW  
- Automated scaling, HTTPS, zero-trust networking, and full observability.
