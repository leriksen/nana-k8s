# Azure Kubernetes service

## Introduction
Provisions an Azure Kubernetes cluster
https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/kubernetes_cluster

### Dependencies

This component depends on the following resources :

- Resource group
- Subnet to be attached to Azure Kubernetes Services
- Private DNS zone ID
- Azure Container Registry ID
- AD Groups to be assigned to Namespace Role Bindings
