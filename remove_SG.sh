#!/bin/sh

set -xe

STACK='stack01'
PORT='portWAN'

PORT_ID=$(openstack stack output show -f json $STACK $PORT | \
  jq -r '.output_value' | sed -e "s/^\$*//g")
openstack port set --disable-port-security --no-security-group $PORT_ID
