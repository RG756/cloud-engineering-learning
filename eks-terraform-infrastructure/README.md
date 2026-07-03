# EKS Terraform Infrastructure

## Overview

This project provisions an Amazon EKS cluster using Terraform and demonstrates
Kubernetes autoscaling with HPA (Horizontal Pod Autoscaler).

## Architecture

- **EKS Cluster** (Kubernetes 1.31) — control plane managed by AWS
- **Node Group** — 2× t3.medium EC2 instances (auto-scaling: min 1 / max 3)
- **Nginx Deployment** — 2 Pods behind a LoadBalancer Service (ELB)
- **Metrics Server** — collects CPU/memory metrics from each Node every 15s
- **HPA** — adjusts Pod count automatically based on CPU utilization

## Autoscaling Demo

### Scale-out: CPU exceeded 30% target → Pods scaled from 2 to 4 automatically

![HPA scale out](./images/hpa-scale-out.png)

Note the AGE column: two Pods had been running for 38 minutes; two new Pods
were created 43 and 28 seconds ago — provisioned automatically by the HPA
with zero manual intervention.

### Scale-in: After stopping the load, Pods returned from 4 to 2 after a ~7-minute stabilization window

![HPA scale in](./images/hpa-scale-in.png)

The newer Pods were terminated first. This reflects the HPA design philosophy:
*scale out aggressively to protect availability, scale in conservatively to
avoid flapping.*

## Key Learnings & Pitfalls

| # | Learning | Detail |
|---|----------|--------|
| 1 | `kubectl get nodes` fails before `aws eks update-kubeconfig` | kubectl reads cluster endpoint and credentials from kubeconfig; without it, requests go to localhost:8080 and are refused |
| 2 | Metrics Server is not pre-installed on EKS | HPA reports `<unknown>` targets until Metrics Server is deployed; it must be installed explicitly before HPA can function |
| 3 | Single load generator was not enough |
