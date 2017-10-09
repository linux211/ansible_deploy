#!/bin/bash
umask 0077
cp  hosts hosts_common
com_inventory=hosts_common
ip_list=$(sed -rn '/^[^#].*ansible_ssh_host=(((2[0-4][0-9]|25[0-5]|[01]?[0-9][0-9]?)\.){3}(2[0-4][0-9]|25[0-5]|[01]?[0-9][0-9]?)).*/{s//\1/;p}' hosts|sort -u)

for i in $ip_list
do
    if [ `egrep -c "^[^#].*$i\>" $com_inventory` -gt 1 ];then
        for j in `sed  -n "/$i\> /="  $com_inventory|sed '$d'`
        do
            sed -i "${j}s/^/#/" $com_inventory
        done
    fi
done
