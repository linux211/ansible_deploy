#!/bin/bash
umask 0077

ps -eo stat,cmd | egrep "{{process}}" | awk '{print $1}'| grep Z |wc -l
