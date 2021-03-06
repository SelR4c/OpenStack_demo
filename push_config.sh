#!/bin/bash -ex

# push fortigate configuration on fortigate with ansible
source demo.rc
source "$HOME/.profile"
cd ansible
./get_ip.sh # get fortigates IP
ansible-playbook FGT_WAN.yaml
ansible-playbook FGT_LAN.yaml
ansible-playbook FGT_HA.yaml

exit 0
