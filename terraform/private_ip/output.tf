output "cp2_private_ip_address" {
  value       = azurerm_network_interface.cp2_priv_ip.private_ip_address
  description = "Private IP address"
}
