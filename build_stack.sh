#!/bin/sh

set -mex

STACK_NAME='stack01'

openstack stack create --wait -t cloudInit.yml $STACK_NAME

sleep 120 # Wait for VM to boot

# remove Security Group on fortigate WAN interface
./remove_SG.sh

# push configuration on fortigate with ansible
cd ansible
./get_ip.sh
ansible-playbook FGT_WAN.yaml
ansible-playbook FGT_LAN.yaml
ansible-playbook FGT_HA.yaml

echo "Building stack complete"
IP_WebServer="$(openstack stack output show -f json $STACK_NAME IP_WebServers | jq -r '.output_value')"
echo "WebSite available at $IP_WebServer"

exit 0