output "podmanvm_private_ip" {
  value       = azurerm_network_interface.podman_nic.private_ip_address
  description = "Podman vm private IP"
}

