#!/bin/bash
file=$1
MODE=`ls $file/`
for mode in $MODE
do
	if [[ $2 == '-V' ]]; then
		echo "-----------mode=$mode-------------"
		cat $file/$mode/round-*/log_fio.log | grep -E "iops|sys"
		cat $file/$mode/round-*/log_fio.log | grep " lat" | grep avg
	fi
	
	# get iops 
	cat $file/$mode/round-*/log_fio.log | grep iops | awk 'BEGIN{FS=","}{print $3}' | awk -v v1=$mode 'BEGIN{FS="=";sum=0;num=0 } {sum=sum+$2; num++} END {split(v1, a, "-"); if(a[3] == "randrw") printf("%d", sum/num*2); else printf("%d", sum/num)}'
	
	# get bw
	cat $file/$mode/round-*/log_fio.log | grep iops | awk -F',|KB/s' '{print $2}'| awk -v v1=$mode 'BEGIN {FS="=";sum=0;num=0} {if (substr($2, length($2)-2, 1) == "B") sum = sum + substr($2, 0, length($2) -3)/1024; else sum=sum+$2; num++} END {split(v1, a, "-"); if(a[3] == "randrw") printf(" %.2f", sum/num/1024*2); else printf(" %.2f", sum/num/1024)}'
	
	# get latency, =await=io_service_time
	cat $file/$mode/round-*/log_fio.log | grep " lat" | grep avg | awk -v v1=$mode -F"avg=" 'BEGIN {sum=0;num=0} {sum=sum+$2; num++} END {split(v1, a, "-"); if(a[3] == "randrw") printf(" %.2f", sum/num*2); else printf(" %.2f", sum/num)}'
	
	# get usr%
	cat $file/$mode/round-*/log_fio.log | grep  sys  | awk -F"usr=|%" 'BEGIN{sum=0;num=0}{sum=sum+$2;num++}END{printf(" %.2f", sum/num)}'
	
	# get sys%
	cat $file/$mode/round-*/log_fio.log | grep  sys  | awk -F"sys=|%" 'BEGIN{sum=0;num=0}{sum=sum+$3;num++}END{printf(" %.2f", sum/num)}'
	
	echo  " ----------mode=$mode ----------"
done
