#!/bin/bash

umask 0077 

config()
{
    local component="$1"
    case "$component" in
        nginx)
        sed -i '/start_nginx.sh$/d' /etc/crontab
        echo "*/{{cron_tasks.common_time}} * * * * {{cron_tasks.nginx_user}} {{cron_tasks.nginx_script}}" >> /etc/crontab
        rccron restart
        ;;
        memcached)
        sed -i '/start_memcached.sh$/d' /etc/crontab
        echo "*/{{cron_tasks.common_time}} * * * * {{cron_tasks.memcached_user}} {{cron_tasks.memcached_script}}" >> /etc/crontab
        rccron restart
        ;;
        silvan)
        sed -i '/start_silvan.sh$/d' /etc/crontab
        echo "*/{{cron_tasks.common_time}} * * * * {{cron_tasks.silvan_user}} {{cron_tasks.silvan_script}}" >> /etc/crontab
        rccron restart
        ;;
        kafka)
        sed -i '/start_kafka.sh$/d' /etc/crontab
        echo "*/{{cron_tasks.common_time}} * * * * {{cron_tasks.kafka_user}} {{cron_tasks.kafka_script}}" >> /etc/crontab
        rccron restart
        ;;
        zookeeper)
        sed -i '/start_zookeeper.sh$/d' /etc/crontab
        echo "*/{{cron_tasks.common_time}} * * * * {{cron_tasks.zookeeper_user}} {{cron_tasks.zookeeeper_script}}" >> /etc/crontab
        rccron restart
        ;;
        asgard)
        sed -i '/start_asgard.sh$/d' /etc/crontab
        echo "*/{{cron_tasks.common_time}} * * * * {{cron_tasks.asgard_user}} {{cron_tasks.asgard_script}}" >> /etc/crontab
        rccron restart
        ;;
        shubao)
        sed -i '/start_tomcat.sh$/d' /etc/crontab
        echo "*/{{cron_tasks.common_time}} * * * * {{cron_tasks.shubao_user}} {{cron_tasks.shubao_script}}" >> /etc/crontab
        rccron restart
        ;;
        consoleHome)
        sed -i '/start_tomcat.sh$/d' /etc/crontab
        echo "*/{{cron_tasks.common_time}} * * * * {{cron_tasks.console_home_user}} {{cron_tasks.console__home_script}}" >> /etc/crontab
        rccron restart
        ;;
        *)
        echo "hosts_patch_root has wrong variables about components!"
        exit 1
    esac
}

host_components={{components}}

IFS=',' read -a components_array <<< "$host_components"

components_count={{'${#components_array[@]}'}}

echo $components_count

if [ $components_count -eq 0 ];then
    exit
fi

if [ $components_count -ge 2 ];then
    for i in "${!components_array[@]}";do
        config ${components_array[$i]}
    done
else
    config $host_components
fi