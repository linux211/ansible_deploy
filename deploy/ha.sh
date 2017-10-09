#!/bin/bash
case $2 in
install)
    ansible-playbook ha.yml -i hosts -e "ha_hosts=$1" -k -K ;;
uninstall)
    ansible-playbook ha.yml -i hosts -t 'ha_uninstall' -e "ha_hosts=$1" -k -K ;;
esac
