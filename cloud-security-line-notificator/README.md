# cloud-security-line-notificator
Hybrid cloud pipeline for real-time security video sync and LINE notifications via AWS, Azure, and Python.

# 🎥 Home Security Video Automation Pipeline
### ~ Real-time Cloud-to-Mobile Notification Architecture ~

## 📝 Executive Summary
This project implements a seamless, serverless pipeline that detects motion-triggered videos on **AWS S3**, synchronizes them to **Azure Blob Storage**, and delivers instant, playable notifications via the **LINE Messaging API**.

The architecture focuses on three core pillars: **Zero-Trust Security**, **Optimized User Experience (UX)**, and **Future-Proof Engineering**.

## 🏗️ System Architecture
A robust hybrid-cloud orchestration leveraging AWS and Azure.
![System Architecture](System%20Architecture_%20Home%20Security%20Video%20Pipeline.png)

1.  **Detection (AWS)**: Surveillance cameras upload motion-triggered MP4 files to an encrypted S3 bucket.
2.  **Orchestration (Python/Colab)**: A Python-based engine identifies the latest assets and executes cross-cloud data transfer.
3.  **Delivery (Azure)**: The system dynamically generates time-limited **Shared Access Signature (SAS)** URLs.
4.  **Notification (LINE)**: Integration with the Messaging API delivers a rich push notification.

## 🛠️ Technical Implementation & Problem Solving

### 1. Security First: Zero-Footprint Credential Management
Instead of hardcoding sensitive credentials, I implemented an externalized secrets management strategy using Google Colab’s `userdata`.
* **Architect’s Perspective**: Decoupled authentication from the codebase to ensure zero risk of credential leakage during public repository deployment.

### 2. UX Optimization: Seamless Inline Playback
I resolved the browser download friction point through metadata manipulation.
* **Engineer’s Perspective**: Controlled the **Blob Metadata** (`Content-Type: video/mp4`) and **SAS properties** (`Content-Disposition: inline`).
* **PM’s Perspective**: Focused on **"Zero-Click Latency"**—ensuring immediate playback within one tap.

### 3. Modernization: Migration to Messaging API
Successfully bypassed the deprecated "LINE Notify" in favor of the more robust **LINE Messaging API**.
* **Architect’s Perspective**: Prioritized long-term maintainability by adopting industry-standard endpoints.
<p align="center">
  <img src="Push%20Notification%20output%20on%20LINE.png" width="300px">
</p>

## 📂 Future Roadmap
- [ ] **Event-Driven Execution**: Transitioning to **AWS Lambda** for real-time handling.
- [ ] **Lifecycle Optimization**: Automating TTL policies on Azure for cost efficiency.

## ✒️ Author
**Ryo Goto** *IT Operations & Project Management Professional* *Bridging the gap between Psychology and Technology to lead organizational DX.*
