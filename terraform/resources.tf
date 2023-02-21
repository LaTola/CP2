// This creates resource group
resource "azurerm_resource_group" "cp2_rg" {
  name     = var.rg_name
  location = var.location
}

resource "azurerm_virtual_network" "cp2_network" {
  name                = "cp2network"
  address_space       = var.network_cidr
  resource_group_name = azurerm_resource_group.cp2_rg.name
  location            = azurerm_resource_group.cp2_rg.location
}

resource "azurerm_network_security_group" "cp2_nsg" {
  name                = "cp2NetworkSecurityGroup"
  resource_group_name = azurerm_resource_group.cp2_rg.name
  location            = azurerm_resource_group.cp2_rg.location

  security_rule {
    name                       = "SSH"
    priority                   = 1001
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "HTTPS"
    priority                   = 1002
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "443"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
}

module "cp2_subnet" {
  source               = "./subnet"
  name                 = "cp2subnet1"
  resource_group_name  = azurerm_resource_group.cp2_rg.name
  virtual_network_name = azurerm_virtual_network.cp2_network.name
  cidr                 = var.subnet_cidr
}

resource "azurerm_network_interface" "cp2_podman_nic" {
  name                = "cp2nic"
  resource_group_name = azurerm_resource_group.cp2_rg.name
  location            = azurerm_resource_group.cp2_rg.location

  ip_configuration {
    name                          = "cp2network"
    subnet_id                     = module.cp2_subnet.subnet_id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = module.podman_public_ip.cp2_public_ip_id
  }
}

resource "azurerm_network_interface_security_group_association" "cp2_sg_assoc" {
  network_interface_id      = azurerm_network_interface.cp2_podman_nic.id
  network_security_group_id = azurerm_network_security_group.cp2_nsg.id
}

module "podman_vm" {
  source              = "./vm"
  resource_group_name = azurerm_resource_group.cp2_rg.name
  location            = azurerm_resource_group.cp2_rg.location
  subnet_id           = module.cp2_subnet.subnet_id
  vm_name             = "podman_vm"
  computer_name       = "podman"
  nic_ids             = [azurerm_network_interface.cp2_podman_nic.id]
  admin_username      = "wilbert"
  os_disk_name        = "os_disk"
  public_key          = module.cp2_ssh_key.ssh_key
}

// Upload SSH key to rg
module "cp2_ssh_key" {
  source              = "./ssh"
  name                = "cp2_ssh_key"
  resource_group_name = azurerm_resource_group.cp2_rg.name
  location            = azurerm_resource_group.cp2_rg.location
  public_key          = var.public_key
  // below dependency is needed because resource group takes long to be created and is prone to timeout
  depends = [azurerm_resource_group.cp2_rg.id]
}

module "create_acr" {
  source              = "./acr"
  name                = "cp2acr"
  resource_group_name = azurerm_resource_group.cp2_rg.name
  location            = azurerm_resource_group.cp2_rg.location
  sku                 = "Basic"
  admin_enabled       = true
}

module "podman_public_ip" {
  source              = "./public_ip"
  name                = "cp2podmanpubip"
  resource_group_name = azurerm_resource_group.cp2_rg.name
  location            = azurerm_resource_group.cp2_rg.location
}

module "k8s_public_ip" {
  source              = "./public_ip"
  name                = "cp2k8spubip"
  resource_group_name = azurerm_resource_group.cp2_rg.name
  location            = azurerm_resource_group.cp2_rg.location
}

resource "null_resource" "run_ansible" {
  provisioner "local-exec" {
    command = "${path.module}/ansible_wrapper.sh"
  }
  depends_on = [
    module.create_acr, 
    module.cp2_ssh_key, 
    module.podman_public_ip,
    module.podman_vm
  ]
}