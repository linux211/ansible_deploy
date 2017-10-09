#!/bin/bash
crtPath=$(cd "$(dirname "$0")"; pwd)

export ANSIBLE_GATHERING=explicit

ansible-playbook uninstall_site.yml -i $crtPath/hosts -t 'omm_uninstall' -K -k
ansible-playbook component.yml -i hosts -t 'shubao_go_restart,silvan_restart,asgard_restart' -k -K
