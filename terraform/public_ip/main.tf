// Creates a public statip IP
resource "azurerm_public_ip" "cp2_public_ip" {
  name                = var.name
  resource_group_name = var.resource_group_name
  location            = var.location
  allocation_method   = "Static"
}
