#!/bin/sh

set -ex

openstack stack create --wait -t cloudInit.yml stack01
sleep 120 # Wait for VM to boot
./remove_SG.sh
cd ansible
./get_ip.sh
ansible-playbook FGT_WAN.yaml
ansible-playbook FGT_LAN.yaml
ansible-playbook FGT_HA.yaml

echo "Building stack complete"