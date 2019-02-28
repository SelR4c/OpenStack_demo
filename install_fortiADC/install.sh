#! /bin/bash 
# This script follow doc provided in the link
# https://s3.amazonaws.com/fortinetweb/docs.fortinet.com/v2/attachments/84b7eff3-2436-11e9-b20a-f8bc1258b856/fortiadc-openstack_integration_guide.pdf

# file required
# https://info.fortinet.com/files/FortiADC/v5.00/images/build0430/
$FILENAME="fortiadc_lbaasv2.tar.gz"
set -e

cp $FILENAME /tmp/.
cd /tmp
tar -zxvf $FILENAME
sudo cp -r /tmp/fortiadc_lbaasv2/fortinet /opt/stack/neutron-lbaas/neutron_lbaas/drivers/ 
cd /tmp/fortiadc_lbaasv2/fortinet_neutron_lbaas
sudo pip install .
# sed -i '/service_provider[ |=]/d' /etc/neutron/neutron_lbaas.conf
# sed -i '/\[service_providers\]/a service_provider=LOADBALANCERV2:Fortinet:neutron_lbaas.drivers.fortinet.driver_v2.PearlMilkTeaDriver:default' /etc/neutron/neutron_lbaas.conf
# sudo systemctl restart devstack@q-svc.service 
