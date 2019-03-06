#!/bin/sh

STACK='test'
FGT_OUTPUT='FGTs'
WS_OUTPUT='Web_Servers'

cd config
IP=$(openstack stack output show -f json $STACK $FGT_OUTPUT | jq '.output_value | .[][1]' | sed -e "s/^\$*/\t- /g")
echo "---\nIP:\n$IP" > fortigate_IP.yaml
IP=$(openstack stack output show -f json $STACK $WS_OUTPUT | jq '.output_value | .[][1]' | sed -e "s/^\$*/\t- /g")
echo "---\nIP:\n$IP" > web_servers_IP.yaml