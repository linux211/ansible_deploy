#!/bin/bash
umask 0077
crtPath=$(cd "$(dirname "$0")"; pwd)

ansible-playbook install_jdk.yml -i $crtPath/hosts -t 'install_jdk,cassandra_restart,zookeeper_restart,kafka_restart,silvan_restart,nginx_restart,asgard_restart,health_check' -K -k 
