#!/bin/sh

source /etc/profile

#component="{{component}}"
PROGRAM_KAFKA=kafka.Kafka
PROGRAM_CASSANDRA=CassandraDaemon
KAFKA_PORT=9092
CASSANDRA_PORT=9042
PROGRAM_ZOOKEEPER="QuorumPeerMain"
ZOOKEEPER_PORT=2181
CMD_ZOOKEEPER_STATUS="/opt/apigateway/zookeeper/bin/zkServer.sh status"
PROGRAM_TOMCAT="/opt/apigateway/tomcat"
PROGRAM_SHUBAO="shubao"
PROGRAM_MEMCACHED="memcached"
SHUBAO_PORT=7443
MEMCACHED_PORT=11211
PROGRAM_ASGARD="asgard"
PROGRAM_SILVAN="silvan"
PROGRAM_NGINX="nginx"
PROGRAM_ETL="etl-bootstarp"


LOCAL_HOST_IP={{ansible_ssh_host}}

if [ -z $LOCAL_HOST_IP ];then
   echo "LOCAL_HOST_IP is empty"
   exit 1
fi


isShubaoOk()
{
     ## check  process
    shubaoCount=`ps -ef | grep -E ${PROGRAM_SHUBAO}\|${PROGRAM_TOMCAT} | grep -v grep | wc -l`
    
    if [ ${shubaoCount} -ne 1 ];then
        echo "shubao process is not Ok"
    else
        echo "shubao process is Ok"
    fi

    ## check  port
    isPortExist=$(netstat -nlt | grep ${SHUBAO_PORT})
    
    if [ -z "${isPortExist}" ]; then
        echo "process port $SHUBAO_PORT not exist!"
    else
    echo "process port $SHUBAO_PORT exist!"
    fi

    # time(second): wait for connection
    local CONNECT_TIMEOUT=30

    # time(second): transfer data
    local TRANS_TIMEOUT=10

    declare -i status_code=`curl -k -i --silent --connect-timeout ${CONNECT_TIMEOUT} -m ${TRANS_TIMEOUT} https://${LOCAL_HOST_IP}:${SHUBAO_PORT}/native/version | awk 'NR==1{print}' | awk '{print $2}'`
    if [ ${status_code} -ge 200 ] && [ ${status_code} -lt 300 ]; then 
        echo "shubao api is Ok"
    else
        echo "shubao api is not Ok"
    fi
}

isSilvanOk()
{
    ## check silvan process
    silvanCount=`ps -ef | grep ${PROGRAM_SILVAN} | grep -v grep | wc -l`
    if [ ${silvanCount} -ne 1 ];then
        echo "silvan process is not Ok"
    else
    echo "silvan process is Ok"
    fi
    
    ## check silvan business 
    # time(second): wait for connection
    local CONNECT_TIMEOUT=30

    # time(second): transfer data
    local TRANS_TIMEOUT=10

    declare -i status_code=`curl -k  -i --silent --connect-timeout ${CONNECT_TIMEOUT} -m ${TRANS_TIMEOUT} https://${LOCAL_HOST_IP}:8086/silvan/rest/v1.0/health-check | awk 'NR==1{print}' | awk '{print $2}'`
    
    if [ ${status_code} -ge 200 ] && [ ${status_code} -lt 300 ]; then
        echo "silvan api is Ok"
    else
        echo "silvan api is not Ok"
    fi
}


isAsgardOk()
{
    ## check asgard process
    asgardCount=`ps -ef | grep ${PROGRAM_ASGARD} | grep -v grep | wc -l`
    if [ ${asgardCount} -ne 1 ];then
        echo "asgard process is not Ok"
    else
        echo "asgard process is Ok"
    fi
}


isZookeeperOk()
{
    ## check zookeeper process
    zookeeperCount=`ps -ef | grep ${PROGRAM_ZOOKEEPER} | grep -v grep | wc -l`
    if [ ${zookeeperCount} -ne 1 ];then
        echo "zookeeper process is not Ok"
    else
        echo "zookeeper process is Ok"
    fi

    ## check zookeeper port
    isPortExist=$(netstat -nlt | grep ${ZOOKEEPER_PORT})
    if [ -z "${isPortExist}" ]; then
        echo "zookeeper port $ZOOKEEPER_PORT not exist!"
    else
        echo "zookeeper port $ZOOKEEPER_PORT exist!"
    fi

    ## check zookeeper status
    zookeeperStatus=$($CMD_ZOOKEEPER_STATUS | grep Error | wc -l)
    if [ ${zookeeperStatus} -ne 0 ];then
        echo "zookeeper cluster is not Ok"
    else
        echo "zookeeper cluster is Ok"
    fi
}


isKafkaOk()
{
    ## check kafka process
    kafkaCount=`ps -ef | grep ${PROGRAM_KAFKA} | grep -v grep | wc -l`
    if [ ${kafkaCount} -ne 1 ];then
        echo "kafka process is not Ok"
    else
        echo "kafka process is Ok"
    fi

    ## check kafka port
    isPortExist=$(netstat -nlt | grep ${KAFKA_PORT})
    if [ -z "${isPortExist}" ]; then
        echo "kafka port $KAFKA_PORT not exist!"
    else
        echo "kafka port $KAFKA_PORT exist!"
    fi
}

isCassandraOk()
{
    ## check CASSANDRA process
    cassandraCount=`ps -ef | grep ${PROGRAM_CASSANDRA} | grep -v grep | wc -l`
    if [ ${cassandraCount} -ne 1 ];then
        echo "cassandra process is not Ok"
    else
        echo "cassandra process is Ok"
    fi

    ## check kafka port
    isPortExist=$(netstat -nlt | grep ${CASSANDRA_PORT})
    if [ -z "${isPortExist}" ]; then
        echo "cassandra port $CASSANDRA_PORT not exist!"
    else
        echo "cassandra port $CASSANDRA_PORT exist!"
    fi
}

isEtlOk()
{
    ## check kafka process
    etlCount=`ps -ef | grep ${PROGRAM_ETL} | grep -v grep | wc -l`
    if [ ${etlCount} -ne 1 ];then
        echo "etl process is not Ok"
    else
        echo "etl process is Ok"
    fi
}

isMemcachedOk()
{
    ## check memcached process
    memcachedCount=`ps -ef | grep ${PROGRAM_MEMCACHED} | grep -v grep | wc -l`
    if [ ${memcachedCount} -ne 1 ];then
        echo "memcached process is not Ok"
    else
        echo "memcached process is Ok"
    fi

    ## check memcached port
    isPortExist=$(netstat -nlt | grep ${MEMCACHED_PORT})
    if [ -z "${isPortExist}" ]; then
        echo "memcached port $MEMCACHED_PORT not exist!"
    else
        echo "memcached port $MEMCACHED_PORT exist!"
    fi
}

isNginxOk()
{
  
    ## check is active node
    source /etc/profile
    status=`QueryHaState |awk -F'=' '/LOCAL_STATE/{print $2}'`
    
    # ha status
    if [ x'active' != x$status  -a x'standby' != x$status ];  then
        echo "ha status is not Ok"
    else
        echo "ha status is Ok"
    fi 

    if [ x'active' == x$status ];  then
         nginxCount=`ps -ef | grep ${PROGRAM_NGINX} | grep -v grep | wc -l`
         if [ ${nginxCount} -le 0 ];then
             echo "nginx process is not Ok"
         else
             echo "nginx process is Ok"
         fi   
    fi

}

## check node type and status
checkHealth()
{
    if [ -d "/opt/apigateway/shubao" ]; then
        isShubaoOk
    fi
    
    if [ -d "/opt/apigateway/asgard" ]; then
        isAsgardOk
    fi
    if [ -d "/opt/apigateway/kafka" ]; then
        isKafkaOk
        isZookeeperOk
    fi
    if [ -d "/opt/onframework/memcached" ]; then
       isMemcachedOk
    fi
    if [ -d "/opt/onframework/silvan" ]; then
       isSilvanOk
    fi
    
    if [ -d "/opt/onframework/nginx" ]; then
       isNginxOk
    fi
    
    if [ -d "/opt/apigateway/cassandra" ]; then
       isCassandraOk
    fi
    
    if [ -d "/opt/apigateway/etl" ]; then
       isEtlOk
    fi
    
    if [ ! -d "/opt/apigateway/shubao" ] && [ ! -d "/opt/apigateway/asgard" ] && [ ! -d "/opt/apigateway/kafka" ] && [ ! -d "/opt/onframework/memcached" ] &&  [ ! -d "/opt/onframework/silvan" ] && [ ! -d "/opt/apigateway/cassandra" ] && [ ! -d "/opt/apigateway/etl" ] && [ ! -d "/opt/onframework/nginx" ];then
        echo "The node don't involve health check"
    fi
}

checkHealth