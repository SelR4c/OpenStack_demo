# Fortinet SecDay Openstack demo
-------------------------------

Openstack demo used for Fortinet Security Days in march 2019.
The demo create VNF on one host with security provided by fortigates.

# Tech used
-------------------------------

The demo intended to presented fortinet's expertise with following techs:
- Heat template to build a stack in openstack
- Ansible-playbook to configure fortigate instantiated in openstack

We used bash script to connect openstack and ansible parts by getting outputs from the stack.
Note that it's also possible to get all values with instances output in yaml format

# Requirements
-------------------------------

- A fresh install of Ubuntu 16.04 with virtualisation options
- A internet connection to download package and repo.