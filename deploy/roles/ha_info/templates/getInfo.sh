#!/bin/bash

FLOATING_IP=$1

IS_PRIMARY=$2

IS_POD_LB=$3

# all eth
ethernets=`ifconfig | cut -d' ' -f1 | sed '/^$/d' | sed 's/://g'`

array=(${ethernets//,/ })

floatip_array=(${FLOATING_IP//./ })
local_ip=""
local_gateway=""
hostname=`hostname`

if [[ $IS_PRIMARY == ha_primary ]] ; then
    RESULT=/tmp/ha_primary
else
    RESULT=/tmp/ha_standby
fi

if [ -f "$RESULT" ]; then 
    rm -rf $RESULT
    touch $RESULT
else
    touch $RESULT
fi    

pod_lb_static_gw=`route -n | grep -w UG | grep {{pod_lb_gw}}|wc -l`

if [[ $IS_POD_LB == "Y" ]] && [[ $pod_lb_static_gw -eq 0 ]] ; then
    if [ -f "/etc/euleros-release" ] ; then
        ## add temporary route
        route add -net {{pod_lb_target_segment}} netmask {{pod_lb_target_netmask}} gw {{pod_lb_gw}}
    else
        sed -i "/{{pod_lb_gw}}/d" /etc/sysconfig/network/routes
        echo "{{pod_lb_target_segment}} {{pod_lb_gw}} {{pod_lb_target_netmask}}" >> /etc/sysconfig/network/routes
        service network restart
    fi
fi

# check result
if [ $? -ne 0 ]; then
  exit 1
fi

for ethernet in ${array[@]}
do

    float_result=""
    local_gateway_result=""
    if [[ $ethernet == "eth"* ]]; then

        local_gateway=`route -n | grep "${ethernet}" | grep -w UG | awk '{print $2}'|uniq`
        #查询/etc下release信息判断是否为欧拉系统
        if [ -f "/etc/euleros-release" ] ; then
            local_mask=`ifconfig ${ethernet} | grep "netmask" | awk '{print $4}'`
            local_ip=`ifconfig ${ethernet} | grep "netmask" | awk '{print $2}'`

        else
            local_mask=`ifconfig ${ethernet} | grep Mask | awk '{ print$4 }' | awk -F ":" '{ print $2 }'`
            local_ip=`ifconfig ${ethernet} | grep Mask | awk '{ print$2 }' | awk -F ":" '{ print $2 }'`

        fi
        
            # match local_gateway
            local_mask_array=(${local_mask//./ })

            local_gateway_array=(${local_gateway//./ })

        for i in "${!floatip_array[@]}"; do

            f_result=$((${floatip_array[$i]} & ${local_mask_array[$i]}))

            g_result=$((${local_gateway_array[$i]} & ${local_mask_array[$i]}))

            float_result=$float_result"${f_result}"

            local_gateway_result=$local_gateway_result"${g_result}"
	    done
        
        # check result
        if [ $? -ne 0 ]; then
            exit 1
        fi

	    if [[ $float_result == $local_gateway_result ]] ; then
        
            if [[ $IS_PRIMARY == 'ha_primary' ]] ; then
                echo ha_primary_itf_name: $ethernet >> $RESULT
                echo ha_primary_node_name: $hostname >> $RESULT
                echo ha_primary_local_mask: $local_mask >> $RESULT
                echo ha_primary_local_gateway: $local_gateway >> $RESULT
                echo ha_primary_local_ip: $local_ip >> $RESULT
                echo ha_primary_arbitration_ip: $local_gateway >> $RESULT 
            else
                echo ha_standby_remote_node_name: $hostname >> $RESULT
                echo ha_standby_local_gateway: $local_gateway >> $RESULT
                echo ha_standby_local_mask: $local_mask >> $RESULT
                echo ha_standby_remote_ip: $local_ip >> $RESULT
                echo ha_standby_itf_name: $ethernet >> $RESULT
            fi
              
            if [[ $IS_POD_LB == "Y"  ]] && [[ -f "/etc/euleros-release" ]] ; then
                # add permart route
                route_config=/etc/sysconfig/network-scripts/route-$ethernet
                echo ADDRESS0={{pod_lb_target_segment}} >  $route_config
                echo NETMASK0={{pod_lb_target_netmask}} >> $route_config
                echo GATEWAY0={{pod_lb_gw}} >> $route_config
                service network restart
            fi
            break
        fi
    fi
done


