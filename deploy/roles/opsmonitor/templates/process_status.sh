#!/bin/bash

memPercent(){
#ps aux|grep "$1"|grep -v "grep"|grep -cv "$0"
if [[ $(ps aux|grep "$1"|grep -v "grep"|grep -cv "$0") == 0 ]];then
   echo 0
   exit 1
fi
MemUsed=$(ps aux|grep "$1"|grep -v "grep"|grep -v "$0"|awk '{sum+=$6}; END{print sum}')
MemTotal=$(grep "MemTotal" /proc/meminfo| awk '{print $2}')
awk 'BEGIN{printf "%.2f\n",('$MemUsed'/'$MemTotal')*100}'
}

cpuPercent(){
if [[ $(ps aux|grep "$1"|grep -v "grep"|grep -cv "$0") == 0 ]];then
   echo 0
   exit 1
fi
CpuCores=$(grep "processor" /proc/cpuinfo|wc -l)
CpuPercent=$(ps aux|grep "$1"|grep -v "grep"|grep -v "$0"|awk '{sum+=$3}; END{print sum/'$CpuCores'}')
echo $((${CpuPercent//.*/+1}))
}

processNum(){
    ps aux|grep "$1"|grep -v "grep"|grep -v "$0"| wc -l
}

case "$1" in
nginxmem)
memPercent nginx
;;
nginxcpu)
cpuPercent nginx
;;
nginxnum)
processNum nginx
;;
mysqlmem)
memPercent mysql
;;
mysqlcpu)
cpuPercent mysql
;;
mysqlnum)
processNum mysql
;;
tomcatmem)
memPercent tomcat
;;
tomcatcpu)
cpuPercent tomcat
;;
tomcatnum)
processNum tomcat
;;
gaussdbmem)
memPercent gaussdb
;;
gaussdbcpu)
cpuPercent gaussdb
;;
gaussdbnum)
processNum gaussdb
;;
kafkamem)
memPercent kafka
;;
kafkacpu)
cpuPercent kafka
;;
kafkanum)
processNum kafka
;;
memcachedmem)
memPercent memcached
;;
memcachedcpu)
cpuPercent memcached
;;
memcachednum)
processNum memcached
;;
zookeepermem)
memPercent zookeeper
;;
zookeepercpu)
cpuPercent zookeeper
;;
zookeepernum)
processNum zookeeper
;;
jettymem)
memPercent jetty
;;
jettycpu)
cpuPercent jetty
;;
jettynum)
processNum jetty
;;
bluefloodmem)
memPercent blueflood
;;
bluefloodcpu)
cpuPercent blueflood
;;
bluefloodnum)
processNum blueflood
;;
cassandramem)
memPercent cassandra
;;
cassandracpu)
cpuPercent cassandra
;;
cassandranum)
processNum cassandra
;;
infinispanmem)
memPercent infinspan
;;
infinispancpu)
cpuPercent infinspan
;;
infinispannum)
processNum infinspan
;;
silvanmem)
memPercent silvan
;;
silvancpu)
cpuPercent silvan
;;
silvannum)
processNum silvan
;;
nodemem)
memPercent node
;;
nodecpu)
cpuPercent node
;;
nodenum)
processNum node
;;
alarmmem)
memPercent alarm
;;
alarmcpu)
cpuPercent alarm
;;
alarmnum)
processNum alarm
;;
asgardmem)
memPercent asgard
;;
asgardcpu)
cpuPercent asgard
;;
asgardnum)
processNum asgard
;;
schedulemem)
memPercent schedule
;;
schedulecpu)
cpuPercent schedule
;;
schedulenum)
processNum schedule
;;
*)
echo "Usage: $0 {nginxmem|mysqlmem|tomcatmem}"
esac
