
#!/bin/sh

zookeeperport=2181
zookeeperleadport=8880
zookeeperfollowport=7770
kafkaport=9092
accessip={{ansible_ssh_host}}



# kafka zookeeper client address
clientips={{asgard.ips | join(",")}},{{apigateway.ips | join(",")}}
kafkacluster={{zookeeper.ips | join(",")}}

IFS=,
clientarr=($clientips)
sudo /usr/sbin/iptables --flush
for clientaddress in "${!clientarr[@]}"; 
do
   address=${clientarr[$clientaddress]}
   
  sudo /usr/sbin/iptables -A INPUT -s ${address} -p tcp  -m multiport --dports ${zookeeperport},${kafkaport} -j ACCEPT
  
done

kafkaclusterarr=($kafkacluster)
 
for clusteraddress in "${!kafkaclusterarr[@]}"; 
do
    address=${kafkaclusterarr[$clusteraddress]}
	
    sudo /usr/sbin/iptables -A INPUT -s ${address} -p tcp  -m multiport --dports  ${zookeeperport},${kafkaport},${zookeeperleadport},${zookeeperfollowport} -j ACCEPT
done

sudo /usr/sbin/iptables -D INPUT -s ${accessip} -p tcp  -m multiport --dports  ${zookeeperport},${kafkaport},${zookeeperleadport},${zookeeperfollowport} -j ACCEPT

sudo /usr/sbin/iptables -A INPUT -p tcp -m multiport --dport ${zookeeperport},${kafkaport},${zookeeperleadport},${zookeeperfollowport} -j DROP

sudo /usr/sbin/iptables-save

