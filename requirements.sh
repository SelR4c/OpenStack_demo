#!/bin/bash

set -ex

function valid_ip()
{
  local  ip=$1
  local  stat=1

  if [[ $ip =~ ^[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}$ ]]; then
    OIFS=$IFS
    IFS='.'
    ip=($ip)
    IFS=$OIFS
    [[ ${ip[0]} -le 255 && ${ip[1]} -le 255 \
      && ${ip[2]} -le 255 && ${ip[3]} -le 255 ]]
    stat=$?
  fi
  return $stat
}

read -p "Enter DevStack host IPv4: " -e IP
if ! valid_ip $IP; then
  echo "UNVALID IP !"
  exit 1
fi

cd ..
# latest ansible version for ubuntu/debian
sudo apt-get install -y software-properties-common
sudo apt-add-repository -y ppa:ansible/ansible

sudo apt-get update

sudo apt-get install -y git jq ansible

if [ -z 'devstack' ]; then
  git clone https://github.com/openstack-dev/devstack.git
fi
cp OpenStack_demo/local.conf ./devstack/local.conf
sed -i "s/^HOST_IP.*/HOST_IP=$IP/" ./devstack/local.conf

sudo ./devstack/tools/create-stack-user.sh

# needed to run locally (with user stack)
echo "export ANSIBLE_LIBRARY=$(pwd)/40ansible/library" >> /opt/stack/.profile

cd devstack
git checkout stable/queens # Demo was build and tested with queens only

./stack.sh

cd ..
# 40ansible
git clone https://github.com/fortinet-solutions-cse/40ansible.git --depth 1
sudo pip install fortiosapi

exit 0