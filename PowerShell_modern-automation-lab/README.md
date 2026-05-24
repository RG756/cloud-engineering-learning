# PowerShell_modern-automation-lab
Modern system automation and scripting mastery, transitioning from legacy ISE to VSCode workflows.

# Modern Automation Lab: PowerShell Mastery

## 🚀 Overview
This repository documents my journey into modern system automation, moving beyond legacy environments to embrace professional DevOps workflows. 

Following a hands-on session at **HandsonLab** (April 25, 2026), I transitioned from the traditional PowerShell ISE to a **VSCode-centric development environment**. This shift reflects a commitment to global industry standards and cross-platform scalability.

## 🛠 Project: Automated Directory & File Management
I developed a script to automate the creation and manipulation of cloud-ready workspace structures.

### Key Features:
- **Scalable Infrastructure**: Automated the generation of `folder-1` through `folder-10` within a dedicated AWS testing workspace.
- **Bulk Data Processing**: Implemented instant file renaming logic across multiple directories.
- **Cleanup Logic**: Integrated teardown procedures to maintain environmental hygiene.

### Tech Stack:
- **Language**: PowerShell 7+ (Core concepts)
- **IDE**: Visual Studio Code (VSCode)
- **Platform**: Windows / Cross-platform ready

## 🧠 Lessons Learned & Troubleshooting
- **Process Locking & File System Integrity**: During the cleanup phase, I encountered a "file in use" exception with `folder-1`. This provided a valuable opportunity to analyze process-level locks and the importance of terminal context (Current Working Directory) when executing destructive commands.
- **Manual Intervention**: Resolved the edge case via GUI to ensure environment reset, while documenting the behavior for future script hardening.

## 🔒 Security Policy
In alignment with professional security practices, this repository **intentionally omits** infrastructure diagrams and specific output logs. My philosophy is to showcase logic and methodology while maintaining a zero-footprint security posture.

---
*“Automate the mundane, engineer the exceptional.”*
