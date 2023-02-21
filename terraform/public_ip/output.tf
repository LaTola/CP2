output "cp2_public_ip_address" {
  value = azurerm_public_ip.cp2_public_ip.ip_address
  description = "Public IP address"
}

output "cp2_public_ip_id" {
  value = azurerm_public_ip.cp2_public_ip.id
  description = "Public IP id"
}
