#!/bin/bash

target_hosts=$1

crtPath=$(cd "$(dirname "$0")"; pwd)

sh unique_hosts.sh

ansible-playbook init_user.yml -i hosts_common --extra-vars "target_hosts=$target_hosts is_check_installed=true" -K  -k
