#!/bin/bash

crtPath=$(cd "$(dirname "$0")"; pwd)

ansible-playbook init_all_env.yml -i hosts --extra-vars "is_check_installed=true" -K  -k
