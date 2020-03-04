#!/bin/bash
umount /home/iotest
echo "d
n
p
1


w
" | fdisk /dev/sde && mkfs -t ext4 /dev/sde1
partprobe

sleep 2
mount /dev/sde1 /home/iotest
sleep 1
qemu-img create -f raw /home/iotest/iotest.img 80G
