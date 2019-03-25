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
INET_SUBNET='10.0.1.0'
WAN_SUBNET='10.10.1.0'
LAN_SUBNET='10.20.1.0'
NET01_SUBNET='10.100.1.0'
MGMT_SUBNET='192.168.99.0'
IP_FGT_WAN_INET='10.0.1.101'

# Default PUBLIC ssh key to use on all machine deployed in openstack
KEY='./default_key.pub'

cat AUTH_URL > demo.rc
# openrc
echo "export OS_PROJECT_NAME=demo
export OS_USER_DOMAIN_NAME=Default
if [ -z \"$OS_USER_DOMAIN_NAME\" ]; then unset OS_USER_DOMAIN_NAME; fi
export OS_PROJECT_DOMAIN_ID=default
if [ -z \"$OS_PROJECT_DOMAIN_ID\" ]; then unset OS_PROJECT_DOMAIN_ID; fi
unset OS_TENANT_ID
unset OS_TENANT_NAME
export OS_USERNAME="admin"
export OS_PASSWORD="fortinet"
export OS_REGION_NAME="RegionOne"
if [ -z \"$OS_REGION_NAME\" ]; then unset OS_REGION_NAME; fi
export OS_INTERFACE=public
export OS_IDENTITY_API_VERSION=3" >> ./demo.rc

source ./demo.rc

openstack project delete alt_demo || echo "Alt_demo already deleted"

# create image on openstack
openstack image show web_server 1> /dev/null || openstack image create --public --disk-format qcow2 --container-format bare --file "$IMG_FOLDER/$WEB_SERVER_IMG_NAME" web_server
openstack image show fortigateVM_604 1> /dev/null || openstack image create --public --disk-format qcow2 --container-format bare --file "$IMG_FOLDER/$FORTIGATE_IMG_NAME" fortigateVM_604

# flavors
openstack flavor show "$FORTIGATE_FLAVOR_NAME" 1> /dev/null || openstack flavor create "$FORTIGATE_FLAVOR_NAME" --ram 1024 --disk 2 --vcpus 1
openstack flavor show "$WEB_SERVER_FLAVOR_NAME" 1> /dev/null || openstack flavor create "$WEB_SERVER_FLAVOR_NAME" --ram 512 --disk 5 --vcpus 1

# default ssh key
if [ ! -r $KEY ]; then
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
openstack network show inet || openstack network create --disable-port-security inet
openstack subnet create --subnet-range "$INET_SUBNET/24" --no-dhcp --network inet inet-subnet || \
  openstack subnet set --no-dhcp inet-subnet

# connect router1 to inet
openstack router add subnet router1 inet-subnet
openstack router set --disable-snat --external-gateway public router1

# static route to join all networks on router1
for route in $WAN_SUBNET $LAN_SUBNET $NET01_SUBNET; do
  openstack router set --route destination="$route/24",gateway="$IP_FGT_WAN_INET" router1 || echo "Static route $route may already exist on router1"
done
openstack router set --route destination=0.0.0.0/24,gateway=172.24.4.1 router1 || echo "Static route $route may already exist on router1"

# Create inet network with no-security-group
openstack network show mgmt || openstack network create --disable-port-security mgmt
openstack subnet show mgmt-subnet || openstack subnet create --subnet-range "$MGMT_SUBNET/24" --dhcp --network mgmt mgmt-subnet

# Router2 for MGMT
openstack router create router2 || echo "Router2 may already exist"
openstack router set --external-gateway public --disable-snat router2
openstack router add subnet router2 mgmt-subnet || echo "Router2 may already be connected to managment-subnet"

# add static route in DevStack host to external gateway
IP_PUBLIC_ROUTER_WAN=$(openstack router show -f json router1 | jq -r .external_gateway_info | jq -r '.external_fixed_ips[0] | .ip_address')
IP_PUBLIC_ROUTER_MGMT=$(openstack router show -f json router2 | jq -r .external_gateway_info | jq -r '.external_fixed_ips[0] | .ip_address')

sudo route add -net "$MGMT_SUBNET" netmask 255.255.255.0 gw "$IP_PUBLIC_ROUTER_MGMT" dev br-ex
sudo route add -net 10.0.0.0 netmask 255.0.0.0 gw "$IP_PUBLIC_ROUTER_WAN" dev br-ex

exit 0