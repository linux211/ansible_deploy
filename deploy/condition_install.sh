#!/bin/bash

target_hosts=$1

crtPath=$(cd "$(dirname "$0")"; pwd)

ansible-playbook condition_site.yml -i hosts --extra-vars "is_check_installed=true" -K  -k


if [ $? -ne 0 ]; then
  exit 1
fi

# install ha
ansible-playbook component.yml -i $crtPath/hosts --extra-vars "is_check_installed=true" -t ha_info_shubao -k -K

if [ $? -ne 0 ]; then
  exit 1
fi

ansible-playbook component.yml -i $crtPath/hosts --extra-vars "is_check_installed=true" -t ha_nginx_shubao -k -K

ansible-playbook component.yml -i $crtPath/hosts --extra-vars "is_check_installed=true" -t ha_info_silvan -k -K

if [ $? -ne 0 ]; then
  exit 1
fi

ansible-playbook component.yml -i $crtPath/hosts --extra-vars "is_check_installed=true" -t ha_nginx_silvan -k -K

ansible-playbook component.yml -i $crtPath/hosts --extra-vars "is_check_installed=true" -t ha_info_pod_shubao -k -K

if [ $? -ne 0 ]; then
  exit 1
fi

ansible-playbook component.yml -i $crtPath/hosts --extra-vars "is_check_installed=true" -t ha_nginx_pod_shubao -k -K

if [ $? -ne 0 ]; then
  exit 1
fi

ansible-playbook component.yml -i $crtPath/hosts  -t health_check -k -K

if [ $? -ne 0 ]; then
  exit 1
fi

exit 0
