#!/bin/bash
crtPath=$(cd "$(dirname "$0")"; pwd)

sh unique_hosts.sh

# install the common(jdk,ntp,dns,common)
ansible-playbook component.yml -i $crtPath/hosts_common -t common_install -K -k

if [ $? -ne 0 ]; then
  exit 1
fi

ansible-playbook component.yml -i $crtPath/hosts -t get_zk_ip_addr -k -K

# install component
ansible-playbook site.yml -i $crtPath/hosts  -K -k

if [ $? -ne 0 ]; then
  exit 1
fi

#clean the operation and health check
ansible-playbook component.yml -i $crtPath/hosts_common -t post_common_clean,health_check -k -K

if [ $? -ne 0 ]; then
  exit 1
fi

exit 0
