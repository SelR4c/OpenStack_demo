#!/bin/bash
#
# Bash script to create SecDays demo in openstack
# Authors: Charles Prevot
# Date: 25/03/2019
#

set -mex

STACK_NAME='stack01'

source demo.rc
openstack stack create --wait -t cloudInit.yaml $STACK_NAME

sleep 120 # Wait for VM to boot

# remove Security Group on fortigate WAN interface
# ./remove_SG.sh

# push fortigate configuration on fortigate with ansible
cd ansible
./get_ip.sh # get fortigates IP
ansible-playbook FGT_WAN.yaml
ansible-playbook FGT_LAN.yaml
ansible-playbook FGT_HA.yaml

echo "Building stack complete"
IP_WebServer="$(openstack stack output show -f json $STACK_NAME IP_WebServers | jq -r '.output_value')"
echo "WebSite available at $IP_WebServer"

exit 0