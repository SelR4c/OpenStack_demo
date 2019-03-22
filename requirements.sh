#!/bin/sh

set -ex

cd ..
# latest version for ubuntu/debian
sudo apt install software-properties-common
sudo apt-add-repository ppa:ansible/ansible

sudo apt-get update

sudo apt-get install git jq ansible

# 40ansible
git clone https://github.com/fortinet-solutions-cse/40ansible.git --depth 1
sudo pip install fortiosapi

git clone https://github.com/openstack-dev/devstack.git
cp OpenStack_demo/local.conf ./devstack/local.conf

sudo ./devstack/tools/create-stack-user.sh

# needed to run locally (with user stack)
echo "export ANSIBLE_LIBRARY=$(pwd)/40ansible/library" >> /home/stack/.profile

cd devstack
git checkout stable/queens # Demo was build and tested with queens only

./stack.sh

exit 0