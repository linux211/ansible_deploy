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

ansible-playbook upgrade.yml -i $crtPath/hosts -t 'memcached_upgrade,add_topics,silvan_upgrade,asgard_upgrade,apigateway_uninstall,tomcat_uninstall,shubao_upgrade,nginx_update,cassandra_upgrade' -K -k

if [ $? -ne 0 ]; then
exit 1
fi


sh unique_hosts.sh
ansible-playbook component.yml -i $crtPath/hosts_common -t 'post_common,upgrade_common_clean' -k -K


exit 0
