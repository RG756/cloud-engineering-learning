# linux-infrastructure-essentials
Hands-on guide to automated infrastructure provisioning via AWS CloudFormation and essential Linux system administration, focusing on secure log management and CUI-based troubleshooting.

# Linux Infrastructure Essentials: IaC & System Administration

## 1. Overview
This repository serves as a technical record of infrastructure provisioning via **AWS CloudFormation (IaC)** and deep-dive **Linux system administration**. It demonstrates the workflow from automated environment setup to hands-on troubleshooting using Command Line Interface (CLI).

## 2. Technical Milestones
### Phase 1: Automated Provisioning
* **Infrastructure as Code (IaC)**: Automated the deployment of VPC, Subnets, and EC2 instances using CloudFormation templates.
* **Network Integrity**: Configured Security Groups and Internet Gateways to ensure secure SSH access via Tera Term.

### Phase 2: System Exploration (CLI)
* **Secure Access**: Managed SSH authentication using RSA Key Pairs (`.pem`).
* **Environment Standardization**: Synchronized system clocks to JST (Japan Standard Time) for accurate log analysis.

### Phase 3: Log Forensics & Management
* **Privilege Escalation**: Mastered `sudo` and `chmod` for secure file access.
* **Log Extraction**: Located and extracted critical system logs (`/var/log/messages`) for external auditing.

---

## 3. Command Line Toolkit (CLI)
The following core utilities were utilized during the session:

| Category | Commands | Purpose |
| :--- | :--- | :--- |
| **Navigation** | `pwd`, `cd`, `ls -l` | Path verification and permission auditing. |
| **File Ops** | `cp`, `rm`, `chmod` | Evidence preservation and cleanup. |
| **Analysis** | `cat`, `tail`, `grep` | Pattern matching and real-time log tracking. |
| **System** | `timedatectl`, `history` | Environment config and audit trail review. |

---

## 4. Engineering Workflow
### Log Preservation Protocol
A secure 3-step process was executed to retrieve system logs without compromising the original file integrity:
1. **Staging**: Copy logs to a temporary directory (`/var/tmp`).
2. **Permission Adjustment**: Modify file mode (`chmod 777`) for secure SCP transfer.
3. **Exfiltration & Cleanup**: Download via Tera Term (SCP) followed by immediate file deletion (`rm`) to maintain security hygiene.

---

## 5. Architectural Reflections
- **The Power of IaC**: CloudFormation eliminates the "Human Error" factor in environment setup, ensuring a repeatable and reliable baseline.
- **CLI vs. GUI**: Realized that while GUIs are intuitive, the CLI provides the granular control and speed required for enterprise-grade troubleshooting.
- **Global Communication**: Proficiency in Linux standards is a non-negotiable skill when collaborating with international support engineers on high-stakes incidents.

---
**Status**: Completed 
**Date**: March 14, 2026
