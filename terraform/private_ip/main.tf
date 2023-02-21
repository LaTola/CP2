# Create network interface
resource "azurerm_network_interface" "cp2_priv_ip" {
  name                = var.name
  resource_group_name = var.resource_group_name
  location            = var.location

  ip_configuration {
    name                          = var.ipconfig.name
    subnet_id                     = var.ipconfig.subnet_id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = var.ipconfig.public_ip_address_id
  }
}
