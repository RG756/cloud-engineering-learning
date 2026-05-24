# serverless-s3-azure-sync-automation
An automated, event-driven multi-cloud pipeline that synchronizes S3 uploads to Azure Blob Storage in real-time, featuring instant LINE notifications for seamless mobile monitoring.

### 🚀 Automated Multi-Cloud Sync: Event-Driven S3 to Azure Pipeline

This repository features a **fully automated, serverless pipeline** designed to synchronize media assets across cloud providers. Leveraging AWS Lambda's event-driven architecture, this system ensures that any file uploaded to a specific S3 bucket is instantly mirrored to Azure Blob Storage and reported via a mobile notification.

---

### 🔥 Why This Automation Matters
Instead of manual transfers or scheduled batch jobs, this project implements a **Real-Time Event-Driven Architecture**:
*   **Zero-Touch Automation:** Triggered automatically by S3 `ObjectCreated` events.
*   **Cross-Cloud Synchronization:** Bridges AWS and Azure ecosystems efficiently.
*   **State-Aware Notifications:** Provides immediate feedback and playback access on smartphones.

---

### 🛠 Technical Deep Dive
*   **Automated Trigger:** Configured S3 Event Notifications to invoke Lambda on the `Video/` prefix.
*   **Smart Filename Handling:** Robust URL decoding logic (`urllib.parse.unquote_plus`) to handle complex file naming conventions automatically.
*   **High-Performance Streaming:** Implemented direct memory-to-cloud streaming to Azure, bypassing disk I/O for faster processing.
*   **Dynamic MIME Detection:** Automatic assignment of `video/mp4` headers during the Azure upload phase to enable instant in-browser playback.

---

### 📋 Environment Setup
To replicate this automation, set the following in your AWS Lambda Environment Variables:

| Key | Value / Purpose |
| :--- | :--- |
| `AZURE_SAS_URL` | Write-authorized SAS URL for Azure Blob Storage. |
| `AZURE_READ_SAS_URL` | Read-authorized SAS URL for secure mobile playback. |
| `LINE_ACCESS_TOKEN` | Bearer token for LINE Messaging API. |
| `LINE_USER_ID` | Targeted User ID for automated alerts. |

---

### 📈 Project Outcomes
*   **Efficiency:** Reduced media sync latency to near real-time.
*   **Reliability:** Successfully handled complex file characters (e.g., brackets/parentheses) through programmatic decoding.
*   **Scalability:** The serverless nature allows the system to handle multiple concurrent uploads without manual intervention.

---

### 🔮 Roadmap
*   [ ] **Infrastructure as Code (IaC):** Migrating manual console setups to Terraform for reproducible automation.
*   [ ] **Cost Optimization:** Automatic lifecycle rules to purge old Azure blobs after 30 days.
