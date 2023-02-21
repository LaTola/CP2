// Upload public key for vm's
resource "azurerm_ssh_public_key" "cp2_ssh_key" {
  name                = var.name
  resource_group_name = var.resource_group_name
  location            = var.location
  public_key          = file(var.public_key)
  // below dependency is needed because resource group takes long to be created and is prone to fail
  depends_on = [var.depends]
}
