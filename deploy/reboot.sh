#!/bin/bash
get_hosts(){
src_hosts=hosts
tmp_inventory=tmp_hosts
component_list='kafka memcached asgard silvan cassandra shubao_public shubao_pod shubao_tsz shubao_nginx shubao_pod_nginx silvan_nginx'
cp $src_hosts  $tmp_inventory
for i in $component_list
do
  first_batch=$(sed -n "/\[$i\]/,/\[.*\]/{/^#/d;/ansible_ssh_host/=}" $tmp_inventory|sed -n "${1}~2p")
  if [ -n "$first_batch" ];then
    for j in $first_batch
    do
      sed -i "${j}s/^/#/" $tmp_inventory

    done
  fi
done

case $2 in 
switch)
    ansible-playbook reboot.yml  -i $tmp_inventory -t 'pre_health_check,switch_standby,nginx_restart' -k -K;;
reboot)
    ansible-playbook reboot.yml -i $tmp_inventory -t 'pre_health_check,reboot,memcached_restart,cassandra_restart,zookeeper_restart,kafka_restart,silvan_restart,nginx_restart,asgard_restart,shubao_go_restart,health_check' -k -K;;
*)
echo Usage:" get_hosts [0 switch|1 reboot|0 switch|1 reboot]"
esac
}


case $1 in
first_switch)
    get_hosts 0 switch;;
second_switch)
    get_hosts 1 switch;;
first_reboot)
    get_hosts 0 reboot;;
second_reboot)
    get_hosts 1 reboot;;
*)
shell_name=`basename $0`
echo Usage:" sh $shell_name [first_switch|first_reboot|second_switch|second_reboot]"
esac
