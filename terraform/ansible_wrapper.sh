#!/bin/bash

# wrapper script para invocar ansible y sobreescribir los parametros
vm_host=$(terraform output -raw podman_public_ip_address)
vm_admin_user=$(terraform output -raw vm_admin_user)
acrcp2_url=$(terraform output -raw acr_login_server)
acrcp2_pwd=$(terraform output -raw acr_admin_password)
acrcp2_user=$(terraform output -raw acr_admin_username)
ak8s_host=$(terraform output -raw cp2aks_host)

# Dump temporal de la configuracion de AKS
k8s_temp_conf=$(mktemp)
chmod 0600 $k8s_temp_conf
$(terraform output -raw cp2aks_kube_config >$k8s_temp_conf)

# Playbook dir
cd ../ansible
ansible-playbook $1 setup.yml \
    --extra-vars \
    "podman ansible_host=$vm_host \
    acrcp2_url=$acrcp2_url \
    acrcp2_pwd=$acrcp2_pwd \
    acrcp2_user=$acrcp2_user \
    vm_admin_user=$vm_admin_user \
    ak8s_host=$ak8s_host \
    ak8s_kube_config=$k8s_temp_conf"

# Se vuelve al directorio de terraform
cd -
# el modulo de ansible 06-limpieza.yml se encarga de eliminar las copias temporales
# de la configuracion del cluster de kubernetes (local y remota)
