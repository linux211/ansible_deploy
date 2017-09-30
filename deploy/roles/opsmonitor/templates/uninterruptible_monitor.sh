#!/bin/bash

umask 0077 

a=$(ps -eo stat,cmd | egrep "{{process}}" | awk '{print $1}'| grep D | wc -l)

if [[ a -ge 1 ]]; then
    a=1
fi
echo $a