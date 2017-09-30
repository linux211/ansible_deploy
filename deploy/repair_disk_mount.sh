#!/bin/bash

crtPath=$(cd "$(dirname "$0")"; pwd)

ansible-playbook disk.yml -i $crtPath/hosts -K -k