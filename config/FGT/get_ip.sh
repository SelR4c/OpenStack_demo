#!/bin/sh

# name of the stack
STACK='stack01'

# name of outputs, specified in the OUTPUTS section of heat template
FGT_WAN='mgmtIP_FGT_WAN'
FGT_LAN='mgmtIP_FGT_LAN'
FGT_OUTPUT='FGTs'
WS_OUTPUT='Web_Servers'
WAN_CIRD='WAN_CIDR'
LAN_CIRD='LAN_CIDR'
NET01_CIRD='NET01_CIDR'
HA_CIRD='HA_CIDR'

FGT_WAN_IP=$(openstack stack output show -f json $STACK $FGT_WAN | \
  jq '.output_value' | sed -e "s/^\$*//g")
echo "---\nIP:" > fortigate_IP.yaml
echo "  WAN: $FGT_WAN_IP" >> fortigate_IP.yaml

FGT_LAN_IP=$(openstack stack output show -f json $STACK $FGT_LAN | \
  jq '.output_value' | sed -e "s/^\$*//g")
echo "  LAN: $FGT_LAN_IP" >> fortigate_IP.yaml

FGTs_IP=$(openstack stack output show -f json $STACK $FGT_OUTPUT | \
  jq '.output_value | .[][1]' | sed -e "s/^\$*/    - /g")
echo "  FGTs_HA:\n$FGTs_IP" >> fortigate_IP.yaml

echo "CIDR:" >> fortigate_IP.yaml
CIDR=$(openstack stack output show -f json $STACK $WAN_CIRD | \
  jq '.output_value' | sed -e "s/^\$*//g")
echo "  WAN: $CIDR" >> fortigate_IP.yaml

CIDR=$(openstack stack output show -f json $STACK $LAN_CIRD | \
  jq '.output_value' | sed -e "s/^\$*//g")
echo "  LAN: $CIDR" >> fortigate_IP.yaml

CIDR=$(openstack stack output show -f json $STACK $NET01_CIRD | \
  jq '.output_value' | sed -e "s/^\$*//g")
echo "  NET01: $CIDR" >> fortigate_IP.yaml

CIDR=$(openstack stack output show -f json $STACK $HA_CIRD | \
  jq '.output_value' | sed -e "s/^\$*//g")
echo "  HA: $CIDR" >> fortigate_IP.yaml
