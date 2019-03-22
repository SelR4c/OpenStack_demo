#!/bin/sh

set -xe

# image to use in VM infra
IMG_FOLDER='./images'
WEB_SERVER_IMG_NAME='debian.qcow2'
FORTIGATE_IMG_NAME='fortios604.qcow2'
FORTIGATE_FLAVOR_NAME='m1.fgt'
WEB_SERVER_FLAVOR_NAME='ds512M'

# Default PRIVATE ssh key to use on all machine deployed in openstack
KEY='./default_key'

# openrc

# create image on openstack
openstack image show web_server || openstack image create --public --disk-format qcow2 --container-format bare --file "$IMG_FOLDER/$WEB_SERVER_IMG_NAME" web_server
openstack image show fortigateVM_604 || openstack image create --public --disk-format qcow2 --container-format bare --file "$IMG_FOLDER/$FORTIGATE_IMG_NAME" fortigateVM_604

# flavors
openstack flavor show "$FORTIGATE_FLAVOR_NAME" || openstack flavor create "$FORTIGATE_FLAVOR_NAME" --ram 1024 --disk 2 --vcpus 1
openstack flavor show "$WEB_SERVER_FLAVOR_NAME" || openstack flavor create "$WEB_SERVER_FLAVOR_NAME" --ram 512 --disk 5 --vcpus 1

# default ssh key
if [ -r $KEY ]; then
  openstack keypair show default || openstack keypair create --private-key $KEY default
fi


exit 0