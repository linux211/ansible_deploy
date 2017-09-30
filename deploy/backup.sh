#!/bin/bash
crtPath=$(cd "$(dirname "$0")"; pwd)
ansible-playbook backup.yml -i $crtPath/hosts -k -K
