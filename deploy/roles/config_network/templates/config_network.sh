#!/bin/bash

# all eth
ethernets=`ifconfig | cut -d' ' -f1 | sed '/^$/d' | sed 's/://g'`
array=(${ethernets//,/ })
local_ip=""
local_gateway=""

default_route=`netstat -rn |awk '$1=="0.0.0.0"&&$4=="UG"&&$3=="0.0.0.0"{print $NF}'`

for ethernet in ${array[@]}
do

    float_result=""
    local_gateway_result=""
    if [[ $ethernet == "eth"* ]]; then
        local_gateway=`route -n | grep "${ethernet}" | grep -w UG | awk '{print $2}'|uniq`
        local_mask=`ifconfig ${ethernet} | grep "netmask" | awk '{print $4}'`
        local_ip=`ifconfig ${ethernet} | grep "netmask" | awk '{print $2}'`
        
        if [[ $ethernet ==  $default_route ]]; then

cat << eof >/etc/sysconfig/network-scripts/ifcfg-$ethernet
TYPE=Ethernet
BOOTPROTO=static
DEFROUTE=yes
NAME=$ethernet
DEVICE=$ethernet
ONBOOT=yes
IPADDR=$local_ip
NETMASK=$local_mask
GATEWAY=$local_gateway
eof
        else 
cat <<EOF > /etc/sysconfig/network-scripts/ifcfg-$ethernet
TYPE=Ethernet
BOOTPROTO=static
DEFROUTE=no
NAME=$ethernet
DEVICE=$ethernet
ONBOOT=yes
IPADDR=$local_ip
NETMASK=$local_mask
EOF
        fi
fi
done
