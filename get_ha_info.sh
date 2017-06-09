#!/bin/bash
pod_segment_netmask=255.192.0.0
float_ip=$1
ha_mode=$2        #it can only be ha_primary or ha_standby
pod_gw=$3
node_name=`uname -n`
os_type=`awk -F'[()]' '{split($(NF-4),a," ");print toupper(a[1])}' /proc/version`
gw_list=`netstat -rn|awk '$4=="UG"{print $2}'`
default_gw=`netstat -rn|awk '$1=="0.0.0.0"&&$4=="UG"{print $2}'`
interface=$(ip a|awk -F'[: ]' '$1~/[0-9]+/&&$3!="lo"{print $3}')
for i in $float_ip $pod_gw
do
    ip_judge=`echo $i|egrep -o '^((2[0-4][0-9]|25[0-5]|[01]?[0-9][0-9]?)\.){3}(2[0-4][0-9]|25[0-5]|[01]?[0-9][0-9]?)$'`
    if [ -z $ip_judge ];then
        echo "$i is an illegal ip address"
        exit 3
    fi
done
get_segment()  
{
   echo $1 $2 |awk -F '[ .]+' 'BEGIN{OFS="."} END{print and($1,$5),and($2,$6),and($3,$7),and($4,$8)}'
}

for if_name in $interface
do 
    ip=`ifconfig $if_name|awk -F"[: ]+" '$2=="inet"{if($3=="addr"){print $4 }else if($4=="netmask"){print $3}}'`
    mask=`ifconfig $if_name|awk -F"[: ]+" '$2=="inet"{if($3=="addr"){print $NF }else if($4=="netmask"){print $5}}'`
    if_name_segment=$(get_segment $ip $mask)
    float_segment=$(get_segment $float_ip $mask)
    pod_gw_segment=$(get_segment $pod_gw $mask)
    if [ $if_name_segment == $float_segment  ];then
        itf_name=$if_name;local_mask=$mask;local_ip=$ip
        if [ $# == 2 ];then
           for local_gw in $gw_list
           do 
               if [ $(get_segment $local_gw $mask) == $float_segment  ];then 
                  local_gateway=$local_gw
                  break
               fi    
           done
        elif [[ $float_segment == $pod_gw_segment ]]; then
           local_gateway=$pod_gw 
           break
        else
          echo -e "pod_lb_gw:$pod_gw and pod_shubao_lb_float_ip:$float_ip are not in the same segment!!!\nplease check the pod_lb_gw:$pod_gw"
          exit 1
        fi
    fi
done
if [ -z $itf_name ];then
  echo -e "float_ip:$float_ip and local ip are not in the same segment!!!\nplease check the float_ip:$float_ip"
  exit 2
fi

cat <<EOF > /tmp/${ha_mode}
${ha_mode}_itf_name: $itf_name
${ha_mode}_node_name: $node_name
${ha_mode}_local_mask: $local_mask
${ha_mode}_local_gateway: $local_gateway
${ha_mode}_local_ip: $local_ip
${ha_mode}_arbitration_ip: $local_gateway
EOF
target_segment=`get_segment $float_ip $pod_segment_netmask`
if [ $os_type == "EULEROS" -a $# == 3 ];then
route add -net $target_segment  netmask $pod_segment_netmask gw $local_gateway
cat << eof >/etc/sysconfig/network-scripts/route-$itf_name
ADDRESS0=$target_segment
NETMASK0=$pod_segment_netmask
GATEWAY0=$local_gateway
eof
elif [ $os_type == "SUSE" -a $# == 3 ];then
route add -net $target_segment  netmask $pod_segment_netmask gw $local_gateway
cat <<EOF > /etc/sysconfig/network/routes
default $default_gw - -
$target_segment      $local_gateway     $pod_segment_netmask 
EOF
fi
