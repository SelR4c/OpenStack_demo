# Fortinet SecDays Openstack demo

Openstack demo used for Fortinet Security Days in march 2019.
The demo creates VNF on one host with security provided by fortigates.
Number of VNF can be change in live.

# Techno used

The demo presentes fortinet's expertise with following techs:
- Heat template to build a stack in openstack
- Ansible-playbook to configure fortigate instantiated in openstack

We used bash script to connect openstack and Ansible parts by getting output from the stack.
Note that it's also possible to get all values with instances output in yaml format

# Quick Start

Download a fortigateVM image in './images' folder and name it 'fortios604.qcow2' or change the variable in requirements.sh and install.sh
Download a debian cloud-init image in './images' folder and name it 'debian.qcow2' or change the variable in requirements.sh and install.sh

Run the 3 following scripts in OpenStack_demo folder:
$ ./requirements.sh # install openstack and ansible module for fortigate
$ ./install.sh      # configure basic infra in openstack - external gateway, management network, etc.
$ ./build_stack.sh  # build the stack - ONLY THIS SCRIPT WAS PRESENTED DURING SECDAYS

# Openstack

The heat template takes two parameters: 
  - FGT_COUNT -> number of fortigate deployed
  - WS_COUNT -> number of web server deployed
The heat template and the script 'build_stack.sh' create by default 2 FGTs and 2 web servers
To update VNF number, run the following command:
  $ openstack stack update --wait --existing --parameter FGT_count=3 --parameter WS_count=3 <stack_name>

# Requirements

- A fresh install of Ubuntu 16.04 with virtualisation options
- A internet connection to download package and repo.

# Versions used

- Openstack will be install and used with QUEENS version. It's the only version tested
- Ansible in v2.7.8/2.7.9
- FortigateVM in v6.04
- 40ansible was in development during the demo, therefore same steps won't be needed after release.

# Troubleshooting

If playbooks fail, try to run it again with script ./push_config.sh. VMs can take a long time to boot.

Our Devstack host runs in esx and we encounted a strange bug when virtualization options was enabled and VMs in openstack could't boot.

# Notes

Script 'build_stack.sh' sleep for 3 min before pushing configuration with ansible.
This number can be reduce when working with a powerful/dedicated machine.

To delete a stack:
$ openstack stack delete --wait -y stack01

# Contact

Charles Prevot - cprevot@fortinet.com
Romain Schlumberger - rschlumberger@fortinet.com
