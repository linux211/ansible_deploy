#bin/bash

ip_addr_mask=`ip a|awk '$1=="inet"&&$NF!~/:|lo/{print $2}'|sed '1!d'`; echo "ip_address_mask: $ip_addr_mask" > /tmp/ip_addr_mask;