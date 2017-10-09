#!/bin/bash
#### 
current_time=`date +%F" "%T`
dev_name="eth0" ### 首先查看网卡名称是否为eth0
log_file="/tmp/monitor_network.log"
remote_ip="{{hostvars[groups.kafka.0].ansible_ssh_host}}  {{hostvars[groups.kafka.1].ansible_ssh_host}}" #### 根据实际情况配置可为kafka节点IP
lcoal_ip="{{ansible_ssh_host}}"
####
function check_network()
{
eth0_ip=`/sbin/ifconfig  | grep ${dev_name} -A1 | grep inet | awk '{print $2}' | cut -d / -f 1`
for ips in ${remote_ip}
do 
	echo > /dev/tcp/${ips}/2181 > /dev/null 
	if [ $? -eq 0 ];then
		zookeeper_port_tag="ok"
		break
	fi
done 
	if [ "$eth0_ip" = "$lcoal_ip" -a "${zookeeper_port_tag}" = "ok" ] ;then
			status="success"
	else
			status="failed"
	fi
}

function truncate_log()
{
	lines=`cat ${log_file} | wc -l`
	seven_days=`expr 60 \* 24 \* 7`
	if [ $lines -gt ${seven_days} ];then
		sed -i '1,1440d' ${log_file}
	fi
}
truncate_log
check_network 

if [ "${status}" = "success" ];then
	echo "[ $current_time ] - status: ${status} - ip: ${eth0_ip} nothing to do!" >> ${log_file}
	exit 0
elif [ "${status}" = "failed" ];then
	echo "[ $current_time ] - status: ${status} - ip: ${eth0_ip} network is not ok!" >> ${log_file}
	systemctl restart network
	sleep 5
	check_network
	if [ "${status}" = "success" ];then
		echo "[ $current_time ] - status: ${status} - ip: ${eth0_ip} network restart success!" >> ${log_file}
	else
		echo "[ $current_time ] - status: ${status} - ip: ${eth0_ip} network restart failed!" >> ${log_file}
	fi
fi

