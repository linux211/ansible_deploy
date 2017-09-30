#!/bin/bash

umask 0077 

declare -r scriptName=$(basename "${BASH_SOURCE}")
alias LOG_INFO='echoMessage [INFO] [${scriptName} ${LINENO}] '
alias LOG_WARN='echoMessage [WARN] [${scriptName} ${LINENO}] '
alias LOG_ERROR='echoMessage [ERROR] [${scriptName} ${LINENO}] '
shopt -s expand_aliases

# 需要绑定的机器ip
localip={{ansible_ssh_host}}
LOGGER_PATH_FOLDER=/var/log/initsysconfig
LOGGER_FILE=initsysconfig.log
LOGMAXSIZE=5120

# 设定文件开启最大数
file_limits=65535

######################################################################
#   FUNCTION   : echoMessage
#   DESCRIPTION: 显示步骤，并打印后续信息
#   CALLS      : 无
#   CALLED BY  : main
#   INPUT      : 参数1要打印的字符串
#   OUTPUT     : 无
#   LOCAL VAR  : 无
#   USE GLOBVAR: stepIndex stepName
#   RETURN     : 无
#   CHANGE DIR : 无
######################################################################
echoMessage()
{
    # 打印后续信息
    local strMsg="$@"
    if [ -n "$strMsg" ]; then
        # 每一行的首字符大写
        strMsg=$(echo "$strMsg" | awk -F'\n' '{print toupper(substr($1,1,1)) substr($1,2);}')
    fi
        # 打印结果
        echo "${strMsg}";

    # 记录log文件
    logger "${strMsg}" ;
}

######################################################################
#  FUNCTION     : createDir
#  DESCRIPTION  : 创建文件夹
#  CALLED BY    : 无
#  INPUT        : 无
#  READ GLOBVAR : 无
#  WRITE GLOBVAR: 无
#  RETURN       : 无
######################################################################
createDir()
{
    local dir="$1";
    if [ ! -d "$dir" ]; then
        mkdir -p $dir
    fi
}

######################################################################
#   FUNCTION   : logger
#   DESCRIPTION: 记录日志
#   CALLS      : 无
#   CALLED BY  : main
#   INPUT      : 无
#   OUTPUT     : 无
#   LOCAL VAR  : 无
#   USE GLOBVAR: stepIndex stepName
#   RETURN     : 无
#   CHANGE DIR : 无
######################################################################
logger()
{
     # 初始化文件目录
    createDir $LOGGER_PATH_FOLDER

    # 设定权限
    chmod 700 ${LOGGER_PATH_FOLDER}/
    
    local LOG_FULL_FILE_PATH=${LOGGER_PATH_FOLDER}/${LOGGER_FILE}	
    local logsize=0
    if [ -e "$LOG_FULL_FILE_PATH" ]; then
        logsize=`ls -lk ${LOG_FULL_FILE_PATH} | awk -F " " '{print $5}'`
    fi
    
    if [ "$logsize" -gt "$LOGMAXSIZE" ]; then
        # 每次删除10000行，约300K
        sed -i '1,10000d' $LOG_FULL_FILE_PATH
    fi
    
    echo "[$(date -d today +"%Y-%m-%d %H:%M:%S %:::z")] $1" >> ${LOG_FULL_FILE_PATH} 2>/dev/null
    chmod 600 ${LOG_FULL_FILE_PATH}
}

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
    sed -ri "s#(PermitRootLogin yes)(.*)#PermitRootLogin without-password#" $sshfile
    
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
    conf_file=/etc/ntp.conf
    LOG_INFO "start to config the ntp."
    if [ x"${NTPSERVERIP}" != x ]; then
        sed -i "/prefer/d" $conf_file
        sed -i "/server 127.127.1.0/iserver $NTPSERVERIP prefer" $conf_file
        service ntp restart
        chkconfig on
        LOG_INFO "update ntp config."
    fi
    sed -ri '/etc\/init.d\/ntp/d' /etc/crontab
    echo '*/10 * * * * root /etc/init.d/ntp start' >> /etc/crontab
    LOG_INFO "finish ntp config."
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
    sed -i "/nameserver/d" $dns
    for element in "${array[@]}"
    do
        sed -i "/nameserver $element/d" $dns
        echo "nameserver $element" >>$dns
    done
}

closerpc
set_file_limit
bindssh
configsshAllow

