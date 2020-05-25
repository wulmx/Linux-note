#!/bin/bash

rm -rf testdata
gcc -o write write.c
./write &
echo `pidof write` 
debugfs=/sys/kernel/debug
echo nop > $debugfs/tracing/current_tracer
echo > $debugfs/tracing/trace
echo 0 > $debugfs/tracing/tracing_on
echo `pidof write` > $debugfs/tracing/set_ftrace_pid
echo function_graph > $debugfs/tracing/current_tracer
echo vfs_write > $debugfs/tracing/set_graph_function
echo vfs_read >> $debugfs/tracing/set_graph_function
#echo vfs_fsync >> $debugfs/tracing/set_graph_function
echo 1 > $debugfs/tracing/tracing_on
cat $debugfs/tracing/set_graph_function
cat $debugfs/tracing/set_ftrace_pid
