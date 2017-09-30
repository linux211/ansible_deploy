#!/bin/bash

umask 0077 

path={{opsmonitorservice}}

srcpath=/home/{{common.opsmonitor_user}}/opsmonitor

destpath=/home/{{common.opsmonitor_user}}/service/process

IFS=',' read -a array <<< "$path"

if [ ! -d "$destpath" ]; then
    mkdir -p $destpath
fi

for element in "${array[@]}"

do
    if [  -d "$destpath/$element" ]; then
        rm -rf $destpath/$element
    fi
    
	mv $srcpath/$element $destpath
	chmod +x $destpath/$element/* -R
	dos2unix $destpath/$element/*.sh
done
