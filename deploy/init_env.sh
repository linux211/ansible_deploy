#!/bin/bash
if [ $# -eq 0 ];then
  exit 1
elif [ $# -eq 1 ];then
    ansible-playbook init_env.yml -i hosts --extra-vars "target_hosts=$1 is_check_installed=true" -K -k
else
  for i in $*
  do
    sh unique_hosts.sh
    ansible-playbook init_env.yml -i hosts_common --extra-vars "target_hosts=$i is_check_installed=true" -K -k
  done
fi
