#!/bin/bash

# wrapper script para invocar ansible y sobreescribir los parametros 
ansible_host=$(terraform output -raw podman_public_ip_address)
acrcp2_url=$(terraform output -raw acr_login_server)
acrcp2_pwd=$(terraform output -raw acr_admin_password)
acrcp2_user=$(terraform output -raw acr_admin_username)

cd ../ansible
ansible-playbook setup.yml \
    --extra-vars \
    "podman ansible_host=$ansible_host \
    acrcp2_url=$acrcp2_url \
    acrcp2_pwd=$acrcp2_pwd \
    acrcp2_user=$acrcp2_user"
cd -
