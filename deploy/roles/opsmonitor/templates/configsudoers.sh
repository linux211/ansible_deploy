#!/bin/bash

umask 0077 

host_users={{monitor_excute_user}}

monitor_script={{opsmonitorscript}}

conf_file=/etc/sudoers

ntp_script=/etc/init.d/ntp
IFS=',' read -a users_array <<< "$host_users"

users_count={{'${#users_array[@]}'}}

echo $users_count

IFS=',' read -a script_array <<< "$monitor_script"

if [ $users_count -eq 0 ];then
    exit
fi

if [ $users_count -ge 2 ];then
    for i in "${!users_array[@]}";do
        sed -i "/^zabbix ALL=(${users_array[$i]})/d" $conf_file
        echo "zabbix ALL=(${users_array[$i]}) NOPASSWD:${script_array[$i]}" >> $conf_file
    done
else
    sed -i "/^zabbix ALL=(${host_users})/d" $conf_file
    echo "zabbix ALL=(${host_users}) NOPASSWD:${monitor_script}" >> $conf_file
fi

sed -i "/^zabbix ALL=(root) NOPASSWD:${ntp_script}/d" $conf_file
echo "zabbix ALL=(root) NOPASSWD:${ntp_script}" >> $conf_file
