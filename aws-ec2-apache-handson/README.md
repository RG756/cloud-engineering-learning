```markdown
# aws-ec2-apache-handson

Step-by-step guide to deploying an Apache web server on AWS EC2 (Amazon Linux 2023) from scratch.

## 🎯 Project Goal
To understand AWS fundamentals by building a web server from scratch on an EC2 instance and customizing its live content.

## 🏗 Architecture Overview
* **Region**: Asia Pacific (Tokyo)
* **Network**: VPC, Public Subnet, Internet Gateway
* **Security**: Security Group (Port 80 for HTTP, Port 22 for SSH)
* **Compute**: EC2 (Amazon Linux 2023)

## 🚀 Step-by-Step Execution

### 1. Infrastructure
Provisioned a VPC environment with an Internet Gateway as shown in the diagram.

### 2. Troubleshooting
Encountered an SSH connection error. Identified that Port 22 was closed in the Security Group and resolved it by adding an inbound rule.

### 3. Server Operations
Used EC2 Instance Connect to issue commands directly to the Linux OS.
Updated the web content using:
```bash
echo '<p>Let’s Go!</p>' | sudo tee /var/www/html/index.html

### 4. Verification
Confirmed the update by accessing the instance's public IP via HTTP (Port 80) in a web browser.
