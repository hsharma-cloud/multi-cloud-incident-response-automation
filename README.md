# Multi-Cloud Incident Response Automation

Event-driven incident response pipeline implemented using AWS services.

## Overview

This project implements an automated security response workflow where security findings trigger containment actions without manual intervention.

## Architecture

GuardDuty → EventBridge → Lambda → EC2 Isolation

## Components

- Amazon GuardDuty  
  Threat detection service that generates security findings

- Amazon EventBridge  
  Routes security events to downstream services

- AWS Lambda  
  Executes automated response actions

- Amazon CloudTrail  
  Provides logging and visibility into API activity

## Workflow

1. GuardDuty generates a security finding  
2. EventBridge captures the event  
3. Lambda function is triggered  
4. Lambda applies containment logic (e.g., isolate EC2 instance)

## Implementation Notes

- Infrastructure defined using Terraform  
- Event-driven architecture  
- Modular and extensible design  

## Status

Initial implementation complete.

Planned improvements:
- Real threat simulation (EC2-based testing)
- Enhanced event filtering
- Safer containment mechanisms
