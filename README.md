# Caso Práctico 2 - Infrastructure as Code with Terraform and Ansible

![Terraform](https://img.shields.io/badge/Terraform-v1.0+-623CE4?style=flat&logo=terraform&logoColor=white)
![Ansible](https://img.shields.io/badge/Ansible-v2.9+-EE0000?style=flat&logo=ansible&logoColor=white)
![Azure](https://img.shields.io/badge/Azure-Cloud-0078D4?style=flat&logo=microsoft-azure&logoColor=white)
![Kubernetes](https://img.shields.io/badge/Kubernetes-AKS-326CE5?style=flat&logo=kubernetes&logoColor=white)
![Podman](https://img.shields.io/badge/Podman-Container-892CA0?style=flat&logo=podman&logoColor=white)
![License](https://img.shields.io/badge/License-Apache%202.0-blue.svg)
![Status](https://img.shields.io/badge/Status-Active-success)

This project implements a complete infrastructure on Azure using Terraform for resource provisioning and Ansible for automated service configuration.

## 📋 Overview

The project deploys an architecture that includes:
- **Virtual Machine** with Podman running an Nginx web server with SSL and basic authentication
- **Azure Container Registry (ACR)** to store container images
- **Azure Kubernetes Service (AKS)** with a deployed Grafana application

## 🏗️ Architecture

### Infrastructure Components (Terraform)

- **Resource Group**: Logical container for all resources
- **Virtual Network**: Virtual network with CIDR `10.0.0.0/16`
- **Subnet**: Subnet `10.0.1.0/24` for virtual machines
- **Network Security Group (NSG)** with rules for:
  - SSH (port 22)
  - HTTP (port 80)
  - HTTPS (port 443)
  - Grafana (port 3000)
- **Virtual Machine**: Ubuntu VM to run Podman containers
- **Public IP**: Public IP for VM access
- **Azure Container Registry (ACR)**: Private container registry
- **Azure Kubernetes Service (AKS)**: Kubernetes cluster with 1 node (Standard_D2_v2)

### Application Components (Ansible)

#### VM with Podman
- **Nginx Web Server**: Containerized web server with:
  - Self-signed SSL certificate
  - HTTP Basic authentication
  - Custom web page
  - Systemd unit for service management

#### AKS Cluster
- **Grafana**: Monitoring application deployed on Kubernetes
  - Accessible via LoadBalancer on port 3000

## 📁 Project Structure

```
.
├── terraform/              # Infrastructure as Code
│   ├── main.tf            # Azure provider configuration
│   ├── resources.tf       # Azure resource definitions
│   ├── vars.tf            # Input variables
│   ├── output.tf          # Deployment outputs
│   ├── terraform.tfvars   # Variable values
│   ├── apply.sh           # Automatic deployment script
│   ├── ansible_wrapper.sh # Wrapper to execute Ansible
│   └── modules/           # Terraform modules
│       ├── acr/           # Azure Container Registry
│       ├── ssh/           # SSH keys
│       ├── subnet/        # Subnet configuration
│       ├── public_ip/     # Public IP
│       └── vm/            # Virtual machine
│
└── ansible/               # Configuration and deployment
    ├── setup.yml          # Main playbook
    ├── ansible.cfg        # Ansible configuration
    ├── secrets.yml        # Sensitive variables (not versioned)
    ├── inventory/         # Dynamic inventory
    └── roles/
        └── setup/         # Main configuration role
            ├── tasks/     # Configuration tasks
            ├── templates/ # Jinja2 templates
            ├── files/     # Static files
            └── vars/      # Role variables
```

## 🚀 Prerequisites

### Required Software

- [Terraform](https://www.terraform.io/downloads.html) >= 1.0
- [Ansible](https://docs.ansible.com/ansible/latest/installation_guide/intro_installation.html) >= 2.9
- [Azure CLI](https://docs.microsoft.com/en-us/cli/azure/install-azure-cli)
- Python 3.x with modules:
  - `kubernetes>=12.0.0`
  - `PyYAML>=3.11.0`
  - `jsonpatch`

### Azure Configuration

```bash
# Login to Azure
az login

# Verify active subscription
az account show

# (Optional) Change subscription
az account set --subscription "SUBSCRIPTION_ID"
```

### SSH Keys

Make sure you have an SSH key pair generated:

```bash
# Generate SSH keys if they don't exist
ssh-keygen -t rsa -b 4096 -C "your_email@example.com"
```

## 📦 Installation and Deployment

### 1. Clone the Repository

```bash
git clone <repository-url>
cd CP2
```

### 2. Configure Variables

Edit the `terraform/terraform.tfvars` file with your values:

```hcl
location     = "France Central"  # Azure region
rg_name      = "Caso_Practico_2" # Resource Group name
public_key   = "~/.ssh/id_rsa.pub" # Path to your SSH public key
network_cidr = ["10.0.0.0/16"]
subnet_cidr  = ["10.0.1.0/24"]
```

### 3. Configure Ansible Secrets

Create the `ansible/secrets.yml` file with the necessary credentials:

```yaml
---
nginx_user_password: "your_secure_password"
```

### 4. Deploy the Infrastructure

#### Option A: Automatic Deployment (Terraform + Ansible)

```bash
cd terraform
chmod +x apply.sh
./apply.sh
```

This script will execute:
1. `terraform apply` to create the infrastructure
2. `ansible_wrapper.sh` to configure the services

#### Option B: Manual Deployment

```bash
# 1. Initialize Terraform
cd terraform
terraform init

# 2. Plan the changes
terraform plan

# 3. Apply the infrastructure
terraform apply

# 4. Run Ansible
./ansible_wrapper.sh
```

## 🔍 Deployment Verification

### Get Infrastructure Information

```bash
cd terraform

# VM public IP
terraform output podman_public_ip_address

# Container Registry URL
terraform output acr_login_server

# ACR admin username
terraform output acr_admin_username

# ACR password (sensitive)
terraform output acr_admin_password

# AKS cluster FQDN
terraform output cp2aks_host

# AKS kubeconfig (sensitive)
terraform output cp2aks_kube_config
```

### Access Nginx Web Server

```bash
# Get the public IP
VM_IP=$(terraform output -raw podman_public_ip_address)

# Access via browser
https://$VM_IP

# Or via curl (accept self-signed certificate)
curl -k -u vm_admin:your_password https://$VM_IP
```

### Access Grafana on AKS

```bash
# Configure kubectl with the AKS cluster
az aks get-credentials --resource-group Caso_Practico_2 --name cp2aks

# Verify Grafana service
kubectl get svc -n grafana

# Get the LoadBalancer external IP
kubectl get svc -n grafana -o jsonpath='{.items[0].status.loadBalancer.ingress[0].ip}'

# Access via browser (may take a few minutes to provision the IP)
http://<EXTERNAL_IP>:3000
```

## 🔧 Project Management

### View Container State on the VM

```bash
# Connect to the VM
ssh wilbert@<VM_PUBLIC_IP>

# View running containers
sudo podman ps

# View Nginx container logs
sudo podman logs nginx_web

# Restart the service
sudo systemctl restart container-nginx_web
```

### Update Configuration

If you need to make changes to the infrastructure:

```bash
cd terraform

# Modify the .tf files as needed

# Apply the changes
terraform apply

# If there are Ansible changes
./ansible_wrapper.sh
```

### Destroy Infrastructure

```bash
cd terraform

# Remove all created resources
terraform destroy

# Confirm when prompted
```

## 📝 Ansible Tasks

The Ansible playbook executes the following tasks in order:

1. **01-OSPackages.yml**: System package installation (Podman, OpenSSL, Python, etc.)
2. **02-nginx.yml**: Nginx configuration (htpasswd, HTML files, configuration)
3. **03-ssl.yml**: Self-signed SSL certificate generation
4. **04-podman.yml**: Web container build and deployment with Podman
5. **05-k8s.yml**: Grafana deployment on AKS cluster
6. **06-limpieza.yml**: Temporary file cleanup

## 🔐 Security

### Security Considerations

- **SSL Certificates**: The project uses self-signed certificates for development. For production, use certificates from a valid CA.
- **Secrets**: The `secrets.yml` file should be excluded from version control.
- **NSG**: Ports are open to the Internet. In production, restrict access to specific IPs.
- **ACR Credentials**: Admin credentials are enabled to facilitate development. In production, use Azure AD and managed identities.

### Secrets Management

```bash
# Encrypt secrets with Ansible Vault (recommended)
ansible-vault encrypt ansible/secrets.yml

# Run playbook with vault
ansible-playbook setup.yml --ask-vault-pass
```

## 🐛 Troubleshooting

### Error: VM is not accessible

```bash
# Verify the NSG
az network nsg show --resource-group Caso_Practico_2 --name cp2networksecuritygroup

# Verify the public IP
az network public-ip show --resource-group Caso_Practico_2 --name cp2podmanpubip
```

### Error: Cannot push to ACR

```bash
# Manual login to ACR
az acr login --name cp2ContainerReg

# Verify that ACR is accessible
az acr repository list --name cp2ContainerReg
```

### Error: AKS cannot pull images

The project already configures the `AcrPull` role assignment so AKS can access the ACR. If there are problems:

```bash
# Verify the role assignment
az role assignment list --scope <ACR_RESOURCE_ID>
```

## 📚 References

- [Terraform Azure Provider](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs)
- [Ansible Documentation](https://docs.ansible.com/)
- [Azure Documentation](https://docs.microsoft.com/azure/)
- [Podman Documentation](https://docs.podman.io/)
- [Kubernetes Documentation](https://kubernetes.io/docs/)

## 👤 Author

**Wilbert Iglesias**  
UNIR - DevOps and Cloud Computing Course  
2023

## 📄 License

This project is licensed under Apache License 2.0 - see the [LICENSE.md](LICENSE.md) file for details.

## 🎓 Academic Context

This project is part of **Caso Práctico 2** (Practical Case 2) from the DevOps and Cloud Computing course at Universidad Internacional de La Rioja (UNIR).

### Learning Objectives

- Provision infrastructure on Azure with Terraform
- Automate configuration with Ansible
- Work with containers (Podman)
- Deploy applications on Kubernetes (AKS)
- Integrate Azure services (ACR, VM, AKS)
- Implement Infrastructure as Code (IaC) practices
