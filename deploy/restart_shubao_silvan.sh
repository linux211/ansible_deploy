#!/bin/bash
umask 0077
crtPath=$(cd "$(dirname "$0")"; pwd)

ansible-playbook restart_shubao_silvan.yml -i $crtPath/hosts -t silvan_restart,shubao_go_restart -k -K

if [ $? -ne 0 ]; then
  exit 1
fi

exit 0