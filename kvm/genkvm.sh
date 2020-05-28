#!/bin/sh

if [ $# -lt 2 ];then
echo $0 name qcow2file
exit
fi

name=tmp-`date +%m%d%H`

if [[ "y$1" != "y" ]];then
	name=$1-`date +%m%d%H`
fi

qemu-img create -f qcow2 $name.qcow2 -o backing_file=/wlm/guest/$2

cp 73.xml $name.xml

# batch replace
perl -p -i -e "s/7.3_wlm/$name/" $name.xml




ip=''

for i in `seq 88 254`; do 
ip=11.0.0.$i
# arping
# -w deadline time between ping
# -c count
# -q non-print
# -v print
# -I device
arping $ip -I br-int -w 0.1 -c 1 -q 
if [ $? -eq 1 ];then
echo got unused ip $ip
break
fi
done

cat > /tmp/ifcfg-eth0 <<EOF
DEVICE="eth0"                                                                                                                             
BOOTPROTO="none"
ONBOOT="yes"
TYPE="Ethernet"
IPADDR=$ip
NETMASK=255.255.255.0
GATEWAY=11.0.0.2
EOF

>/tmp/70-persistent-net.rules


virt-copy-in -a $name.qcow2  /tmp/70-persistent-net.rules  /etc/udev/rules.d/
virt-copy-in -a $name.qcow2  /tmp/ifcfg-eth0  /etc/sysconfig/network-scripts/

virsh create $name.xml

virsh vncdisplay $name
