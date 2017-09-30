#!/bin/bash
umask 0077
crtPath=$(cd "$(dirname "$0")"; pwd)

ansible-playbook run_role.yml -i $crtPath/hosts -e "ROLE=$1" -e "TARGETIP=$2" -K -k