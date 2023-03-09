#!/bin/bash

terraform apply --auto-approve
if [ $? == 0 ]
then 
    ./ansible_wrapper.sh
fi