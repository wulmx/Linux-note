#!/bin/bash

rm -rf testsrc
dd if=/dev/zero of=./testsrc bs=1K count=1
touch testaio
gcc -o aio -laio aio.c
./aio testsrc testaio &
echo `pidof aio` 
debugfs=/sys/kernel/debug
echo nop > $debugfs/tracing/current_tracer
echo > $debugfs/tracing/trace
echo 0 > $debugfs/tracing/tracing_on
echo `pidof aio` > $debugfs/tracing/set_ftrace_pid
echo function_graph > $debugfs/tracing/current_tracer
echo io_submit_one > $debugfs/tracing/set_graph_function
#echo __x64_sys_io_submit >> $debugfs/tracing/set_graph_function
echo 1 > $debugfs/tracing/tracing_on
cat $debugfs/tracing/set_graph_function
cat $debugfs/tracing/set_ftrace_pid
