
// TODO
// Follow https://learn.microsoft.com/en-us/azure/virtual-machines/linux/quick-create-terraform

resource "azurerm_network_interface" "podman_nic" {
  name                = "podmannic"
  location            = var.location
  resource_group_name = var.resource_group_name

  ip_configuration {
    name                          = "privip"
    subnet_id                     = var.subnet_id
    private_ip_address_allocation = "Dynamic"
  }
}

resource "azurerm_linux_virtual_machine" "podman_host" {
  name                            = var.vm_name
  location                        = var.location
  resource_group_name             = var.resource_group_name
  network_interface_ids           = var.nic_ids
  size                            = "Standard_D2s_v3"
  admin_username                  = var.admin_username
  computer_name                   = var.computer_name
  disable_password_authentication = true

  admin_ssh_key {
    username   = var.admin_username
    public_key = var.public_key
  }

  os_disk {
    name                 = var.os_disk_name
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "canonical"
    offer     = "0001-com-ubuntu-minimal-jammy"
    sku       = "minimal-22_04-lts-gen2"
    version   = "latest"
  }

}
