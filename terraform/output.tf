// Container registry outputs
output "acr_admin_password" {
  value       = module.create_acr.acr_admin_password
  sensitive   = true
  description = "Azure Container Registry admin password"
}

output "acr_admin_username" {
  value       = module.create_acr.acr_admin_user
  description = "Azure Container Registry admin user"
}

output "acr_login_server" {
  value       = module.create_acr.acr_login_server
  description = "Azure Container Registry login server"
}

// Podman VM outputs
output "vm_admin_user" {
  value       = module.podman_vm.vm_admin_user
  description = "Podman Virtual Machine admin user"
}

output "podman_public_ip_address" {
  value       = module.podman_public_ip.cp2_public_ip_address
  description = "Podman VM public IP address"
}

// AKS outputs

output "cp2aks_host" {
  value = azurerm_kubernetes_cluster.cp2_aks.fqdn
}

output "cp2aks_kube_config" {
  value     = azurerm_kubernetes_cluster.cp2_aks.kube_config_raw
  sensitive = true
}
