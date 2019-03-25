#!/bin/bash
#
# configure default requirements to run heat template
# 
# Authors: Charles Prevot
# Date: 25/03/2019
#

set -xe

# image to use in VM infra
IMG_FOLDER='./images'
WEB_SERVER_IMG_NAME='debian.qcow2'
FORTIGATE_IMG_NAME='fortios604.qcow2'
FORTIGATE_FLAVOR_NAME='m1.fgt'
WEB_SERVER_FLAVOR_NAME='ds512M'
INET_SUBNET='10.0.1.0/24'
WAN_SUBNET='10.10.1.0/24'
LAN_SUBNET='10.20.1.0/24'
NET01_SUBNET='10.100.1.0'
MGMT_SUBNET='192.168.99.0'
IP_FGT_WAN_INET='10.0.1.101'

# Default PRIVATE ssh key to use on all machine deployed in openstack
KEY='./default_key.pub'

# openrc

# create image on openstack
openstack image show web_server || openstack image create --public --disk-format qcow2 --container-format bare --file "$IMG_FOLDER/$WEB_SERVER_IMG_NAME" web_server
openstack image show fortigateVM_604 || openstack image create --public --disk-format qcow2 --container-format bare --file "$IMG_FOLDER/$FORTIGATE_IMG_NAME" fortigateVM_604

# flavors
openstack flavor show "$FORTIGATE_FLAVOR_NAME" || openstack flavor create "$FORTIGATE_FLAVOR_NAME" --ram 1024 --disk 2 --vcpus 1
openstack flavor show "$WEB_SERVER_FLAVOR_NAME" || openstack flavor create "$WEB_SERVER_FLAVOR_NAME" --ram 512 --disk 5 --vcpus 1

# default ssh key
if [ -r $KEY ]; then
  cp "$HOME/.ssh/id_rsa.pub" "$KEY"
fi

openstack keypair show default || openstack keypair create --public-key "$KEY" default

# Removed private network
openstack router remove subnet router1 private-subnet || echo "private-subnet interface removed from router1"
openstack router remove subnet router1 ipv6-private-subnet || echo "ipv6-private-subnet interface removed from router1"
openstack router remove subnet router1 ipv6-public-subnet || echo "ipv6-public-subnet interface removed from router1"
openstack subnet delete private-subnet || echo "private-subnet removed"
openstack network delete private || echo "private network removed"

# Create inet network with no-security-group
openstack network create --disable-port-security inet || openstack network set --disable-port-security inet
openstack subnet create --subnet-range "$INET_SUBNET/24" --no-dhcp --network inet inet-subnet || \
  openstack subnet set --no-dhcp inet-subnet

# connect router1 to inet
openstack router add subnet router1 inet-subnet
openstack router set --disable-snat --external-gateway public router1

# static route to join all networks
for route in $WAN_SUBNET $LAN_SUBNET $NET01_SUBNET; do
  openstack router set --route destination="$route",gateway="$IP_FGT_WAN_INET" router1 || echo "Static route $route may already exist on router1"
done
openstack router set --route destination=0.0.0.0/24,gateway=172.24.4.1 router1 || echo "Static route $route may already exist on router1"

# Create inet network with no-security-group
openstack network create --disable-port-security mgmt || openstack network set --disable-port-security mgmt
openstack subnet create --subnet-range "$MGMT_SUBNET/24" --dhcp --network mgmt mgmt-subnet || openstack subnet set --dhcp mgmt-subnet

openstack router create router2 || echo "Router2 may already exist"
openstack router set --external-gateway public --disable-snat router2
openstack router add subnet router2 mgmt-subnet || echo "Router2 may already be connected to managment-subnet"

IP_PUBLIC_ROUTER_WAN=$(openstack router show -f json router1 | jq -r .external_gateway_info | jq -r '.external_fixed_ips[0] | .ip_address')
IP_PUBLIC_ROUTER_MGMT=$(openstack router show -f json router2 | jq -r .external_gateway_info | jq -r '.external_fixed_ips[0] | .ip_address')

sudo route add -net "$MGMT_SUBNET" netmask 255.255.255.0 gw $IP_PUBLIC_ROUTER_MGMT dev br-ex
sudo route add -net "$INET_SUBNET" netmask 255.0.0.0 gw $IP_PUBLIC_ROUTER_WAN dev br-ex

exit 0