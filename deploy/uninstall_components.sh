#!/bin/bash
crtPath=$(cd "$(dirname "$0")"; pwd)

ansible-playbook action.yml -i hosts -t 'ha_uninstall' -K -k
