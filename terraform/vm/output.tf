output "vm_admin_user" {
  value       = azurerm_linux_virtual_machine.podman_host.admin_username
  description = "virtual machine admin username"
}
