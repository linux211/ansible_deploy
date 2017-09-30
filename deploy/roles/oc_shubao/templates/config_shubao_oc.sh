#bin/bash

# Copyright Huawei Technologies Co., Ltd. 1998-2015. All rights reserved.
# description:
# The script can config the oc 

umask 0077

config_file={{shubao_go.config_file}}

ocAlarmUri=https://{{g_oc.region_api_ip}}:{{g_oc.server_port}}/oc/v2.3/alarm/thirdalarms

ocTokenUri=https://{{g_oc.region_api_ip}}:{{g_oc.server_port}}/oc/v2.3/tokens

ocUserName={{oc_username}}

ocOnUse=true

sed -ri "/ocAlarmUri/s#:(.*)#: \"$ocAlarmUri\",#"  $config_file

sed -ri "/ocTokenUri/s#:(.*)#: \"$ocTokenUri\",#"  $config_file

sed -ri "/ocUserName/s#:(.*)#: \"$ocUserName\",#"  $config_file

sed -ri "/ocOnUse/s#:(.*)#: $ocOnUse,#"  $config_file
