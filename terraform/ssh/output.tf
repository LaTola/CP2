output "ssh_key" {
  value       = azurerm_ssh_public_key.cp2_ssh_key.public_key
  description = "Public Key"
}
