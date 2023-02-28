#!/bin/bash

# Dump temporal de la configuracion de AKS
k8s_temp_conf=$(mktemp)
chmod 0600 $k8s_temp_conf
$(terraform output -raw cp2aks_kube_config >$k8s_temp_conf)

# wrapper script para invocar ansible y sobreescribir los parametros 
vm_host=$(terraform output -raw podman_public_ip_address)
acrcp2_url=$(terraform output -raw acr_login_server)
acrcp2_pwd=$(terraform output -raw acr_admin_password)
acrcp2_user=$(terraform output -raw acr_admin_username)

# Playbook dir
cd ../ansible
ansible-playbook $1 setup.yml \
    --extra-vars \
    "podman ansible_host=$vm_host \
    acrcp2_url=$acrcp2_url \
    acrcp2_pwd=$acrcp2_pwd \
    acrcp2_user=$acrcp2_user \
    ak8s_kube_config=$k8s_temp_conf"

# Se vuelve al directorio de terraform 
cd -
# el modulo 06-k8s.yml se encarga de eliminar las copias temporales 
# de la configuracion del cluster de kubernetes (local y remota)