# Azure SAS Viya Automation Scripts

This repository contains PowerShell runbooks to automate start and stop operations for SAS Viya environments deployed in Azure.

## 📌 Scripts Included

- **scripts/start-sas-viya.ps1**  
  Starts Azure AKS, creates a Kubernetes job from `sas-start-all` cronjob to bring up the SAS Viya instance.

- **scripts/stop-sas-viya.ps1**  
  Stops SAS Viya by triggering the `sas-stop-all` Kubernetes job, then halts the AKS cluster and optional components.

## ✅ Requirements

- Azure Automation Account with System Assigned Identity
- RBAC permissions granted to Automation Account on AKS, VMs, and Postgres (if used)
- Existing cronjobs named `sas-start-all` and `sas-stop-all` defined in the target Kubernetes namespace

## 🔧 Notes

- These scripts are designed for enterprise SAS Viya deployments managed via Azure and Kubernetes.
- Can be adapted for different environments with minor changes to resource group, cluster, or namespace names.

---

_Authored by Pablo Zambrano — Cloud & Data Engineer_
