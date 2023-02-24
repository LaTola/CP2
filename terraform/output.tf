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

output "acr_id" {
  value       = module.create_acr.acr_id
  description = "Azure Container Registry id"
}

output "acr_login_server" {
  value       = module.create_acr.acr_login_server
  description = "Azure Container Registry login server"
}

// Podman public IP outputs
output "podman_public_ip_address" {
  value       = module.podman_public_ip.cp2_public_ip_address
  description = "Podman VM public IP address"
}

output "podman_public_ip_id" {
  value       = module.podman_public_ip.cp2_public_ip_id
  description = "Podman VM public IP id"
}

# // kubernetes public IP outputs
# output "k8s_public_ip_address" {
#   value       = module.k8s_public_ip.cp2_public_ip_address
#   description = "Kubernetes Cluster public IP address"
# }

# // Kubernetes cluster public IP id
# output "k8s_public_ip_id" {
#   value       = module.k8s_public_ip.cp2_public_ip_id
#   description = "Kubernetes Cluster public IP id"
# }

# output "cp2aks_client_cert" {
#   value     = azurerm_kubernetes_cluster.cp2_aks.kube_config.0.cp2aks_client_cert
#   sensitive = true
# }

output "cp2aks_host" {
  value = azurerm_kubernetes_cluster.cp2_aks.fqdn
}

output "cp2aks_kube_config" {
  value = azurerm_kubernetes_cluster.cp2_aks.kube_config_raw
  sensitive = true
}