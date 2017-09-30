#!/bin/bash

source /etc/profile

kfk_cmd_path="/opt/{{common.user_apigateway}}/kafka/bin"
zookeeper_list="{{common_ips.I_APIGW_KFK01}}:{{common.zookeeper_client_port}},{{common_ips.I_APIGW_KFK02}}:{{common.zookeeper_client_port}},{{common_ips.I_APIGW_KFK03}}:{{common.zookeeper_client_port}}"
broker_list="{{common_ips.I_APIGW_KFK01}}:{{common.kafka_port}},{{common_ips.I_APIGW_KFK02}}:{{common.kafka_port}},{{common_ips.I_APIGW_KFK03}}:{{common.kafka_port}}"
topic="just_test_kfk_availability"
message=`date +%Y-%m-%d:%H:%M:%S`
producer="${kfk_cmd_path}/kafka-console-producer.sh --broker-list $broker_list --topic $topic"
consumer="${kfk_cmd_path}/kafka-console-consumer.sh --zookeeper $zookeeper_list --topic $topic --max-messages 1"
create_topic="${kfk_cmd_path}/kafka-topics.sh --create --zookeeper $zookeeper_list --replication-factor 1 --partitions 1 --topic $topic"
topic_list="${kfk_cmd_path}/kafka-topics.sh --list --zookeeper $zookeeper_list"
output_file="/tmp/kfk_availability_test"

# whether $topic is existed
existed=`eval $topic_list | grep "$topic" | wc -l`
if [ $existed -eq 0 ]; then
	# create if not existed
	eval $create_topic
fi

# firstly, to start consumer to receive message
eval $consumer  1>$output_file 2>/dev/null &

# waiting for 10 seconds
sleep 10s

# secondly, to start producer to send message
eval echo $message | $producer 1>/dev/null 2>&1

# compare the receive message with the send message
receive_message=`awk 'NR==1{print}' $output_file`
if [ "$receive_message" ] && [ $receive_message = $message ]; then
	echo 0
else
    echo 1
fi
