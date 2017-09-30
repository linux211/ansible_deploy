#bin/bash

cd /opt/apigateway

# the back up file
backup_file=/opt/{{common.user_apigateway}}/{{shubao_go.backup_name}}

# the config file list 
config_file_list=`tar -tvf $backup_file |awk '$1!~/^d/&&$6~/\/ssl\/.*\/.*|\.jks$|\.p12$|\.crt$|\.key$/{print $6}'`

# copy the config file to 
if [ -z "$config_file_list" ]; then 
    echo "The config file is empty."
else
    echo "The config file list is:" $config_file_list
    tar -xf /opt/{{common.user_apigateway}}/{{shubao_go.backup_name}} $config_file_list -C {{restore_dir}}  
fi
