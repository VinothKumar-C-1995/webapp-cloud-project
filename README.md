# ☁️ Production Cloud Architecture — AWS

> Technical assessment submission: containerized web app on AWS with Terraform IaC, ALB, ECS Fargate auto-scaling, and GitHub Actions CI/CD.

---

## 📁 Project Structure

```
webapp-project/
├── app/                        # Node.js application
│   ├── app.js                  # Express server
│   ├── app.test.js             # Jest tests
│   └── package.json
├── docker/
│   └── nginx.conf              # Nginx reverse proxy config
├── terraform/
│   ├── main.tf                 # Root module (wires all modules)
│   ├── variables.tf
│   ├── outputs.tf
│   ├── provider.tf
│   ├── terraform.tfvars        # Configuration values
│   └── modules/
│       ├── vpc/                # VPC, subnets, SGs, NAT GW
│       ├── ecr/                # Container registry
│       ├── ecs/                # ECS Fargate cluster + service
│       ├── alb/                # Application Load Balancer
│       ├── asg/                # Auto Scaling policies
│       └── monitoring/         # CloudWatch + SNS alerts
├── .github/workflows/
│   └── deploy.yml              # CI/CD pipeline
├── scripts/
│   ├── push-image.sh           # Manual ECR push
│   └── deploy-infra.sh         # Terraform deploy helper
├── Dockerfile                  # Multi-stage container build
├── docker-compose.yml          # Local development
└── README.md
```

---

## 🏗️ Architecture

```
Internet
    │
    ▼
[Route 53 / DNS]
    │
    ▼
[Application Load Balancer]   ← Public Subnets (AZ-1a, AZ-1b)
    │              │
    ▼              ▼
[ECS Fargate]  [ECS Fargate]  ← Private Subnets (Auto Scaling)
                               (min: 1, desired: 2, max: 6)
[CloudWatch Logs + Dashboard + SNS Alerts]
```

### Key Components
| Component | Service | Purpose |
|-----------|---------|---------|
| Container Runtime | ECS Fargate | Serverless containers |
| Container Registry | AWS ECR | Private Docker registry |
| Load Balancer | AWS ALB | Traffic distribution, health checks |
| Networking | AWS VPC | Public/private subnet isolation |
| Scaling | App Auto Scaling | CPU/memory/request-based scaling |
| CI/CD | GitHub Actions | Automated build + deploy |
| Monitoring | CloudWatch | Logs, metrics, alarms |
| Alerting | SNS + Email | Notification on threshold breach |

---

## 🚀 How to Deploy

### Prerequisites
- AWS CLI configured (`aws configure`)
- Terraform >= 1.5
- Docker
- Node.js 18

### Step 1 — Update Configuration
Edit `terraform/terraform.tfvars`:
```hcl
alert_email = "your-email@example.com"
```

### Step 2 — Deploy Infrastructure
```bash
chmod +x scripts/*.sh
./scripts/deploy-infra.sh prod apply
```

### Step 3 — Push First Docker Image
```bash
./scripts/push-image.sh latest
```

### Step 4 — Trigger CI/CD
Push to `main` branch — GitHub Actions handles everything automatically:
```bash
git push origin main
```

### Step 5 — Access the App
```bash
# Get the ALB DNS name
cd terraform
terraform output alb_dns_name
```

---

## 🔄 CI/CD Pipeline

```
git push → main
    │
    ├─► [Test] npm test
    │
    ├─► [Build] docker build → push to ECR
    │
    └─► [Deploy] ECS rolling update (zero downtime)
```

GitHub Secrets required:
- `AWS_ACCESS_KEY_ID`
- `AWS_SECRET_ACCESS_KEY`

---

## 📊 Design Decisions

### 1. ECS Fargate (not EC2)
**Why**: No server management, automatic resource provisioning, per-task billing.  
**Trade-off**: Slightly higher cost per unit vs EC2 at very large scale.

### 2. Single NAT Gateway
**Why**: Cost savings (~$32/month per NAT GW).  
**Trade-off**: If the NAT GW AZ fails, private subnet loses internet.  
**Prod recommendation**: One NAT GW per AZ for full HA.

### 3. ALB over NLB
**Why**: Layer-7 routing, path-based rules, built-in health checks, WAF integration.  
**Trade-off**: Higher cost than NLB, but far more features needed for HTTP apps.

### 4. Modular Terraform
**Why**: Each module (vpc, ecs, alb...) is independently versioned and testable.  
**Trade-off**: More files, but much easier to maintain and extend.

### 5. GitHub Actions (not CodePipeline)
**Why**: Free for public repos, simple YAML config, huge ecosystem of Actions.  
**Trade-off**: Requires GitHub; CodePipeline stays within AWS boundary.

---

## 💰 Cost Estimate (us-east-1)

| Resource | Estimate/month |
|----------|---------------|
| ECS Fargate (2 tasks, 0.25 vCPU, 512MB) | ~$15 |
| ALB | ~$20 |
| NAT Gateway | ~$35 |
| ECR storage | ~$1 |
| CloudWatch logs + metrics | ~$3–5 |
| **Total** | **~$74–76/month** |

### Cost Optimizations Applied
- ECR lifecycle policy: keeps only last 10 images
- CloudWatch logs: 30-day retention
- Fargate Spot: can be enabled for non-prod (70% discount)
- Single NAT GW instead of per-AZ

---

## 🔐 Security Checklist

- [x] App containers in private subnets (no public IP)
- [x] ALB is the only public entry point
- [x] Security groups: ALB open to internet; app only accessible from ALB
- [x] Docker: non-root user, multi-stage build (minimal image)
- [x] ECR: image scanning on push enabled
- [x] IAM: least-privilege roles for ECS tasks
- [x] ECS deployment circuit breaker: auto-rollback on failure
- [ ] WAF on ALB (recommended for production)
- [ ] ACM certificate for HTTPS (add before prod)
- [ ] GuardDuty (recommended for threat detection)

---

## 📈 Scaling Configuration

| Trigger | Scale Out | Scale In Cooldown |
|---------|-----------|-------------------|
| CPU > 70% | +1 task | 300s |
| Memory > 80% | +1 task | 300s |
| > 1000 req/target/min | +1 task | 300s |
| Min tasks | 1 | — |
| Max tasks | 6 | — |
