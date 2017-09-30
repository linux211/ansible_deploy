#!/bin/bash
crtPath=$(cd "$(dirname "$0")"; pwd)

ansible-playbook uninstall_dmz_nginx_ha.yml -i $crtPath/hosts -t 'ha_uninstall' -K -k