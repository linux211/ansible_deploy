#!/bin/bash
crtPath=$(cd "$(dirname "$0")"; pwd)
if [ $1 == "health_check" -o $1 == "base_check" -o $1 == "cancel_root" -o $1 == "common" ];then
  sh unique_hosts.sh
  ansible-playbook component.yml -i hosts_common -t $1 -k -K
else
case $1 in
omm)
  ansible-playbook component.yml -i hosts -t $1 -k -K
  ansible-playbook component.yml -i hosts -t 'shubao_go_restart,silvan_restart,asgard_restart' -k -K ;;
*)
  ansible-playbook component.yml -i hosts -t $1 -k -K ;;
esac
fi
