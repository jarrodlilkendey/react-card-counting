# Infrastructure as Code

## Overview

- Manage the Terraform state within AWS S3
- Deploy the website to S3, setup CloudFront for TLS termination and as a CDN to pull the website from S3
- Setup domain in CloudFlare and point the domain directly to CloudFront distribution (no CloudFlare monitoring/caching)
- Setup TLS certificate and automate renewals in Amazon Cert Manager
- Setup AWS Lambda as a backend to handle contact us form fills and send them to a mailbox with SES
