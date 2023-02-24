#!/bin/bash

# wrapper script para invocar ansible y sobreescribir los parametros 
vm_host=$(terraform output -raw podman_public_ip_address)
acrcp2_url=$(terraform output -raw acr_login_server)
acrcp2_pwd=$(terraform output -raw acr_admin_password)
acrcp2_user=$(terraform output -raw acr_admin_username)
acrcp2_kube_config=$(terraform output -raw cp2aks_kube_config)
acrcp2_k8s_fqdn=$(terraform output -raw cp2aks_host)

cd ../ansible
ansible-playbook $1 setup.yml \
    --extra-vars \
    "podman ansible_host=$vm_host \
    acrcp2_url=$acrcp2_url \
    acrcp2_pwd=$acrcp2_pwd \
    acrcp2_user=$acrcp2_user \
    acrcp2_kube_config=$acrcp2_kube_config" \
    #ak8s ansible_host=$acrcp2_k8s_fqdn"
cd -
