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
  name                = "cp2networksecuritygroup"
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

  security_rule {
    name                       = "HTTP"
    priority                   = 1003
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "80"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
  
  security_rule {
    name                       = "grafana-HTTP"
    priority                   = 1004
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "3000"
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
  name                = "cp2sshkey"
  resource_group_name = azurerm_resource_group.cp2_rg.name
  location            = azurerm_resource_group.cp2_rg.location
  public_key          = var.public_key
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

resource "azurerm_kubernetes_cluster" "cp2_aks" {
  name                = "cp2aks"
  resource_group_name = azurerm_resource_group.cp2_rg.name
  location            = azurerm_resource_group.cp2_rg.location
  dns_prefix          = "cp2aks"

  default_node_pool {
    name       = "default"
    node_count = 1
    vm_size    = "Standard_D2_v2"
  }

  identity {
    type = "SystemAssigned"
  }
}

resource "azurerm_role_assignment" "cp2_aks_pull_acr" {
  principal_id                     = azurerm_kubernetes_cluster.cp2_aks.kubelet_identity[0].object_id
  role_definition_name             = "AcrPull"
  scope                            = module.create_acr.acr_id
  skip_service_principal_aad_check = true
}

