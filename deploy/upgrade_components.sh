#!/bin/bash
umask 0077
crtPath=$(cd "$(dirname "$0")"; pwd)

upgrade_ha () {
    ansible-playbook component.yml -i hosts -t upgrade_ha  -k -K
    ansible-playbook component.yml -i hosts -t upgrade_ha --skip-tag 'switch_standby' -k -K
}

upgrade_jdk () {
sh unique_hosts.sh
if [ $? -ne 0 ]; then
    exit 1
fi
    ansible-playbook install_jdk.yml -i $crtPath/hosts_common -t 'install_jdk,cassandra_restart,zookeeper_restart,kafka_restart,silvan_restart,nginx_restart,asgard_restart,health_check' -K -k
}
case $1 in
upgrade_ha)
    upgrade_ha ;;
upgrade_jdk)
    upgrade_jdk ;;
esac
