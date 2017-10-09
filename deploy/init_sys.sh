#!/bin/bash
crtPath=$(cd "$(dirname "$0")"; pwd)

action=$1
sh unique_hosts.sh

echo $action

if [ "$action" == "init_user" ] ; then
    ansible-playbook component.yml --extra-vars "ansible_ssh_user=root" -i $crtPath/hosts_common -t initsysuser -K -k
fi

if [ "$action" == "init_disk" ] ; then
    ansible-playbook component.yml --extra-vars "ansible_ssh_user=root" -i $crtPath/hosts_common -t init_disk -K -k
fi

if [ "$action" == "init_sys" ]; then
    ansible-playbook component.yml --extra-vars "ansible_ssh_user=root" -i $crtPath/hosts_common -t init_sys -K -k
fi
