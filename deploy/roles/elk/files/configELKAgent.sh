#!/bin/sh
###############################################################
## @Company:
#
## @Filename:     configELKAgent.sh
## @Usage:        sh configELKAgent.sh
## @Description:  fix the ELKAgent config
#
## @Options:      
## @History:      initial
## @Author:
## @Version:      v1.0
## @Created:      05.31.2017

backupTime=`date +%Y%m%d`
CONFIG_PATH=""
BIN_PATH=""

cd $CONFIG_PATH

## For ELKAgent 2.0.0
if [ -d "logstash-shipper" ]
then
    cp ./logstash-shipper/elk_input.conf ./logstash-shipper/elk_input.conf.${backupTime}
    mv elk_input.conf ./logstash-shipper/
    cd ${BIN_PATH}
    sh stop_shipper.sh || exit 1
    sh start_shipper.sh || exit 1
    echo "ELKAgent2.0.0 config has been fixed successful"
    exit 0
fi

## For ELKAgent version lower than 2.0.0
checkConfig=`diff elk_input.conf logstash-shipper.conf | grep "/var/log"`

if [ -z "$checkConfig" ]
then
    echo "no need fix config."
    exit 0
else
    ##Back old config
    cp logstash-shipper.conf logstash-shipper.conf.${backupTime}
    firstLine=`grep -n "filter {" logstash-shipper.conf | awk -F : '{print $1}' | head -1`
    echo >> elk_input.conf
    sed -n ''${firstLine}',$p' logstash-shipper.conf >> elk_input.conf
    mv elk_input.conf logstash-shipper.conf
    cd ${BIN_PATH}
    sh stop_shipper.sh || exit 1
    sh start_shipper.sh || exit 1
    echo "config has been fixed successful"
    exit 0
fi
