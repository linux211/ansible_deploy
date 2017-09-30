#!/bin/bash
crtPath=$(cd "$(dirname "$0")"; pwd)

ansible-playbook component.yml -i hosts -t $1 -k -K
