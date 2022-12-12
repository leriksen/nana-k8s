output "id" {
  description = "Returns the resource ID of the AKS cluster."
  value       = azurerm_kubernetes_cluster.this.id
}

output "fqdn" {
  description = "Returns the FQDN (Fully Qualified Domain Name) of the AKS cluster."
  value       = azurerm_kubernetes_cluster.this.fqdn
}
output "name" {
  description = "Returns the Name of the AKS cluster."
  value       = azurerm_kubernetes_cluster.this.name
}

output "identity" {
  description = "Returns the identity of the AKS cluster."
  value       = azurerm_kubernetes_cluster.this.identity[*].principal_id
}

output "kube_admin_config" {
  description = "Returns the kube admin config of the AKS cluster. This is only available when Role Based Access Control with Azure Active Directory is enabled."
  value       = azurerm_kubernetes_cluster.this.kube_admin_config
  sensitive   = true
}

output "kube_config" {
  description = "Returns the kube config of the AKS cluster."
  value       = azurerm_kubernetes_cluster.this.kube_config
  sensitive   = true
}

output "kube_config_raw" {
  description = "Returns the raw kube config of the AKS cluster."
  value       = azurerm_kubernetes_cluster.this.kube_config_raw
  sensitive   = true
}

output "kubernetes_version" {
  description = "Returns the kubernetes version of the AKS cluster."
  value       = azurerm_kubernetes_cluster.this.kubernetes_version
}

output "kubelet_identity" {
  description = "Returns the Kubelet Identity."
  value       = azurerm_kubernetes_cluster.this.kubelet_identity
}

output "key_vault_secrets_provider" {
  description = "client id of the secret identity of the key vault secrets provider"
  value       = azurerm_kubernetes_cluster.this.key_vault_secrets_provider[0].secret_identity[0].client_id
}