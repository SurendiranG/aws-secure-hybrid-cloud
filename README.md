# AWS Secure Hybrid Cloud Network

A small-office style network on AWS, connected privately to a simulated on-premises site over an IPsec Site-to-Site VPN. I built it in the console, tested each part by breaking it on purpose, and rebuilt the network layer in Terraform.

## Built in two phases to control cost

**Free phase**
- VPC, public and private subnets across two availability zones, route tables, internet gateway
- Security groups and NACLs with least-privilege rules
- IAM roles on EC2 instead of access keys
- Private S3 bucket with versioning, lifecycle rule, HTTPS-only policy and a gateway VPC endpoint
- CloudTrail, VPC Flow Logs, CloudWatch alarms and SNS email alerts
- Systems Manager patch baseline and maintenance window
- Python (boto3) audit script that checks for open SSH, public S3 buckets and IAM users without MFA

**Paid phase (deleted or stopped the same day)**
- EC2 servers: bastion, web and app
- Site-to-Site VPN with a strongSwan server and an Elastic IP

## What it shows

Network design, least-privilege access, logging and monitoring, hybrid connectivity over IPsec, and automation with Python and Terraform.

## Cost

Built and tested for under $1 (about $0.88 per Cost Explorer on 1 Nov 2026), by deleting the VPN and releasing the Elastic IP the same day and stopping servers after every session.

## Architecture

![Architecture diagram](architecture.svg)
