#!/bin/sh
for((i = 0; i < 40; i++))
do
    ps -C tsched -o pid,pri,cmd,time,psr,%cpu,%mem,stat >>psinfo.log 2>&1
    sleep 2;
done
