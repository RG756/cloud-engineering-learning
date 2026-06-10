# Private Intranet — Multi-Cloud Serverless Architecture

> A fully serverless, authentication-protected private intranet built on AWS,
> with automated multi-cloud backup to Microsoft Azure.

---

## Overview

This project demonstrates enterprise-level cloud architecture skills, including
Zero Trust security, serverless design, and multi-cloud data redundancy.
Built entirely from scratch as a portfolio project targeting cloud advisory
and PM professional roles at a Big Company.

---

## Architecture
User
└─► CloudFront (CDN + HTTPS)
└─► S3 (Static Hosting)
└─► Cognito (Auth + MFA)
└─► Private Intranet HTML
└─► Media Gallery (CloudFront URLs)
S3 Event
└─► Lambda (Node.js 22.x)
└─► Azure Blob Storage (Auto Backup)

---

## Tech Stack

| Layer | Service |
|---|---|
| CDN | AWS CloudFront |
| Storage | AWS S3 |
| Auth | AWS Cognito + MFA (TOTP) |
| Compute | AWS Lambda |
| Cloud Backup | Microsoft Azure Blob Storage |
| Runtime | Node.js 22.x |
| Library | @azure/storage-blob |

---

## Phases

### Phase 1: HTML Development
- Built a single-page application (SPA) with a multi-section dashboard
- Sections: Home, Market, Archive, Media Gallery, Career

### Phase 2: S3 Static Hosting
- Deployed HTML to S3 bucket `rgoto-private-intranet`
- Configured bucket policy for CloudFront-only access

### Phase 3: CloudFront + Cognito + MFA
- Issued HTTPS endpoint via CloudFront distribution
- Implemented Cognito User Pool with email + password authentication
- Enforced MFA using TOTP (Microsoft Authenticator)
- Frontend-based auth flow using `sessionStorage.`

### Phase 4: Multi-Cloud Backup (AWS → Azure)
- Created Azure Blob Storage account (`rgotointranet`) in Japan East
- Built a Lambda function triggered by S3 `ObjectCreated` events
- Packaged `@azure/storage-blob` as a Lambda Layer via CloudShell
- Configured environment variables for secure credential management
- Verified end-to-end sync: S3 upload → Lambda → Azure Blob Storage

### Phase 5: Media Gallery
- Added Media Gallery section to intranet HTML
- Served video/image assets via CloudFront URLs
- Leveraged existing lightbox UI for full-screen playback

---

## Security Design

- **Zero Trust**: No public access to S3 or Azure Blob Storage
- **CloudFront-only**: S3 bucket accessible only via OAC
- **MFA enforced**: TOTP-based second factor via Cognito
- **Private Blob**: Azure container configured with `Anonymous access: Disabled.`
- **Secrets management**: Azure credentials stored as Lambda environment variables

---

## Key Learnings

- Lambda@Edge Viewer Request functions **cannot make outbound HTTP calls**
  — Cognito token exchange at the edge is architecturally infeasible
- Node.js runtime version compatibility is a live constraint in Lambda environments
- Data assets (S3) require multi-cloud backup; infrastructure config can be rebuilt
- Frontend-based auth (`sessionStorage`) is a viable fallback when edge auth fails
- Private storage returning 403 is correct behavior — confirms security is working

---

## Infrastructure Details

| Resource | Value |
|---|---|
| AWS Region | `ap-northeast-1` (Tokyo) |
| Azure Region | Japan East |
| Runtime | Node.js 22.x |
| Lambda Layer | `azure-storage-blob-layer` v1 |

> Specific endpoint URLs and bucket names are omitted for security reasons.

---

## Future Enhancements
- [ ] AWS WAF integration for geo-blocking
      and web attack prevention
- [ ] CloudTrail audit logging
- [ ] Automated backup verification
