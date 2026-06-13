# Multi-Cloud Incident Response Automation

## Overview

This project demonstrates automated cloud security incident response using AWS security services and Terraform.

When Amazon GuardDuty detects suspicious activity, an EventBridge rule automatically triggers an AWS Lambda function that isolates the affected EC2 instance by applying a quarantine security group.

The objective is to reduce incident response time and automate containment actions for potential security threats.

---

## Architecture

```text
Amazon GuardDuty
        ↓
Amazon EventBridge
        ↓
AWS Lambda
        ↓
EC2 Isolation (Quarantine Security Group)
```

---

## Technologies Used

* Terraform
* AWS GuardDuty
* Amazon EventBridge
* AWS Lambda
* AWS IAM
* Amazon CloudTrail
* Amazon S3

---

## Terraform Resources

### Security Monitoring

* GuardDuty Detector
* CloudTrail Trail

### Logging

* S3 Bucket for CloudTrail Logs
* S3 Bucket Policy

### Automated Response

* Lambda Function
* Lambda IAM Role
* Lambda IAM Policy

### Containment

* Quarantine Security Group

### Event Processing

* EventBridge Rule
* EventBridge Target
* Lambda Permission

---

## Automated Response Workflow

1. GuardDuty generates a security finding.
2. EventBridge captures the event.
3. Lambda is automatically invoked.
4. Lambda extracts the affected EC2 instance ID.
5. Lambda applies the quarantine security group.
6. CloudTrail records the response activity.

---

## Lambda Isolation Logic

```python
ec2.modify_instance_attribute(
    InstanceId=instance_id,
    Groups=[QUARANTINE_SG]
)
```

This action removes the instance from its existing security groups and places it into an isolated security boundary.

---

## Project Structure

```text
multi-cloud-incident-response-automation/
│
├── aws/
│   ├── main.tf
│   └── lambda/
│       ├── handler.py
│       └── lambda.zip
│
├── azure/
│
├── providers.tf
├── README.md
└── .gitignore
```

---

## Deployment Validation

The solution was successfully deployed and validated in AWS using Terraform.

Validated Components:

* GuardDuty deployment
* CloudTrail deployment
* S3 logging bucket creation
* Lambda deployment
* EventBridge integration
* Automated EC2 isolation workflow

---

## Security Concepts Demonstrated

* Incident Response Automation
* Infrastructure as Code (IaC)
* Event-Driven Security Operations
* Automated Containment
* AWS Security Services Integration
* Serverless Security Automation

---

## Future Enhancements

* Security Hub integration
* SNS notifications
* Slack notifications
* Threat simulation testing
* Azure incident response implementation
* Multi-cloud orchestration

---

## Author

**Hari Sharma**

Cloud Security | AWS | Azure | IAM | Security Automation

