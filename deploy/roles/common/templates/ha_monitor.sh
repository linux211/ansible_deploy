#!/bin/sh

source /etc/profile

######################################################################
#   FUNCTION   : getCurPath
#   DESCRIPTION: 获取该函数所在脚本的路径，并把该路径存在全局变量$PACKAGE_PATH中
#   CALLS      : 无
#   CALLED BY  : main
#   INPUT      : 无
#   OUTPUT     : PACKAGE_PATH
#   LOCAL VAR  : 无
#   USE GLOBVAR: PACKAGE_PATH   $0
#   RETURN     : 无
#   CHANGE DIR : 无
######################################################################
getCurPath()
{
    # 1.如果当前目录就是install文件所在位置，直接pwd取得绝对路径；
    # 2.而如果是从其他目录来调用install的情况，先cd到install文
    #   件所在目录,再取得install的绝对路径，并返回至原目录下。
    # 3.使用install调用该文件，使用的是当前目录路径
    if [ "` dirname "$0" `" = "" ] || [ "` dirname "$0" `" = "." ]; then
        PACKAGE_PATH="`pwd`"
    else
        cd ` dirname "$0" `
        PACKAGE_PATH="`pwd`"
        cd - > /dev/null 2>&1
    fi
    echo $PACKAGE_PATH
}

isHaSwitchover()
{
    if [ ! -e $curpath/ha_status ]; then
        echo active > $curpath/ha_status
    fi 
    ## get ha status in record
    status=`cat $curpath/ha_status` 
    ## get the current ha status
    source /etc/profile
    current_status=`QueryHaState |awk -F'=' '/LOCAL_STATE/{print $2}'`
    
    # ha switchover
    if [ x$status != x$current_status ];  then
        echo $current_status > $curpath/ha_status
        echo "HA status is not normal, active and standby switchover"
    else
        echo "HA status is normal"
    fi 
}

curpath=$(getCurPath) 


## check node type and status
checkHealth()
{
    if [ -d "/opt/onframework/ha" ] || [ -d "/opt/gaussdb" ]; then
       isHaSwitchover
    fi
    
    if [ ! -d "/opt/onframework/nginx" ] && [ ! -d "/opt/gaussdb" ];then
	   echo "The node don't involve ha monitor"
    fi
}

checkHealth
