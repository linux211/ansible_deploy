#!/bin/bash

umask 0077 

declare -r scriptName=$(basename "${BASH_SOURCE}")
alias LOG_INFO='echoMessage [INFO] [${scriptName} ${LINENO}] '
alias LOG_WARN='echoMessage [WARN] [${scriptName} ${LINENO}] '
alias LOG_ERROR='echoMessage [ERROR] [${scriptName} ${LINENO}] '
shopt -s expand_aliases

# 需要绑定的机器ip
localip={{ansible_ssh_host}}

# NTPSERVERIP
NTPSERVERIP={{common.NTP_SERVER}}

# nameserver
DNSERVERIP={{common.DNS_SERVER}}

LOGGER_PATH_FOLDER=/var/log/initsysconfig
LOGGER_FILE=initsysconfig.log

# 设定文件开启最大数
file_limits=65535

######################################################################
#   FUNCTION   : configsshAllow
#   DESCRIPTION: config ssh allow user
#   CALLS      : 无
#   CALLED BY  : main
#   INPUT      : 无
#   OUTPUT     : 无
#   LOCAL VAR  : sshfile
#   RETURN     : 无
#   CHANGE DIR : 无
######################################################################
configsshAllow(){
    local sshfile=/etc/ssh/sshd_config
    sed -i "/AllowGroups/d" $sshfile
    echo "AllowGroups {{ansible_ssh_user}} {{common.opsmonitor_user}}" >>$sshfile
    sed -i "/AllowUsers/d" $sshfile
    echo "AllowUsers {{ansible_ssh_user}} {{common.opsmonitor_user}}" >>$sshfile
	sed -ri "s#(\#PermitRootLogin yes)(.*)#PermitRootLogin without-password#" $sshfile
}

######################################################################
#   FUNCTION   : bindssh
#   DESCRIPTION: 绑定ssh到指定IP
#   CALLS      : 无
#   CALLED BY  : main
#   INPUT      : 无
#   OUTPUT     : 无
#   LOCAL VAR  : sshfile
#   RETURN     : 无
#   CHANGE DIR : 无
######################################################################
bindssh(){
    # ssh配置文件(系统文件)
    local sshfile=/etc/ssh/sshd_config
    LOG_INFO "start to config the sshd file."
    # 修改配置文件
    sed -ri "s#(\#ListenAddress 0.0.0.0)(.*)#ListenAddress $localip#" $sshfile

    # 重启ssh服务
    service sshd restart
}

######################################################################
#   FUNCTION   : closerpc
#   DESCRIPTION: 关闭rpc无用端口
#   CALLS      : 无
#   CALLED BY  : main
#   INPUT      : 无
#   OUTPUT     : 无
#   RETURN     : 无
#   CHANGE DIR : 无
######################################################################
closerpc(){
    LOG_INFO "start to close the rpc."
    service rpcbind stop
    chkconfig rpcbind off
}

######################################################################
#  FUNCTION     : ntpupdate
#  DESCRIPTION  : 时间同步ntp
#  CALLS        : 无
#  CALLED BY    : 任何需要调用此函数的地方
#  INPUT        : 无
#  OUTPUT       : 无
#  READ GLOBVAR : 无
#  WRITE GLOBVAR: 无
#  RETURN       :   0   成功
#                   1   失败
######################################################################

ntpupdate(){
    confile=/etc/ntp.conf
    if [ x"${NTPSERVERIP}" != x ]; then
	    sed -i "/server ${NTPSERVERIP} prefer/d" $confile
	    echo "server ${NTPSERVERIP} prefer">> $confile
        service ntp restart
        chkconfig on
	fi
}

######################################################################
#  FUNCTION     : set_file_limiit
#  DESCRIPTION  : 修改文件最大开启数
#  CALLS        : 无
#  CALLED BY    : 任何需要调用此函数的地方
#  INPUT        : 无
#  OUTPUT       : 无
#  READ GLOBVAR : 无
#  WRITE GLOBVAR: 无
#  RETURN       :   0   成功
#                   1   失败
######################################################################

set_file_limit(){
    limits_conf_file=/etc/security/limits.conf
    sed -i "/* soft nofile/d" $limits_conf_file
    echo "* soft nofile $file_limits" >>$limits_conf_file
    sed -i "/* hard nofile/d" $limits_conf_file
    echo "* hard nofile $file_limits" >>$limits_conf_file
    ulimit -n $file_limits
}

set_dns(){

    dns=/etc/resolv.conf
	IFS=',' read -a array <<< "$DNSERVERIP"
	
    for element in "${array[@]}"
    do
        sed -i "/nameserver/d" $dns
        echo "nameserver $element" >>$dn
    done
}

closerpc
set_file_limit
ntpupdate
bindssh
configsshAllow
set_dns
