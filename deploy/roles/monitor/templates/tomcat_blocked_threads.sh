#!/bin/bash

# make sure java tools is available
source /etc/profile

threadDumpFile="/tmp/tomcat_thread.dump"
outputFile={{common.tomcat_thread_num_file}}


function getTomcatPid
{
    echo `jps -l | awk '/org\.apache\.catalina\.startup\.Bootstrap/{print $1}'`
}

function getThreadNum 
{
    echo `grep "java.lang.Thread.State" $threadDumpFile | wc -l` 
}

function getBlockedThreadNum
{
    echo `grep "java.lang.Thread.State: BLOCKED" $threadDumpFile | wc -l`
}

# create $threadDumpFile
if [ ! -f $threadDumpFile ]; then
    touch $threadDumpFile
fi

tomcatPID=`getTomcatPid`

# whether the tomcat process existed
if [ -z tomcatPID ]; then
    echo 0
    exit 1
fi

# dump the thread information of the tomcat process
sudo -u {{common.user_apigateway}} jstack $tomcatPID > $threadDumpFile

threads=`getThreadNum`
blockedThreads=`getBlockedThreadNum`

if [ ${threads} -eq 0 ]; then
    echo 0
else
    echo $(($blockedThreads * 100 / $threads))
fi

