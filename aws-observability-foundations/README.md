# aws-observability-foundations
Implementation of automated monitoring and alerting pipelines using Amazon CloudWatch and SNS. Focused on ensuring infrastructure stability and operational excellence for EC2 environments.

# AWS Observability Foundations: CloudWatch Monitoring

## 1. Overview
Infrastructure reliability is defined by its **"Stable Operation"** post-deployment. This repository documents a technical hands-on focused on mastering **Amazon CloudWatch**, the cornerstone of AWS observability. The objective was to transition from reactive troubleshooting to proactive infrastructure management.

## 2. Core Objectives
* **Health Monitoring**: Implementation of real-time status checks to minimize MTTR (Mean Time To Repair).
* **Resource Visualization**: Quantitative analysis of compute metrics to prevent performance degradation.
* **Incident Automation**: Decoupling human intervention from anomaly detection via automated alerting.

## 3. Technical Stack
### Infrastructure
- **Provider**: AWS (Amazon Web Services)
- **Service**: Amazon EC2
- **OS**: Amazon Linux 2

### Monitoring Suite
- **Engine**: Amazon CloudWatch
- **Logic**: CloudWatch Alarms
- **Transport**: Amazon SNS (Simple Notification Service)

---

## 4. Implementation Details

### 4.1 Metric Selection & Thresholds
The following KPIs (Key Performance Indicators) were selected for monitoring:

| Metric | Condition | Logic |
| :--- | :--- | :--- |
| `CPUUtilization` | Critical Load | `> 80% for 5 minutes` |
| `StatusCheckFailed` | Instance Failure | `Any value > 0` |

### 4.2 Notification Pipeline
To ensure high availability of alerts, an asynchronous notification flow was established:
```text
[ CloudWatch Metric ] -> [ Alarm Trigger ] -> [ SNS Topic ] -> [ Admin Email ]
