#!/bin/bash
#!/bin/sh
###############################################################
## @Company:      HUAWEI Tech. Co., Ltd.
#
## @Filename:     auto-del-90-days-log.sh
## @Usage:        sh  auto-del-90-days-log.sh
## @Description:   remove log
#
## @Options:      remove log
## @History:      initial
## @Version:      v1.0
## @Created:      03.29.2016
##############################################################


time_period={{log_remove_time_period}}

#启动执行logrotate，删除转储过期日志
logrotate -v /etc/logrotate.d/logrotate >& null

#删除tomcat目录下过期日志
find /opt/apigateway/tomcat7059/logs/ -mtime +$time_period -name "*.log" -exec rm -rf {} \;
find /opt/apigateway/tomcat7059/logs/ -mtime +$time_period -name "*.txt" -exec rm -rf {} \;
find /opt/apigateway/tomcat7059/logs/ -mtime +$time_period -name "*.gz" -exec rm -rf {} \;

#删除kafka日志目录下的过期日志
find /opt/apigateway/kafka/logs/ -mtime +$time_period -name "*.log*" -exec rm -rf {} \;

#删除NGXS下的过期目录
find /opt/onframework/nginx/logs/ -mtime +$time_period -name "*.log" -exec rm -rf {} \;

#删除zookeeper下的过期目录
find /var/log/apigateway/zookeeper/ -mtime +$time_period -name "*.log" -exec rm -rf {} \;

#删除/var/logs下的过期日志
find /var/log/ -mtime +$time_period -name "*.log" -exec rm -rf {} \;
find /var/log/ -mtime +$time_period -name "*.bz2" -exec rm -rf {} \;

