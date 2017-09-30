#!/bin/bash
source /etc/profile

base_dir=/opt/{{common.user_console}}/ftp/

# install lftp
libgnutlsPkgName="$base_dir/libgnutls.rpm"
if [ -z `rpm -qa | grep libgnutls` ] && [ -f $libgnutlsPkgName ]; then
    rpm -i $libgnutlsPkgName
fi

lftpPkgName="$base_dir/lftp.rpm"
if [ -z `rpm -qa | grep lftp` ] && [ -f $lftpPkgName ]; then
    rpm -i $lftpPkgName
fi
if [ $? -ne 0 ]; then
    echo "install lftp rpm package failed"
    exit 1
fi
