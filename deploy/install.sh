#!/bin/bash
crtPath=$(cd "$(dirname "$0")"; pwd)

echo 'Please enter the ssh user and root password successively in the next two rows.'

ansible-playbook component.yml -i $crtPath/hosts -t get_zk_ip_addr -k -K

if [ $? -ne 0 ]; then
  exit 1
fi

ansible-playbook site.yml -i $crtPath/hosts  -K -k

if [ $? -ne 0 ]; then
  exit 1
fi

# install ha
ansible-playbook component.yml -i $crtPath/hosts -t ha_info_shubao -k -K

if [ $? -ne 0 ]; then
  exit 1
fi

ansible-playbook component.yml -i $crtPath/hosts -t ha_nginx_shubao -k -K

ansible-playbook component.yml -i $crtPath/hosts -t ha_info_silvan -k -K
if [ $? -ne 0 ]; then
  exit 1
fi
ansible-playbook component.yml -i $crtPath/hosts -t ha_nginx_silvan -k -K

ansible-playbook component.yml -i $crtPath/hosts -t ha_info_pod_shubao -k -K

if [ $? -ne 0 ]; then
  exit 1
fi

ansible-playbook component.yml -i $crtPath/hosts -t ha_nginx_pod_shubao -k -K

if [ $? -ne 0 ]; then
  exit 1
fi

ansible-playbook component.yml -i $crtPath/hosts -t health_check -k -K

if [ $? -ne 0 ]; then
  exit 1
fi

exit 0
