#!/bin/bash
crtPath=$(cd "$(dirname "$0")"; pwd)

ansible-playbook uninstall_site.yml -i $crtPath/hosts -t 'shubao_go_uninstall,etl_uninstall,tomcat_uninstall,apigateway_uninstall,asgard_uninstall,kafka_uninstall,zookeeper_uninstall,cassandra_uninstall,memcached_uninstall,ha_uninstall,nginx_uninstall,silvan_uninstall,jdk_uninstall,cancel_root,common_clean' -K -k




