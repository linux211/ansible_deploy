#!/bin/bash
set -o errexit
#set -o nounset
float_ip={{float_ip}}
pod_lb_gw={{pod_lb_gw}}
pod_flag={{flag_type_pod}}
local_ha_file={{local_ha_file}}
remote_ha_file={{remote_ha_file}}
ha_config_file={{ha_nginx.ha_config_file}}
pod_lb_target_segment={{pod_lb_target_segment}}
pod_lb_target_netmask={{pod_lb_target_netmask}}
os_type=$(egrep -io 'EulerOS|SUSE' /proc/version| tr '[a-z]' '[A-Z]')

function error_exit {
  echo "$1" 1>&2
  exit 1
}

# function of get ha info
function get_ha_info {
#get interface name and  netmask  and ipaddress
if_info=$(ifconfig|sed -rn '/^[^ ]/{s#^([^ ]*)[: ]\s.*#\1#g;h;: top;n;/^$/b;
    s#^.*inet( addr)?[: ](((2[0-4][0-9]|25[0-5]|[01]?[0-9][0-9]?)\.){3}(2[0-4][0-9]|25[0-5]|[01]?[0-9][0-9]?)).*[Mm]ask[: ](((2[0-4][0-9]|25[0-5]|[01]?[0-9][0-9]?)\.){3}(2[0-4][0-9]|25[0-5]|[01]?[0-9][0-9]?)).*#\2,\6#g;
    T top;H;x;s/\n/,/g;p}'|egrep -v ':|lo')
#get interface information which segment is same as float ip
eval $(echo $if_info|awk -v f_ip="$float_ip" 'BEGIN{FS=",";OFS=";";RS=" "}{split($2,ip_addr,".");split($3,net_mask,".");
    split(f_ip,fl_ip,".");for(i=1;i<=4;i++){a[i]=and(net_mask[i],ip_addr[i]);b[i]=and(net_mask[i],fl_ip[i])};
    if (a[1]==b[1]&&a[2]==b[2]&&a[3]==b[3]&&a[4]==b[4]){print "itf_name="$1,"ip_addr="$2,"net_mask="$3}
}')

if [ -z $itf_name ];then
error_exit "Floating IP and local IP are not on the same network segment,please check your Floating IP"
fi

node_name=$(uname -n)
default_gw=$(route -n |awk -v if_name=$itf_name '$8==if_name&&$4=="UG"{print $2}'|uniq)

# config route for pod lb
if [ $pod_flag == "Y" ];then
    local_gateway=$pod_lb_gw
    pod_route_num=$(route -n|egrep "$pod_lb_target_segment\s+$local_gateway\s+$pod_lb_target_netmask\s+UG\b"|wc -l)
    if [ $pod_route_num -eq 0 ];then
        route add -net $pod_lb_target_segment  netmask $pod_lb_target_netmask gw $local_gateway
    fi
if [ $os_type == "SUSE" ];then
cat <<EOF > /etc/sysconfig/network/routes
default $default_gw - -
$pod_lb_target_segment      $local_gateway     $pod_lb_target_netmask
EOF
else
cat <<eof >/etc/sysconfig/network-scripts/route-$itf_name
ADDRESS0=$pod_lb_target_segment
NETMASK0=$pod_lb_target_netmask
GATEWAY0=$local_gateway
eof
fi
else
  local_gateway=$default_gw
fi

#output ha info to file
cat <<EOF > /tmp/${local_ha_file}
local_itf_name=$itf_name
local_node_name=$node_name
local_ip=$ip_addr
local_gateway=$local_gateway
local_mask=$net_mask
local_arbitration_ip=$local_gateway
EOF
}

# function of config ha
function config_ha {
sed -i 's#local#remote#g' $remote_ha_file
eval $(cat $local_ha_file $remote_ha_file)
sed -ri -e "/^(nodeName=).*/s##\1$local_node_name#" \
        -e "/^(localIP=).*/s##\1$local_ip#"   \
        -e "/^(localMask=).*/s##\1$local_mask#" \
        -e "/^(localGateWay=).*/s##\1$local_gateway#" \
        -e "/^(floatIP=).*/s##\1$float_ip#" \
        -e "/^(remoteNodeName=).*/s##\1$remote_node_name#" \
        -e "/^(remoteIp=).*/s##\1$remote_ip#" \
        -e "/^(haArbitrationIP=).*/s##\1$remote_arbitration_ip#" \
        -e "/^(itfName=).*/s##\1$remote_itf_name#" $ha_config_file
}
case $1 in
get_ha_info)
  get_ha_info  ;;
config_ha)
  config_ha ;;
*)
echo Usage:" sh $(basename $0) [get_ha_info|config_ha]"
esac
