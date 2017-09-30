#!/bin/bash
umask 0077
crtPath=$(cd "$(dirname "$0")"; pwd)

## check before upgrade
ansible-playbook oc.yml -i $crtPath/hosts -t "config_asgard_oc,asgard_restart,config_silvan_oc,silvan_restart,config_shubao_go_oc,shubao_go_restart,health_check" -K -k

if [ $? -ne 0 ]; then
   exit 1
fi
