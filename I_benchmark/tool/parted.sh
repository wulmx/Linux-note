#!/bin/sh


usage() {
cat <<EOF
# add by wulm at 20180829
# para1	->	DISK name
# para2	->	DISK size
# para3	->	DISK type
# para4	->	DISK count
EOF
}

if [[ $1 == "-h" ]];then
	usage
	exit 0
fi
DISK=$1
DISK_SIZE=$2
DISK_NUM=$4

function clean_disk()
{
	# umount
	for i in `seq 1 $DISK_NUM`
	do
	  umount /dev/${DISK} &>/dev/null
	  umount /dev/${DISK}$i &>/dev/null
	done
	local part_num=0
	local part_list=`ls /dev/ | grep $DISK`
	for part in $part_list
	do
		if [ "$part" != "$DISK" ];then
			umount /dev/$part 2> /dev/null 
			part_num=`expr $part_num + 1`
		fi
	done
	for i in `parted -s /dev/$DISK print | grep -A10 "Number  Start" | grep -v "Number" | awk '{if($1!=""){print $1}}'`
	do
		parted -s /dev/$DISK rm $i
	done
	echo "clean disk /dev/$DISK"	
}


clean_disk

declare -i DISK_SIZE00=$DISK_SIZE

	LIST=`parted /dev/$DISK p | awk '{print $1}'`
        for NUMBER in `echo $LIST`
	do
		echo $NUMBER | grep ^[0-9]
		if [ $? = 0 ]; then
			parted /dev/$DISK rm $NUMBER
		fi
	done

	echo "parted -s /dev/$1 mklabel msdos"
	parted -s /dev/$1 mklabel msdos

	declare -i COUNT=1
	declare -i START=1   # <- this must don't use 0, otherwise IO performance will dgrade above 80%
	declare -i END=${DISK_SIZE}000

	parted -s /dev/$1 mklabel gpt
	while [ $COUNT -le $DISK_NUM ]
	do
		#echo "parted -s /dev/$1 mkpart primary ext2 $START $END"
		parted -s /dev/$1 mkpart primary $3 $START $END
		#parted -s /dev/$1 mkpart $COUNT $START $END
		START=`expr $END + 1`
		END=`expr $START + ${DISK_SIZE}000`
		COUNT=`expr $COUNT + 1`
	done
	partprobe

# format
for i in `seq 1 $DISK_NUM`
do
  # since sometime mkfs fail, so add -f option
	if [[ $3 = "xfs" ]] || [[ $3 = "btrfs" ]]; then
  		mkfs -t $3 -f /dev/${1}$i &>/dev/null  
	else
  		mkfs -t $3 /dev/${1}$i &>/dev/null  
	fi
done

mount /dev/sde1 /home/iotest/
qemu-img create -f raw /home/iotest/iotest.img 80G

