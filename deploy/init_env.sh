#!/bin/bash

target_hosts=$1

crtPath=$(cd "$(dirname "$0")"; pwd)

ansible-playbook init_env.yml -i hosts --extra-vars "target_hosts=$target_hosts is_check_installed=true" -K  -k
