# ☁️ Cloud Engineering Learning Portfolio

**Ryo Goto** · Bilingual IT Professional (Japanese / English) · Tokyo, Japan

> Transitioning from 6+ years of IT operations and cross-functional coordination at global tech companies (Quest Software, Unity Technologies) into hands-on cloud infrastructure and service delivery engineering.  
> This repository documents my self-directed learning journey — structured projects, lab work, and automation prototypes built to develop real, deployable cloud skills.

---

## 🚀 Main Projects

### Project A — Production-Grade Container Infrastructure on AWS
**Status: ✅ Completed (July 2026)**

End-to-end containerized infrastructure on AWS, built with Terraform and production-grade security in mind.

| Component | Details |
|---|---|
| IaC | Terraform |
| Compute | EC2 + EBS with KMS encryption |
| Backup & Monitoring | AWS Backup + CloudWatch |
| Containerization | Docker |
| Orchestration | EKS cluster with HPA auto-scaling |
| Registry & Deployment | ECR private registry + Helm chart |

---

### Project B — Enterprise SSO Federation
**Status: 🔄 In Progress — Phase 5: Playwright E2E Test Automation**

Configuring enterprise identity federation between Microsoft Entra ID (formerly Azure AD) and AWS Cognito using SAML 2.0, with infrastructure managed by Terraform.

| Component | Details |
|---|---|
| Identity Provider | Microsoft Entra ID |
| Service Provider | Amazon Cognito |
| Protocol | SAML 2.0 |
| IaC | Terraform |
| Current Phase | Phase 5 — Playwright end-to-end test automation: authentication flow validation, attribute mapping, and operational documentation |

**Phases completed:** Environment setup → Entra ID app configuration → Cognito integration → SAML attribute mapping → *(Phase 5 in progress)*

---

### Project C — Multi-Tier Web Infrastructure with DNS & Load Balancing on AWS
**Status: ✅ Completed (July 2026)**

Highly available, multi-AZ web infrastructure built from scratch with Terraform.

| Component | Details |
|---|---|
| IaC | Terraform |
| Network | VPC multi-AZ architecture |
| Load Balancing | ALB (Application Load Balancer) with health checks |
| DNS | Route 53 management |
| Web Servers | EC2 with Apache |
| Security | Security group design |

---

### Project D — Serverless REST API on AWS
**Status: 🔄 In Progress**

Serverless backend architecture using AWS-native services and Python.

| Component | Details |
|---|---|
| IaC | Terraform |
| API Layer | API Gateway |
| Compute | Lambda (Python) |
| Database | DynamoDB (NoSQL) |
| Security | IAM least-privilege policies |
| Observability | CloudWatch logging |

---

## 🧪 Additional Labs & Exercises

Supplementary hands-on labs covering foundational cloud, security, automation, and infrastructure topics:

| Lab | Description |
|---|---|
| [`aws-ec2-apache-handson`](./aws-ec2-apache-handson) | EC2 instance setup and Apache web server configuration |
| [`aws-ec2-live-log-monitoring`](./aws-ec2-live-log-monitoring) | Real-time log monitoring on EC2 |
| [`aws-iam-cloudformation-lab`](./aws-iam-cloudformation-lab) | IAM policy design and CloudFormation provisioning |
| [`aws-observability-foundations`](./aws-observability-foundations) | AWS monitoring and observability fundamentals |
| [`azure-iam-best-practices`](./azure-iam-best-practices) | Azure identity and access management practices |
| [`cloud-security-line-notificator`](./cloud-security-line-notificator) | Security alert notification system via LINE API |
| [`serverless-s3-azure-sync-automation`](./serverless-s3-azure-sync-automation) | Cross-cloud storage synchronization (AWS S3 ↔ Azure) |
| [`linux-infrastructure-essentials`](./linux-infrastructure-essentials) | Linux system administration and infrastructure basics |
| [`PowerShell_modern-automation-lab`](./PowerShell_modern-automation-lab) | Business process automation with PowerShell |
| [`VBA-Business-Automation-Prototype`](./VBA-Business-Automation-Prototype) | Office workflow automation prototype in VBA |

---

## 🛠️ Tech Stack

```
Cloud Platforms   AWS (VPC, EC2, EBS, EKS, ECR, Lambda, API Gateway,
                  DynamoDB, IAM, CloudFormation, CloudWatch, Cognito,
                  Route 53, ALB, KMS, AWS Backup)
                  Microsoft Azure (Entra ID, IAM, Blob/S3 sync)

Identity & Auth   SAML 2.0 · Microsoft Entra ID · Amazon Cognito

IaC & DevOps      Terraform · Docker · Kubernetes (EKS) · Helm

Testing           Playwright (E2E automation)

Languages         Python (Boto3, Lambda) · PowerShell · Bash · VBA

Monitoring        CloudWatch · Observability tooling

Notifications     LINE Messaging API · CloudWatch Alerts

CRM & Ops         Salesforce (Reports, Dashboards, UAT)
```

---

## 🌱 Learning Context

This portfolio is part of a structured self-learning program (*zeki-chan-lab*, biweekly intensive workshop series, ongoing through September 2026), complemented by community learning:

- **JAWS-UG AWS IoT Hands-on** (August 2026) — AWS IoT Core device-to-cloud connectivity; continuing independently with Raspberry Pi for full end-to-end lab completion

---

## 📬 Contact

- **Email:** rgoto.lancaster.biel@gmail.com  
- **Location:** Tokyo, Japan  
- **Languages:** Japanese (Native) · English (Business Fluent)

---

*Each project folder contains its own README with architecture diagrams, setup instructions, and learning notes.*
