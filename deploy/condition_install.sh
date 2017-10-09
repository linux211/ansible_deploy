#!/bin/bash

target_hosts=$1

crtPath=$(cd "$(dirname "$0")"; pwd)
sh unique_hosts.sh
ansible-playbook condition_site.yml -i hosts_common --extra-vars "is_check_installed=true" -t 'jdk' -K  -k

ansible-playbook condition_site.yml -i hosts --extra-vars "is_check_installed=true" --skip-tag 'jdk,common' -K  -k

if [ $? -ne 0 ]; then
  exit 1
fi

# install ha

ansible-playbook component.yml -i $crtPath/hosts --extra-vars "is_check_installed=true" -t ha_nginx -k -K

if [ $? -ne 0 ]; then
  exit 1
fi

ansible-playbook condition_site.yml -i hosts_common --extra-vars "is_check_installed=true" -t 'common' -K  -k

sh install_components.sh  health_check

if [ $? -ne 0 ]; then
  exit 1
fi

exit 0
