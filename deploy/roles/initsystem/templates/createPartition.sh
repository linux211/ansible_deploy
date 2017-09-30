#!/bin/bash
  
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
#   CHANGE DIR : # 1.如果当前目录就是install文件所在位置，直接pwd取得绝对路径；
    # 2.而如果是从其他目录来调用install的情况，先cd到install文
    #   件所在目录,再取得install的绝对路径，并返回至原目录下。
    # 3.使用install调用该文件，使用的是当前目录路径
######################################################################
getCurPath()
{
  
    if [ "` dirname "$0" `" = "" ] || [ "` dirname "$0" `" = "." ]; then
        PACKAGE_PATH="`pwd`"
    else
        cd ` dirname "$0" `
        PACKAGE_PATH="`pwd`"
        cd - > /dev/null 2>&1
    fi
    echo $PACKAGE_PATH
}
curpath=$(getCurPath) 
declare -r scriptName="createPartitions.sh"
alias LOG_INFO='echoMessage [INFO] [$$] [${scriptName} ${LINENO}] '
alias LOG_WARN='echoMessage [WARN] [$$] [${scriptName} ${LINENO}] '
alias LOG_ERROR='echoMessage [ERROR] [$$] [${scriptName} ${LINENO}] '
  
# constant params
P1_INDEX=1
P2_INDEX=2

partitionIndex=0
UNPARTITIONED_DEVICE_NAME=""
FATABL_FILE="/etc/fstab"
LOGGER_PATH_FOLDER=/tmp/tool
LOGGER_FILE=system.log
LOGMAXSIZE=5120
  
#config the params  
#notice: P1-Primary partition 1 ;P2-Primary partition 2;P3-Primary partition 3;P4-Extended partition 4,reserved
#        P1_SIZE measure by M bytes  

P1_SIZE=43G
P1_FS_TYPE=ext3
TMP_P1_MOUNT_PATH=/mnt/tmp-var_log
P1_MOUNT_PATH=/var/log
# get all the left space
P2_FS_TYPE=ext3
TMP_P2_MOUNT_PATH=/mnt/tmp-opt
P2_MOUNT_PATH=/opt

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
#   FUNCTION   : init
#   DESCRIPTION: 
#   CALLS      : N/A
#   CALLED BY  : N/A
#   INPUT      : N/A
#   OUTPUT     : N/A
#   LOCAL VAR  : N/A
#   USE GLOBVAR: N/A
#   RETURN     : N/A
#   DESCRIPTION: Initialize the backup directory
######################################################################

init()
{
    LOG_INFO "Begin to init"
    mkdir -p "${TMP_P1_MOUNT_PATH}"
    mkdir -p "${TMP_P2_MOUNT_PATH}"
    LOG_INFO "End to init"
}

######################################################################
#   FUNCTION   : getUnpartitionedDeviceName
#   DESCRIPTION: 
#   CALLS      : N/A
#   CALLED BY  : main
#   INPUT      : N/A
#   OUTPUT     : UNPARTITIONED_DEVICE_NAME
#   LOCAL VAR  : isdisk_unparted
#   USE GLOBVAR: UNPARTITIONED_DEVICE_NAME
#   RETURN     : N/A
#   DESCRIPTION：get no partition disk information
######################################################################

getUnpartitionedDeviceName()
{
    LOG_INFO "Begin to getUnpartitionedDeviceName"
    local disk_list=$(parted -l 2>/dev/null|egrep -o '/dev/[a-z]{2}[b-z]{1,2}\>')
    if [ -z "$disk_list" ];then
        LOG_INFO "there is no extra disk, please insert a new one"
    else
        for i in $disk_list
        do
            local isdisk_unparted=$(parted  $i print 2>&1|egrep -c '^[[:space:]]?[1-9][0-9]*\>')
            if  [ $isdisk_unparted == 0  ];then
                UNPARTITIONED_DEVICE_NAME=$i
            fi
        done
        if [ -z $UNPARTITIONED_DEVICE_NAME ];then
            LOG_INFO "the disk have no extra space,please insert a new one" 
            exit 0
        fi
    fi
    LOG_INFO "End to getUnpartitionedDeviceName,UNPARTITIONED_DEVICE_NAME=${UNPARTITIONED_DEVICE_NAME}"
}

######################################################################
#   FUNCTION   : getUnpartitionedDeviceName
#   CALLS      : N/A
#   CALLED BY  : main
#   INPUT      : N/A
#   OUTPUT     : N/A
#   LOCAL VAR  : N/A
#   USE GLOBVAR: UNPARTITIONED_DEVICE_NAME ，P2_FS_TYPE，TMP_P1_MOUNT_PATH
#   RETURN     : N/A
#   DESCRIPTION：create a disk partition
######################################################################
  
createPartitions()
{
# Example: createPartitions 1 ext3 0G 43G
    LOG_INFO "Begin to createPartitions"
    if [ -z "${UNPARTITIONED_DEVICE_NAME}" ];then
    {
        LOG_ERROR "no available disk found. Please check and run again"
        return 1
    }
    fi
  
    LOG_INFO "createPartitions for P${1} will Begin."  
    if [ $1 == 1 ];then
    parted -s ${UNPARTITIONED_DEVICE_NAME}  mklabel msdos
    fi
    parted -s ${UNPARTITIONED_DEVICE_NAME}  mkpart primary  $2 $3 $4 
    eval P${1}_NAME="${UNPARTITIONED_DEVICE_NAME}${1}"
    LOG_INFO "createPartitions for P${1} End."
 
}
mkfs_tmp_mount()
{
#   mkfs_tmp_mount ext3 /dev/xvde2 /mnt/tmp_opt
        LOG_INFO "mkfs for $2 Begin."
        mkfs -t  $1  $2
        if [ $? == 0 ];then
        LOG_INFO "mkfs for $2 Success."
        mkdir -p $3
        LOG_INFO "mount $2 temporarily" 
        mount $2 $3 -o errors=panic
        else
            LOG_INFO "mkfs for $2 Faild."
        fi
}

Release_the_Catalog (){
# Example: Release_the_Catalog /var/log
    sshd_proc_name='/usr/sbin/sshd'
    process_list=`lsof $1|egrep -v "$$|$sshd_proc_name"| awk '$2!~/PID/{print $2 }'|sort -n|uniq`
        if [ -n  "$process_list" ];then
	    kill $process_list &>/dev/null||kill -9 $process_list &>/dev/null
        fi      
}
######################################################################
#   FUNCTION   : Transfer_Data
#   CALLS      : N/A
#   CALLED BY  : main
#   INPUT      : N/A
#   OUTPUT     : N/A
#   LOCAL VAR  : N/A
#   USE GLOBVAR: UNPARTITIONED_DEVICE_NAME ，P2_FS_TYPE，TMP_P1_MOUNT_PATH
#   RETURN     : N/A
#   DESCRIPTION：backup the data before mounting 
#                the disk that already exists
######################################################################

function Transfer_Data(){
# Example: Transfer_Data  '/home/zabbix/etc'  '/tmp/tmp'
    LOG_INFO "Begin Transfer_Data For ${1}."
    cd ~
    local MOUNT_PATH=$1
    local TMP_MOUNT_PATH=$2
    Release_the_Catalog $MOUNT_PATH 
    tar -cpf - -C  ${MOUNT_PATH}  ./  |tar -xf - -C ${TMP_MOUNT_PATH} && LOG_INFO "Transfer data for $1 Success!" 
    df -h |grep -q "${P_MOUNT_PATH}"
    if [ $? = 0 ];then
    umount $MOUNT_PATH
        if [ $? != 0 ];then
            Release_the_Catalog $MOUNT_PATH
            umount $MOUNT_PATH
        fi
    fi
    umount  ${TMP_MOUNT_PATH}
    rmdir  ${TMP_MOUNT_PATH}   
    LOG_INFO "End Transfer_Data For ${1}."
}  

######################################################################
#   FUNCTION   : MountPartition
#   CALLS      : N/A
#   CALLED BY  : main
#   INPUT      : P_NAME,P_MOUNT_PATH,P_FS_TYPE
#   OUTPUT     : N/A
#   LOCAL VAR  : P_NAME,P_MOUNT_PATH,P_FS_TYPE
#   USE GLOBVAR: N/A
#   RETURN     : N/A
#   DESCRIPTION：Mount the disk
######################################################################

MountPartition (){
    local P_NAME=$1
    local P_MOUNT_PATH=$2
    local P_FS_TYPE=$3
    df -h |grep -q "${P_MOUNT_PATH}"
    if [ $? = 0 ];then
    umount $P_MOUNT_PATH
        if [ $? != 0 ];then
            Release_the_Catalog $P_MOUNT_PATH
	    sleep 1
            umount -f $P_MOUNT_PATH
        fi
    fi
    sleep 2
    mount -t ext3  ${P_NAME} ${P_MOUNT_PATH} -o errors=panic
    sleep 4
    #show the result
    local P_name=$(echo ${P_NAME##*/})
    sed  -i "/${P_name}/d" ${FATABL_FILE}
    grep -v "${P_MOUNT_PATH}" ${FATABL_FILE} >${FATABL_FILE}.tmp
    mv ${FATABL_FILE}.tmp  ${FATABL_FILE}
    echo "${P_NAME} ${P_MOUNT_PATH} ${P_FS_TYPE} defaults,errors=panic 1 2" >> ${FATABL_FILE}
    mount -a
    LOG_INFO "$(df -h)"
}

######################################################################
#   FUNCTION   : Start_Process
#   CALLS      : N/A
#   CALLED BY  : main
#   INPUT      : 
#   OUTPUT     : N/A
#   LOCAL VAR  :
#   USE GLOBVAR: N/A
#   RETURN     : N/A
#   DESCRIPTION：Mount the disk main function
######################################################################

function Start_Process()
{
    LOG_INFO "get unpartitioned device name"
    getUnpartitionedDeviceName
    LOG_INFO "the unpartitioned device name is ${UNPARTITIONED_DEVICE_NAME}"

    LOG_INFO "create partition for ${UNPARTITIONED_DEVICE_NAME} Begin."
    createPartitions ${P1_INDEX} ${P1_FS_TYPE} 0G ${P1_SIZE}
    createPartitions ${P2_INDEX} ${P2_FS_TYPE} ${P1_SIZE} 100%
    LOG_INFO "create partition for ${UNPARTITIONED_DEVICE_NAME} End."
    # force fresh the linux core to know the new partition
    partprobe
    sleep 5
    partx ${UNPARTITIONED_DEVICE_NAME}
    sleep 3

    LOG_INFO "mkfs and mount  Begin."
    mkfs_tmp_mount ${P1_FS_TYPE} ${P1_NAME} ${TMP_P1_MOUNT_PATH}
    mkfs_tmp_mount ${P2_FS_TYPE} ${P2_NAME} ${TMP_P2_MOUNT_PATH}
    LOG_INFO "mkfs and mount  End."

    service cron stop||systemctl stop crond
    service ntp  stop||systemctl stop ntpd
    Transfer_Data "$P1_MOUNT_PATH"  "$TMP_P1_MOUNT_PATH" 
    Transfer_Data "$P2_MOUNT_PATH"  "$TMP_P2_MOUNT_PATH"
    MountPartition ${P1_NAME} ${P1_MOUNT_PATH} ${P1_FS_TYPE}
    MountPartition ${P2_NAME} ${P2_MOUNT_PATH} ${P2_FS_TYPE}
    service cron start||systemctl start crond
    service ntp  start||systemctl start ntpd
    service sshd start||systemctl start sshd
}

######################################################################
#   FUNCTION   : Main_Process
#   CALLS      : N/A
#   CALLED BY  : main
#   INPUT      : N/A
#   OUTPUT     : N/A
#   LOCAL VAR  :
#   USE GLOBVAR: N/A
#   RETURN     : N/A
#   DESCRIPTION：Check whether it is already mounted, 
#                if there is then end, else start to mount disk 
######################################################################

Main_Process()
{
    local var_log_size=`df -m|awk  '$1~/\dev\/[a-z][a-z][b-z]?[b-z][1-9]/&&$6~/\/var\/log$/{print $4 }'`
    local opt_size=`df -m|awk  '$1~/\dev\/[a-z][a-z][b-z]?[b-z][1-9]/&&$6~/\/opt$/{print $4}'`
    if [ -z "$var_log_size" -a  -z "$opt_size" ];then
        Start_Process
    else
        LOG_INFO "nothing to do"
        exit 0
    fi
}
case $1 in
normal)
Main_Process;;
force)
Start_Process;;
*)
shell_name=`basename $0`
echo Usage:" sh $shell_name [normal|force]" 
esac
exit 0
