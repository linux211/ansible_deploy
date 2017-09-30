#!/bin/bash
umask 0077
crtPath=$(cd "$(dirname "$0")"; pwd)

## check before upgrade
ansible-playbook component.yml -i hosts -t "config_db_backup" -k -K

if [ $? -ne 0 ]; then
   exit 1
fi
