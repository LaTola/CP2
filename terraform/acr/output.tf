
output "acr_admin_password" {
  value       = azurerm_container_registry.cp2_acr.admin_password
  sensitive   = true
  description = "Azure Container Registry admin password"
}

output "acr_admin_user" {
  value       = azurerm_container_registry.cp2_acr.admin_username
  description = "Azure Container Registry admin user name"
}

output "acr_id" {
  value       = azurerm_container_registry.cp2_acr.id
  description = "Azure Container Registry id"
}

output "acr_login_server" {
  value       = azurerm_container_registry.cp2_acr.login_server
  description = "Azure Container Registry login server"
}
