#!/bin/bash
#
# Program:
#	 Get system's performance info with out kvm_stat and 
#        virt-top
# History:
#	 wulm 2018/1/29 1.0v
#
export LANG=C

if [ "$#" != 1 ];then 

    echo "Parameter is wrong."
    echo "Usage: $0  <LOG_DIR> "
    echo "Waring: "LOG_DIR" need relative or absolute PATH."
    exit 1

fi

LOG=$1
DIR=`dirname $0`
<<EOF
which getPerfInfo.sh >/dev/null 2>&1
if [ $? != 0 ]; then
    rpm -ivh $DIR/FJSVgetperfinfo-2.6-1.noarch.rpm --force
    if [ $? -ne 0 ]; then
        echo "ERROR: FJSVgetperfinfo install failed, please check the reason."
        exit 1
    fi
else
    VER=`getPerfInfo.sh -v | awk '{print $3}'`
    if [ ${VER} != "2.6-1" ]; then
        rpm -ivh $DIR/FJSVgetperfinfo-2.6-1.noarch.rpm --force
        if [ $? -ne 0 ]; then
           echo "ERROR: FJSVgetperfinfo install failed, please check the reason."
           exit 1
        fi
    fi
fi
EOF
mkdir -p ${LOG}
cp $DIR/getPerfInfo.sh /usr/bin
#getPerfInfo.sh --novirttop --nokvm -d  ${LOG}/"getperfinfo" 5 30000 &
getPerfInfo.sh --novirttop  -d  ${LOG}/"getperfinfo" 5 30000 &

