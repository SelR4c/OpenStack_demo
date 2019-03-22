#!/bin/sh

set -ex

DEMO_FOLDER="$(pwd)"

cd $HOME
# latest version for ubuntu/debian
sudo apt install software-properties-common
sudo apt-add-repository ppa:ansible/ansible

sudo apt-get update

sudo apt-get install git jq ansible

# 40ansible
git clone https://github.com/fortinet-solutions-cse/40ansible.git --depth 1
sudo pip install fortiosapi
# needed to run locally
echo "export ANSIBLE_LIBRARY=$(pwd)/40ansible/library" >> ~/.bash_profile

git clone https://github.com/openstack-dev/devstack.git
cp "$DEMO_FOLDER/local.conf" ./devstack/local.conf
cd devstack
git checkout stable/queens # Demo was build and tested with queens only

exit 0