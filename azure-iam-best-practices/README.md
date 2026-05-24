# azure-iam-best-practices
Secure Azure environment setup implementing Least Privilege for upcoming workshops.

# 🚀 Azure Hands-on Environment Setup: IAM Best Practices

## Overview
This repository documents the secure setup of an Azure environment for a hands-on workshop. Following industry-standard **Least Privilege** principles, I have separated administrative duties from daily operational tasks by implementing a dedicated workload identity.

---

## 🛡️ Security Architecture: "Separation of Duties"
Instead of using the Root (Account Administrator) credentials for active resource deployment, I architected a dual-account structure similar to AWS IAM best practices:

### 1. Administrative Tier (Root)
* **Scope**: Used exclusively for billing management and high-level identity governance.
* **Role**: Holds the `Owner` role.
* **Access**: Minimal usage to ensure the security of the billing account.

### 2. Workload Tier (Operational)
* **Identity**: Dedicated Entra ID user (following the naming convention: `[workload]-[environment]-user`).
* **Role**: Assigned the **`Contributor`** (RBAC) role at the subscription scope.
* **Key Decision**: This role grants full access to manage resources (Compute, AI, Storage) while explicitly denying permissions to modify IAM policies or share image galleries, effectively minimizing the attack surface.

---

## 🛠️ Key Technical Milestones

* **Identity Provisioning**: Successfully provisioned a new Entra ID identity within the tenant, following standardized internal naming policies.
* **Role-Based Access Control (RBAC)**: Navigated the "Privileged Administrator" role tier to assign the **Contributor** role, ensuring full resource management capabilities for the upcoming workshop.
* **Validation**: Verified the workload identity's ability to initialize **Resource Groups** and access subscription resources via an isolated session (InPrivate/Incognito), confirming zero-trust connectivity and successful privilege inheritance.

---

## 💡 Why this matters for the Business
By implementing this structure, I ensured:

* **Auditability**: Clear separation between billing actions and infrastructure changes.
* **Security**: Protection of the root account from potential credential exposure during the workshop.
* **Scalability**: A repeatable, policy-driven pattern for onboarding additional engineers or automated service principals in a corporate environment.

---
> **Note**: For security reasons, all specific identifiers, Subscription IDs, and Tenant IDs have been redacted or abstracted.
