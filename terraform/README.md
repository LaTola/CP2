# Terraform Infrastructure - Azure Cloud

![Terraform](https://img.shields.io/badge/Terraform-v1.0+-623CE4?style=flat&logo=terraform&logoColor=white)
![Azure](https://img.shields.io/badge/Azure-Cloud-0078D4?style=flat&logo=microsoft-azure&logoColor=white)
![AzureRM](https://img.shields.io/badge/AzureRM-v3.45.0-0078D4?style=flat)

This Terraform configuration deploys a complete Azure infrastructure including:
- Virtual Network with security groups
- Virtual Machine with Podman support
- Azure Container Registry (ACR)
- Azure Kubernetes Service (AKS) cluster
- Public IP addresses and network interfaces

## 🏗️ Architecture Overview

The infrastructure creates:

### Networking
- **Virtual Network**: `10.0.0.0/16` CIDR block
- **Subnet**: `10.0.1.0/24` for VM resources
- **Network Security Group**: Rules for SSH (22), HTTP (80), HTTPS (443), and Grafana (3000)
- **Public IP**: Static IP address for the Podman VM

### Compute
- **Virtual Machine**: Ubuntu-based VM for running Podman containers
- **Azure Kubernetes Service**: Single-node AKS cluster (Standard_D2_v2)

### Container Services
- **Azure Container Registry**: Private registry for container images with admin access enabled
- **Role Assignment**: AKS cluster with `AcrPull` permission to access ACR

## 📋 Prerequisites

Before you begin, ensure you have:

1. **Azure CLI** installed and configured
   ```bash
   az login
   az account show
   ```

2. **Terraform** >= 1.0 installed
   ```bash
   terraform version
   ```

3. **SSH Key Pair** generated
   ```bash
   ssh-keygen -t rsa -b 4096 -C "your_email@example.com"
   ```

4. **Azure Subscription** with appropriate permissions to create resources

## 🚀 Quick Start

### 1. Initialize Terraform

```bash
cd terraform
terraform init
```

This will download the required providers and initialize the backend.

### 2. Configure Variables

Edit `terraform.tfvars` with your specific values:

```hcl
location     = "France Central"      # Azure region
rg_name      = "Caso_Practico_2"     # Resource Group name
public_key   = "~/.ssh/id_rsa.pub"   # Path to SSH public key
network_cidr = ["10.0.0.0/16"]       # Virtual network CIDR
subnet_cidr  = ["10.0.1.0/24"]       # Subnet CIDR
```

### 3. Plan the Deployment

Review the changes that will be made:

```bash
terraform plan
```

### 4. Apply the Configuration

Deploy the infrastructure:

```bash
terraform apply
```

Or use the automated script:

```bash
chmod +x apply.sh
./apply.sh
```

The `apply.sh` script will automatically run Ansible configuration after Terraform completes.

### 5. Verify the Deployment

```bash
# Get all outputs
terraform output

# Get specific values
terraform output podman_public_ip_address
terraform output acr_login_server
```

## 📁 Module Structure

```
terraform/
├── main.tf              # Provider configuration
├── resources.tf         # Main resource definitions
├── vars.tf              # Variable declarations
├── output.tf            # Output definitions
├── terraform.tfvars     # Variable values (customize this)
├── apply.sh             # Automated deployment script
├── ansible_wrapper.sh   # Ansible integration script
└── modules/
    ├── acr/             # Azure Container Registry module
    ├── ssh/             # SSH key management module
    ├── subnet/          # Subnet configuration module
    ├── public_ip/       # Public IP module
    └── vm/              # Virtual Machine module
```

## 🔧 Modules Description

### ACR Module (`./acr`)
Creates an Azure Container Registry for storing Docker/Podman images.
- Configurable SKU (Basic, Standard, Premium)
- Optional admin user enablement
- Integration with AKS via role assignments

### SSH Module (`./ssh`)
Manages SSH keys for secure VM access.
- Creates Azure SSH public key resource
- Uses provided public key path

### Subnet Module (`./subnet`)
Configures network subnetting.
- Defines subnet CIDR blocks
- Associates with virtual network

### Public IP Module (`./public_ip`)
Creates public IP addresses for external access.
- Static allocation method
- Standard SKU

### VM Module (`./vm`)
Deploys Ubuntu-based virtual machines.
- Ubuntu 20.04 LTS or newer
- Custom admin username
- SSH key authentication
- Configurable VM size

## 🔐 Security Configuration

The infrastructure implements several security measures:

### Network Security Groups
- **SSH**: Port 22 (restricted to specific IPs in production)
- **HTTP**: Port 80 for web traffic
- **HTTPS**: Port 443 for secure web traffic
- **Grafana**: Port 3000 for monitoring dashboard

### Authentication
- **VM Access**: SSH key-based authentication (no passwords)
- **ACR Access**: Admin credentials (use Azure AD in production)
- **AKS Access**: Managed identity with role-based access

## 📤 Outputs

After deployment, the following outputs are available:

| Output | Description | Usage |
|--------|-------------|-------|
| `podman_public_ip_address` | VM public IP | SSH access: `ssh user@<IP>` |
| `acr_login_server` | ACR URL | Docker/Podman login |
| `acr_admin_username` | ACR username | Container registry auth |
| `acr_admin_password` | ACR password | Container registry auth (sensitive) |
| `vm_admin_user` | VM username | SSH login |
| `cp2aks_host` | AKS FQDN | Kubernetes API endpoint |
| `cp2aks_kube_config` | Kubeconfig | kubectl configuration (sensitive) |

### Accessing Outputs

```bash
# Non-sensitive outputs
terraform output podman_public_ip_address

# Sensitive outputs (will prompt for confirmation)
terraform output acr_admin_password
terraform output cp2aks_kube_config

# Export to file
terraform output -raw cp2aks_kube_config > ~/.kube/config
```

## 🔄 Updating Infrastructure

### Modify Resources

1. Edit the relevant `.tf` files
2. Run `terraform plan` to preview changes
3. Run `terraform apply` to apply changes

### Add New Resources

1. Add resource definitions to `resources.tf` or create new `.tf` files
2. Update `vars.tf` if new variables are needed
3. Update `output.tf` for new outputs
4. Run `terraform plan` and `terraform apply`

## 🗑️ Destroying Infrastructure

To remove all created resources:

```bash
# Preview what will be destroyed
terraform plan -destroy

# Destroy all resources
terraform destroy

# Auto-approve (use with caution)
terraform destroy -auto-approve
```

**Warning**: This will permanently delete all resources and data. Make sure you have backups if needed.

## 🔍 Troubleshooting

### Common Issues

#### Error: Resource Group Already Exists
```bash
# Import existing resource group
terraform import azurerm_resource_group.cp2_rg /subscriptions/<SUBSCRIPTION_ID>/resourceGroups/<RG_NAME>
```

#### Error: SSH Key Not Found
```bash
# Verify the public key path in terraform.tfvars
cat ~/.ssh/id_rsa.pub

# Generate new key if needed
ssh-keygen -t rsa -b 4096
```

#### Error: Quota Exceeded
Check your Azure subscription quotas:
```bash
az vm list-usage --location "France Central" -o table
```

#### State Lock Issues
```bash
# Force unlock (use carefully)
terraform force-unlock <LOCK_ID>
```

### Validation

```bash
# Validate Terraform configuration
terraform validate

# Format Terraform files
terraform fmt -recursive

# Check for security issues (requires tfsec)
tfsec .
```

## 📊 Cost Estimation

Approximate monthly costs for resources (as of 2026):

| Resource | Type | Estimated Cost |
|----------|------|----------------|
| Virtual Machine | Standard_D2_v2 | ~$70-90/month |
| AKS Cluster | 1 node (Standard_D2_v2) | ~$70-90/month |
| Container Registry | Basic | ~$5/month |
| Public IP | Static | ~$3-5/month |
| Virtual Network | Standard | Minimal |
| **Total** | | **~$150-190/month** |

> **Note**: Costs vary by region and usage. Use [Azure Pricing Calculator](https://azure.microsoft.com/pricing/calculator/) for accurate estimates.

## 🔗 Integration with Ansible

After Terraform completes, use the `ansible_wrapper.sh` script to configure services:

```bash
./ansible_wrapper.sh
```

This script:
1. Extracts Terraform outputs (IPs, credentials, etc.)
2. Generates Ansible inventory
3. Runs Ansible playbooks with proper variables
4. Configures Podman containers and Kubernetes deployments

## 📚 Additional Resources

- [Terraform Azure Provider Documentation](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs)
- [Azure Virtual Machines Documentation](https://docs.microsoft.com/azure/virtual-machines/)
- [Azure Kubernetes Service Documentation](https://docs.microsoft.com/azure/aks/)
- [Azure Container Registry Documentation](https://docs.microsoft.com/azure/container-registry/)

## 🤝 Contributing

When making changes:
1. Run `terraform fmt` to format code
2. Run `terraform validate` to check syntax
3. Update this README if adding new resources or modules
4. Test in a development environment first

---

<!-- BEGIN_TF_DOCS -->
## Requirements

No requirements.

## Providers

| Name | Version |
|------|---------|
| <a name="provider_azurerm"></a> [azurerm](#provider\_azurerm) | 3.45.0 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_cp2_ssh_key"></a> [cp2\_ssh\_key](#module\_cp2\_ssh\_key) | ./ssh | n/a |
| <a name="module_cp2_subnet"></a> [cp2\_subnet](#module\_cp2\_subnet) | ./subnet | n/a |
| <a name="module_create_acr"></a> [create\_acr](#module\_create\_acr) | ./acr | n/a |
| <a name="module_podman_public_ip"></a> [podman\_public\_ip](#module\_podman\_public\_ip) | ./public_ip | n/a |
| <a name="module_podman_vm"></a> [podman\_vm](#module\_podman\_vm) | ./vm | n/a |

## Resources

| Name | Type |
|------|------|
| [azurerm_kubernetes_cluster.cp2_aks](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/kubernetes_cluster) | resource |
| [azurerm_network_interface.cp2_podman_nic](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/network_interface) | resource |
| [azurerm_network_interface_security_group_association.cp2_sg_assoc](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/network_interface_security_group_association) | resource |
| [azurerm_network_security_group.cp2_nsg](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/network_security_group) | resource |
| [azurerm_resource_group.cp2_rg](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/resource_group) | resource |
| [azurerm_role_assignment.cp2_aks_pull_acr](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/role_assignment) | resource |
| [azurerm_virtual_network.cp2_network](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/virtual_network) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_location"></a> [location](#input\_location) | n/a | `string` | n/a | yes |
| <a name="input_network_cidr"></a> [network\_cidr](#input\_network\_cidr) | n/a | `list(string)` | n/a | yes |
| <a name="input_public_key"></a> [public\_key](#input\_public\_key) | n/a | `string` | n/a | yes |
| <a name="input_rg_name"></a> [rg\_name](#input\_rg\_name) | n/a | `string` | n/a | yes |
| <a name="input_subnet_cidr"></a> [subnet\_cidr](#input\_subnet\_cidr) | n/a | `list(string)` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_acr_admin_password"></a> [acr\_admin\_password](#output\_acr\_admin\_password) | Azure Container Registry admin password |
| <a name="output_acr_admin_username"></a> [acr\_admin\_username](#output\_acr\_admin\_username) | Azure Container Registry admin user |
| <a name="output_acr_login_server"></a> [acr\_login\_server](#output\_acr\_login\_server) | Azure Container Registry login server |
| <a name="output_cp2aks_host"></a> [cp2aks\_host](#output\_cp2aks\_host) | n/a |
| <a name="output_cp2aks_kube_config"></a> [cp2aks\_kube\_config](#output\_cp2aks\_kube\_config) | n/a |
| <a name="output_podman_public_ip_address"></a> [podman\_public\_ip\_address](#output\_podman\_public\_ip\_address) | Podman VM public IP address |
| <a name="output_vm_admin_user"></a> [vm\_admin\_user](#output\_vm\_admin\_user) | Podman Virtual Machine admin user |
<!-- END_TF_DOCS -->