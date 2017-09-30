#!/bin/bash
crtPath=$(cd "$(dirname "$0")"; pwd)
ansible-playbook restore.yml -i $crtPath/hosts -K -k