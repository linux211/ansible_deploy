#!/bin/bash
umask 0077
crtPath=$(cd "$(dirname "$0")"; pwd)

## check before upgrade
ansible-playbook component.yml -i $crtPath/hosts -t "check_var" -K -k

if [ $? -ne 0 ]; then
   exit 1
fi

ansible-playbook backup.yml -i $crtPath/hosts -k -K

if [ $? -ne 0 ]; then
   exit 1
fi

ansible-playbook upgrade.yml -i $crtPath/hosts -t 'memcached_upgrade,add_topics,silvan_upgrade,asgard_upgrade,apigateway_uninstall,tomcat_uninstall,shubao_upgrade,nginx_update,config_logrotate_log,upgrade_common_clean,config_opsmonitor' -K -k

if [ $? -ne 0 ]; then
  exit 1
fi

exit 0