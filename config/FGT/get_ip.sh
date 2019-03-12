#!/bin/sh

# name of the stack
STACK='test'

# name of outputs, specified in the OUTPUTS section of heat template
FGT_WAN='FGT_WAN'
FGT_LAN='FGT_LAN'
FGT_OUTPUT='FGTs'
WS_OUTPUT='Web_Servers'

FGT_WAN_IP=$(openstack stack output show -f json $STACK $FGT_WAN | \
  jq '.output_value | .[1]' | sed -e "s/^\$*//g")
echo "---\nIP:" > fortigate_IP.yaml
echo "  WAN: $FGT_WAN_IP" >> fortigate_IP.yaml

FGT_LAN_IP=$(openstack stack output show -f json $STACK $FGT_LAN | \
  jq '.output_value | .[1]' | sed -e "s/^\$*//g")
echo "  LAN: $FGT_LAN_IP" >> fortigate_IP.yaml

FGTs_IP=$(openstack stack output show -f json $STACK $FGT_OUTPUT | \
  jq '.output_value | .[][1]' | sed -e "s/^\$*/    - /g")
echo "  FGTs_IP:\n$FGTs_IP" >> fortigate_IP.yaml
