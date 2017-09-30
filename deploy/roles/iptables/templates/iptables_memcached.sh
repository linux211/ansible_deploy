
#!/bin/sh

umask 077

memcacheport={{common.memcache_port}}

# memcache client address
clientips={{asgard.ips | join(",")}}

IFS=,
clientarr=($clientips)

# clean the ruler
sudo /usr/sbin/iptables --flush

for clientaddress in "${!clientarr[@]}"; 

do
   address=${clientarr[$clientaddress]}
   sudo /usr/sbin/iptables -A INPUT -s ${address} -p tcp  --dport  ${memcacheport} -j ACCEPT
   
done

sudo /usr/sbin/iptables -A INPUT -p tcp --dport ${memcacheport} -j DROP

sudo /usr/sbin/iptables-save