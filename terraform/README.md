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