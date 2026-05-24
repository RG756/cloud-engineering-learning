# aws-iam-cloudformation-lab
Automating IAM users and groups with CloudFormation YAML templates. Currently focused on IAM lifecycle management and S3 permission controls.

# AWS IAM Infrastructure as Code (IaC) Lab

## Overview
This repository documents a hands-on verification of automated IAM resource provisioning using **AWS CloudFormation**. The goal was to transition from manual console-based configurations to a declarative Infrastructure as Code (IaC) approach, ensuring environment reproducibility and operational efficiency.

## Implementation Scenarios
The CloudFormation template automates the following requirements:

1. **IAM User Group Provisioning**
   - Defined a centralized management group with `AdministratorAccess` and `AmazonS3FullAccess`.
2. **Batch User Creation**
   - Provisioned three read-only users with the `AmazonS3ReadOnlyAccess` managed policy.
3. **Privileged User Setup**
   - Configured a dedicated power user with full S3 operational permissions.
4. **Dynamic Group Membership**
   - Programmatically associated specific users with the administrative group using logical references.

## Tech Stack
- **IaC**: AWS CloudFormation (YAML)
- **Editor**: Visual Studio Code (VS Code)
- **Service**: AWS Identity and Access Management (IAM)

## Key Learnings & Engineering Insights

### 1. Logical vs. Physical IDs
Deepened understanding of the distinction between **Logical IDs** (internal template references) and **Physical IDs** (actual resource names in AWS). Leveraging `!Ref` intrinsic functions allowed for seamless resource dependency management.

### 2. Error Handling (NoSuchEntity)
Encountered and resolved `NoSuchEntity` exceptions. This reinforced the importance of resource existence checks and naming consistency when managing cross-resource dependencies in a declarative environment.

### 3. Resource Lifecycle & Idempotency
Validated the efficiency of stack deletion, ensuring a clean teardown of all associated entities. This highlighted the advantage of IaC in preventing "resource leakage" and reducing the security risks associated with orphan IAM accounts.

## Security Considerations
- Adhered to the **Principle of Least Privilege (PoLP)** by assigning specific read-only policies to standard users.
- Abstracted internal architectural diagrams to maintain security posture while documenting logical flow.
