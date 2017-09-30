#!/bin/bash
crtPath=$(cd "$(dirname "$0")"; pwd)
ansible-playbook stop.yml -i $crtPath/hosts -t 'stop_shubao,stop_asgard,stop_memcached,stop_ha,stop_kafka,stop_zookeeper' -k -K

