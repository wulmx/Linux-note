#!/bin/sh
#################################################################################
#                 Collection tool of performance information.		        #
#									        #
#                                  Ver 2.0                add iotop information #
#                                      2.1-1        add kvm related information #
#                                      2.1-2             modify top information #
#                                      2.2-1  add -n option into iostat command #
#                                      2.3-1  add rotated collection function   #
#                                      2.4-1  modify iotop information defaultly#
#	         not to be collected and make getPerfInfo suit to RHEL7   	#
#                                      2.5-1  change the method of collecting   #
#                           performance information and add --novirttop option  #
#                                      2.5-2  change the method of checking the #
#                                               rotated collection double start #
#                                      2.5-3  add the check of pgrep's return   #
#                                             value                             #
#                                      2.5.4  modify the method of checking     #
#                 whether the top, iotop and virt-top commands are valid or not #
#                                                                               #
#################################################################################
LANG=C
export LANG

PATH="/usr/bin:/bin:/usr/sbin:/sbin:$PATH"
export PATH

COMMANDNAME=`basename $0`

### Version of this tool ###
VERSION="2.6-1"

MPSTAT_ID=-1
SAR_ID=-1
IOSTAT_ID=-1
NFSIOSTAT_ID=-1
TOP_ID=-1
IOTOP_ID=-1
CAE_ID=-1
VIRT_TOP_ID=-1

TOOL_DIR="."
TEMPDIR=""
EXEC_FLAG=0
COLUMNS_NUM=80
ROTATION_DIR_NAME=/var/log/FJSVgetperfinfo
#----------------------------------------------------------------------------
# Output usage
#----------------------------------------------------------------------------
LP_help() {
	cat <<EOT
$@

USAGE:
    $COMMANDNAME [ --notop ] [ --iotop | --noiotop ] [ --novirttop ]
                 [ --netstat ][ -d outdir | -z outfile ] interval count
    $COMMANDNAME --kill PID
    $COMMANDNAME --rstart [ -r rotation ] [ --notop ] [ --iotop | --noiotop ]
                 [ --novirttop ][ --netstat ] interval count
    $COMMANDNAME --rstop 
    $COMMANDNAME -v

    OPTION:
      --nokvm     : Do not get kvm_stat information.
      --notop     : Do not get top information.
                    Default is collected.
      --iotop     : Get iotop information.
                    Default is not collected. 
      --noiotop   : Do not get iotop information.
                    Default is not collected.
      --novirttop : Do not get virttop information.
                    Default is collected.    
      --netstat   : Get netstat information.
                    Default is not collected.
      -d outdir   : Output directory.
                    If the file does not exist it will be created.
                    it can not be used for rotated collection.
      -z outfile  : Output archive and compressed file.
                    The format is tar.gz.
                    If neither of (-d | -z) parameters is specified,
                    performance information is collected in
                    /tmp/perf<current_date>.
                    Only one of (-d | -z) option can be selected.
                    it can not be used for rotated collection.
      interval    : A sampling period of interval.
      count       : The  number of updates.
      --kill      : Force stop by specifying PID of $COMMANDNAME.
                    it can not be used for rotated collection.
      --rstart    : rotated collection start.
      --rstop     : rotated collection stop.
      -r rotation : count of ratation if this option is not specified, 
  		    the default is 7.
		    this option must be between 1 and 1000.
      -v          : Show version information of $COMMANDNAME.
		    
    EX: 30 count every 60 seconds. (It may be 1800 seconds)
      $COMMANDNAME  60  30
      $COMMANDNAME  -d perfdir  60  30
      $COMMANDNAME  -z perf.tar.gz  60  30
      
    EX: Starting rotated collection, once every 60 seconds, 1440 times of
   	collection per round, 7 perfinfo-YYYYMMDDHHMMSS.tar.gz keeped.
      $COMMANDNAME  --rstart 60 1440
EOT
}

#----------------------------------------------------------------------------
# Check specified digit
#----------------------------------------------------------------------------
LP_Check_Digit(){
	DIGIT=$1

	echo ${DIGIT} | awk '{
		for(i=1;i<length($0)+1;i++){
			if(substr($0,i,1) !~ /[[:digit:]]/){
				exit 1
			}
		}
		exit 0
	}'
	return $?
}

# check file(s) exist
# return value
# 0: file does not exist
# 1: file exists -> output error message and exit 1
chk_file_exist() {
	FILE_PATH=$1
	if [ -e "$FILE_PATH" ]; then
		echo "ERROR: Specified file or directory ($FILE_PATH) already exists."
		exit 1
	fi
	return 0
}

# check directory exist
# return value
# directory is created when directory does not exist
chk_directory_exist() {
	FILE_PATH=$1           
	if [ ! -d "$FILE_PATH" ]; then
		mkdir -p $FILE_PATH
	fi
}

#----------------------------------------------------------------------------
# Process collected files
#----------------------------------------------------------------------------
LP_ProcessFiles(){
	if [ "$1" != "" ]; then
		### Convert sar information into text file ###
		sar -A -f "$1/sar-A_$DATE"	> "$1/sar-A_$DATE.txt" 2>/dev/null
		
		### Collect df, ps and cmdline information when programme ends ###
		echo			>>	"$1/df-hTP_$DATE"
		echo `date "+%T %x"`	>>	"$1/df-hTP_$DATE"
		df -hTP			>>	"$1/df-hTP_$DATE"
		echo			>>	"$1/ps_aux_$DATE"
		echo `date "+%T %x"`	>>	"$1/ps_aux_$DATE"
		ps aux			>>	"$1/ps_aux_$DATE"
		cat /proc/cmdline	>	"$1/cmdline_$DATE"

		### Compress files ###
		if [ "$2" = "-z" ]; then
			DIR_NAME=`dirname $1`
			BASE_DIR=`basename $1`
			tar -czvf $3 -C $DIR_NAME $BASE_DIR  > /dev/null 2>&1
			rm -rf $1
		fi
	fi
}

#----------------------------------------------------------------------------
# Delete the unneed rotation tmp file
#----------------------------------------------------------------------------
DEL_UNneed_TMP(){
	### Delete the unneeded rotation tmp file ###
	Del_tmp_list=`find ${ROTATION_DIR_NAME}/ -name "perfinfo-[0-9][0-9][0-9][0-9][0-1][0-9][0-3][0-9][0-2][0-9][0-5][0-9][0-6][0-9].tmp.tar.gz" | sort | awk '{print $1}'`
	for del_tmp in $Del_tmp_list
	do
		rm -rf "$del_tmp"
	done
}

#----------------------------------------------------------------------------
# Delete the unneed rotation directory
#----------------------------------------------------------------------------
DEL_UNneed_DIR(){
	### Delete the unneeded rotation tmp file ###
	Del_dir_list=`find ${ROTATION_DIR_NAME}/ -name "perf[0-9][0-9][0-9][0-9][0-1][0-9][0-3][0-9][0-2][0-9][0-5][0-9][0-6][0-9]" | awk '{print $1}'`

	Perf_list=`find ${ROTATION_DIR_NAME}/ -name "perfinfo-[0-9][0-9][0-9][0-9][0-1][0-9][0-3][0-9][0-2][0-9][0-5][0-9][0-6][0-9].tar.gz" | sort | awk '{print $1}'`
	
	for dir in $Del_dir_list
	do
		del_dir=`basename $dir`
		del_dir_date=`expr substr "$del_dir" 5 14`

		for perf_tar in $Perf_list
		do
			perf_tar=`basename $perf_tar`
			perf_tar_date=`expr substr "$perf_tar" 10 14`
			if [ $del_dir_date = $perf_tar_date ]; then
				rm -rf "$dir"
				break
			fi
		done
	done
}

#----------------------------------------------------------------------------
# Delete the unneed rotation file
#----------------------------------------------------------------------------
DEL_UNneed_ROT(){
	count=`find ${ROTATION_DIR_NAME}/ -name "perfinfo-[0-9][0-9][0-9][0-9][0-1][0-9][0-3][0-9][0-2][0-9][0-5][0-9][0-6][0-9].tar.gz" | wc -l | awk '{print $1}'`

	### Delete the unneeded rotation file ###
	if [[ $count -ge $ROTATION ]]; then
		Del_Perf_list=`find ${ROTATION_DIR_NAME}/ -name "perfinfo-[0-9][0-9][0-9][0-9][0-1][0-9][0-3][0-9][0-2][0-9][0-5][0-9][0-6][0-9].tar.gz" | sort | head -$[count - ROTATION + 1] | awk '{print $1}'`
		for del_perf in $Del_Perf_list
		do
			rm -rf "$del_perf"
		done
	fi 	
}

#----------------------------------------------------------------------------
# Process collected files for rotated collection
#----------------------------------------------------------------------------
LP_CompressFilesForRotation(){
	### Delete the unneeded rotation file ###
	DEL_UNneed_ROT

	### Compress files ###	
	BEFORE_DIR=`pwd | awk '{print $1}'`
	DIR_NAME=`dirname $1`
	BASE_DIR=`basename $1`
	BASE_DIR_DATE=`expr substr "$BASE_DIR" 5 14`
	cd $DIR_NAME
	COM_SUC=1

	### archive the tar.gz file ###
	tar -czvf ${ROTATION_DIR_NAME}/perfinfo-"$BASE_DIR_DATE".tmp.tar.gz  $BASE_DIR  >/dev/null 2>&1
	COM_SUC=$?


	### Delete the directory when tar successfully ###
	if [ $COM_SUC = 0 ]; then 
		mv ${ROTATION_DIR_NAME}/perfinfo-"$BASE_DIR_DATE".tmp.tar.gz ${ROTATION_DIR_NAME}/perfinfo-"$BASE_DIR_DATE".tar.gz
		rm -rf $1
	### Delete the .tar.gz file when fail to tar ###
	else
		rm -rf ${ROTATION_DIR_NAME}/perfinfo-"$BASE_DIR_DATE".tmp.tar.gz
		### Stop getPerfInfo's process when file to tar, maybe the capacity of disk is not enough###
		echo "WARNING: Directory failed to be archived(${ROTATION_DIR_NAME}/${BASE_DIR})."
		Stop_ROTATION &
	fi

	cd "$BEFORE_DIR"
}

#----------------------------------------------------------------------------
# Complete Messages
#----------------------------------------------------------------------------
LP_EndMsg() {
	echo "INFO: Performance information has collected."
	if [ $OUT_OPT = "-d" ];then
		echo "      Check the $TEMPDIR"
	else
		echo "      Check the $OUTFILE"
	fi
	echo -n "End time: " 
	echo `date "+%T %x"`
}

#----------------------------------------------------------------------------
# Kill all child processes
#----------------------------------------------------------------------------
LP_killtool() {
	if [ $MPSTAT_ID != -1 ]; then
		kill -15 $MPSTAT_ID >/dev/null 2>&1
	fi
	echo -n "."
	if [ $SAR_ID != -1 ]; then
		SADC_ID=`ps -eo pid,ppid,comm | grep sadc | grep -w $SAR_ID | head -1 | awk '{printf $1}'`
		kill -15 $SADC_ID >/dev/null 2>&1
	fi
	echo -n "."
	if [ $IOSTAT_ID != -1 ]; then
		kill -15 $IOSTAT_ID >/dev/null 2>&1
	fi
	echo -n "."
	if [ $NFSIOSTAT_ID != -1 ]; then
		kill -15 $NFSIOSTAT_ID >/dev/null 2>&1
	fi
	echo -n "."
	if [ $TOP_ID != -1 ]; then
		kill -15 $TOP_ID >/dev/null 2>&1
	fi
	echo -n "."
	if [ $IOTOP_ID != -1 ]; then
		kill -15 $IOTOP_ID >/dev/null 2>&1
	fi
	echo -n "."
	if [ $CAE_ID != -1 ]; then
		kill -15 $CAE_ID >/dev/null 2>&1
	fi
	echo -n "."
	if [ $VIRT_TOP_ID != -1 ]; then
		kill -15 $VIRT_TOP_ID >/dev/null 2>&1
	fi
	echo -n "."

}

#----------------------------------------------------------------------------
# Receive Ctrl+C or Interrupt Signal
#----------------------------------------------------------------------------
LP_dispatch_signal() {
	echo -n "Interrupt signal received. Stopping $COMMANDNAME. "
	LP_killtool

	LP_ProcessFiles $TEMPDIR $OUT_OPT $OUTFILE
	if [ $rotation_Flag = 0 ]; then 
		LP_EndMsg
		echo ". Success."
	fi
	exit 1
}

#----------------------------------------------------------------------------
# For stopping perf tool.
# get the child process's PID
# USAGE:
#    getPerfInfo --kill <pid of getPerfInfo>
#
#    --kill: Kill the perf tool.
#    pid of getPerfInfo.sh: Pid which excute the perf tool.
#----------------------------------------------------------------------------
LP_Get_Child_PID() {
	TOOLS_PID=$1

	SAR_ID=`ps -eo pid,ppid,comm | grep sar | grep $TOOLS_PID | head -1 | awk '{printf $1}'`
	if [ -z "$SAR_ID" ]; then
		SAR_ID=-1
	fi
	
	MPSTAT_ID=`ps -eo pid,ppid,comm | grep mpstat | grep $TOOLS_PID | head -1 | awk '{printf $1}'`
	if [ -z "$MPSTAT_ID" ]; then
		MPSTAT_ID=-1
	fi

	IOSTAT_ID=`ps -eo pid,ppid,comm | grep iostat | grep $TOOLS_PID | head -1 | awk '{printf $1}'`
	if [ -z "$IOSTAT_ID" ]; then
		IOSTAT_ID=-1
	fi
	
	NFSIOSTAT_ID=`ps -eo pid,ppid,comm | grep nfsiostat | grep $TOOLS_PID | head -1 | awk '{printf $1}'`
	if [ -z "$NFSIOSTAT_ID" ]; then
		NFSIOSTAT_ID=-1
	fi

	TOP_ID=`ps -eo pid,ppid,comm | grep top | grep $TOOLS_PID | head -1 | awk '{printf $1}'`
	if [ -z "$TOP_ID" ]; then
		TOP_ID=-1
	fi
	
	IOTOP_ID=`ps -eo pid,ppid,comm | grep iotop | grep $TOOLS_PID | head -1 | awk '{printf $1}'`
	if [ -z "$IOTOP_ID" ]; then
		IOTOP_ID=-1
	fi

	CAE_ID=`ps -eo pid,ppid,comm | grep perfex | grep $TOOLS_PID | head -1 | awk '{printf $1}'`
	if [ -z "$CAE_ID" ]; then
		CAE_ID=-1
	fi

	VIRT_TOP_ID=`ps -eo pid,ppid,comm | grep virt-top | grep $TOOLS_PID | head -1 | awk '{printf $1}'`
	if [ -z "$VIRT_TOP_ID" ]; then
		VIRT_TOP_ID=-1
	fi
}

#----------------------------------------------------------------------------
# For stopping perf tool.
# USAGE:
#    getPerfInfo --kill <pid of getPerfInfo>
#
#    --kill: Kill the perf tool.
#    pid of getPerfInfo.sh: Pid which excute the perf tool.
#
#    EX:
#    getPerfInfo --kill 8892
#----------------------------------------------------------------------------
LP_pkilltool() {
	TOOLS_PID=$1
	
	## get the child process's PID
	LP_Get_Child_PID $TOOLS_PID
	
 	if [[ "${Stop_Service_Flag}" = 0 ]]; then
		GPID=`lsof -p $TOOLS_PID -g | grep $COMMANDNAME | head -1 | awk '{print $3}'`
		SADC_ID=`ps -eo pid,ppid,comm | grep sadc | grep -w $SAR_ID | head -1 | awk '{printf $1}'`
		DATE=`lsof -g $GPID | grep sar-A | grep $SADC_ID | head -1 | awk -F"sar-A_" '{print $2}'`
		OUTFILE=`ps aux | grep $TOOLS_PID | head -1 | awk -F"-z " '{print $2}' | awk '{print $1}'`
		if [ -z "$OUTFILE" ];then
			OUT_OPT="-d"
			TEMPDIR=`lsof -g $GPID | grep $SADC_ID | grep sar-A | head -1 | awk -F"sar-A_" '{print $1}' | awk '{print $10}'`
			if [ -z "$TEMPDIR" ];then
				TEMPDIR="/tmp/perf$DATE"
			fi
		else
			OUT_OPT="-z"
			TEMPDIR="/tmp/perf$DATE"
			if [ "${OUTFILE::1}" != "/" ]; then
				CWD=`lsof -g $GPID | grep cwd | grep $TOOLS_PID | head -1 | awk '{print $10}'`
				OUTFILE=$CWD/$OUTFILE
			fi
		fi
	fi
	LP_killtool >/dev/null 2>&1
	kill -9 $TOOLS_PID >/dev/null 2>&1
	
	### the situation of not rotated collection ###
	if [[ ! -z "$rotation_Flag" ]] && [[ "$rotation_Flag" = 0 ]] && [[ "${Stop_Service_Flag}" = 0 ]]; then
		LP_ProcessFiles $TEMPDIR $OUT_OPT $OUTFILE
		echo -n "End time: " 
		echo `date "+%T %x"`
		exit 0
	else
		dir_rotation_save=`find ${ROTATION_DIR_NAME}/ -name "perf[0-9][0-9][0-9][0-9][0-1][0-9][0-3][0-9][0-2][0-9][0-5][0-9][0-6][0-9]" | awk '{print $1}' | sort -r | head -1`
		if [[ -d ${dir_rotation_save} ]]; then
			if [[ `ls -a $dir_rotation_save | wc -l` -gt 2 ]]; then
				BASE_DIR=`basename $dir_rotation_save`
				DATE=`expr substr "$BASE_DIR" 9 10`

				LP_ProcessFiles $dir_rotation_save
			else
				## delete the null diretory ##
				rm -rf $dir_rotation_save
			fi
		fi
	fi
}

#----------------------------------------------------------------------------
# Collect Other Information
#----------------------------------------------------------------------------
LP_Collect_Other_Information() {
	TIME=$1

	echo "Time: $TIME"   >>  "$TEMPDIR/meminfo_$DATE"
	echo "Time: $TIME"   >>  "$TEMPDIR/slabinfo_$DATE"
	echo "Time: $TIME"   >>  "$TEMPDIR/ipcs_$DATE"
	echo "Time: $TIME"   >>  "$TEMPDIR/ipcs-u_$DATE"
#	echo "Time: $TIME"   >>  "$TEMPDIR/netstat_$DATE"
	echo "Time: $TIME"   >>  "$TEMPDIR/nfsstat-c_$DATE"
	echo "Time: $TIME"   >>  "$TEMPDIR/buddyinfo_$DATE"
	echo "Time: $TIME"   >>  "$TEMPDIR/interrupts_$DATE"
	cat /proc/meminfo    >>  "$TEMPDIR/meminfo_$DATE"

	### xen kernel add HugePages information ###
	uname -r | grep xen > /dev/null
	if [ $? = 0 ]; then
		echo "HugePages_Total:    0"		>>  "$TEMPDIR/meminfo_$DATE"
		echo "HugePages_Free:     0"		>>  "$TEMPDIR/meminfo_$DATE" 
		echo "HugePages_Rsvd:     0"    	>>  "$TEMPDIR/meminfo_$DATE"
		echo "Hugepagesize:       0 kB"		>>  "$TEMPDIR/meminfo_$DATE"
	fi

	### Collect zoneinfo ###
	if [ -f /proc/zoneinfo ]; then
		echo "Time: $TIME"   >>  "$TEMPDIR/zoneinfo_$DATE"
		cat /proc/zoneinfo   >>  "$TEMPDIR/zoneinfo_$DATE"
	fi

	### Collect nfs client info ###
	nfsstat -c > /dev/null 2>&1
	if [ $? = 0 ]; then
		nfsstat -c	>>    "$TEMPDIR/nfsstat-c_$DATE"
	else
		echo "no \"nfsstat -c\" information specified "	>>	"$TEMPDIR/nfsstat-c_$DATE"
	fi

	cat /proc/slabinfo   >>  "$TEMPDIR/slabinfo_$DATE"
	ipcs                 >>  "$TEMPDIR/ipcs_$DATE"
	ipcs -u              >>  "$TEMPDIR/ipcs-u_$DATE"
#	netstat -an          >>  "$TEMPDIR/netstat_$DATE"
	cat /proc/buddyinfo  >>  "$TEMPDIR/buddyinfo_$DATE"
	cat /proc/interrupts >>  "$TEMPDIR/interrupts_$DATE"

	### Collect numastat info ###
	numastat > /dev/null 2>&1
	if [ $? = 0 ];then
		echo "Time: $TIME"    >>  "$TEMPDIR/numastat_$DATE"
		numastat              >>  "$TEMPDIR/numastat_$DATE"
	fi

	### Collect kvm_stat info ###
	if [ $KVM_STAT_COM = 1 ];then
		echo "Time: $TIME"    >>  "$TEMPDIR/kvm_stat_$DATE"
		kvm_stat --once       >>  "$TEMPDIR/kvm_stat_$DATE" &
	fi

	### Collect ksm info ###
	if [ -d /sys/kernel/mm/ksm ];then
		echo "$TIME"    >>  "$TEMPDIR/ksminfo_$DATE"
		for file in `ls /sys/kernel/mm/ksm/`; do
			printf "${file}:\t"    >>  "$TEMPDIR/ksminfo_$DATE"
			cat /sys/kernel/mm/ksm/${file}  >>  "$TEMPDIR/ksminfo_$DATE"
		done
	fi

	### Collect netstat info ###
	if [ $NETSTAT_COM = 1 ];then
		echo "Time: $TIME"   >>  "$TEMPDIR/netstat_$DATE"
		netstat -an          >>  "$TEMPDIR/netstat_$DATE"
	fi

}

#----------------------------------------------------------------------------
# Stop getPerfInfo's ROTATION_000 process
#----------------------------------------------------------------------------
Stop_ROTATION_000() {
	if [ ! -z "$1" ]; then 
		echo "INFO: GetPerfInfo rotated collection is stopping........."
		for collRotPid in $1
		do	
			if [ -f /proc/${collRotPid}/status ]; then
				kill -9 ${collRotPid} > /dev/null 2>&1
				if [ $? = 0 ]; then
					Kill_Suc=$[Kill_Suc + 1]
				fi
			fi	
		done
	fi
}

#----------------------------------------------------------------------------
# Stop getPerfInfo's ROTATION_001 process
#----------------------------------------------------------------------------
Stop_ROTATION_001() {
	if [[ ! -z "$1" ]]; then
		for collProPid in $1
		do	
			if [ -f /proc/${collProPid}/status ]; then
				LP_pkilltool $collProPid > /dev/null 2>&1
				if [ $? = 0 ]; then
					Kill_Suc=$[Kill_Suc + 1]
				fi
			fi
		done	
	fi
}

#----------------------------------------------------------------------------
# Stop getPerfInfo's ROTATION process
#----------------------------------------------------------------------------
Stop_ROTATION() {
	### Get rotation service process pid ###
	TOOLS_ID_000=`ps aux | grep "${COMMANDNAME} ROTATION_000" | grep -v grep | awk '{print $2}'`

	### Get getPerfInfo collection process pid ###
	TOOLS_ID_001=`ps aux | grep "${COMMANDNAME} ROTATION_001" | grep -v grep | awk '{print $2}'`
	
	### the situation that ROTATION_000 and ROTATION_001 process's pid are not exist ###
	if [[ -z "${TOOLS_ID_000}" ]] && [[ -z "${TOOLS_ID_001}" ]]; then
		echo "INFO: GetPerfInfo rotated collection has not been started."
		exit 1
	fi
	
	### the count of kill ROTATION_000 process or ROTATION_001 process ###
	Kill_Suc=0
	
	### stop the rotation service process ###
	Stop_ROTATION_000 $TOOLS_ID_000
	
	Stop_Service_Flag=1 

	### stop the collection of getPerfInfo process ###
	Stop_ROTATION_001 $TOOLS_ID_001

	if [ ${Kill_Suc} -gt 0 ]; then  
		echo "INFO: GetPerfInfo rotated collection has been stopped."
		exit 0
	fi		
}

#----------------------------------------------------------------------------
# Stop getPerfInfo's ROTATION process 
# Usage
#      kill -15 pid(ROTATION_000 proceess's pid)
#----------------------------------------------------------------------------
Term_ROTATION() {
	### stop the rotation service process ###
	### Get rotation service process pid ###
	TOOLS_ID_000=`ps aux | grep "${COMMANDNAME} ROTATION_000" | grep -v grep | awk '{print $2}'`
	Stop_ROTATION_000 $TOOLS_ID_000
	echo "INFO: GetPerfInfo rotated collection has been stopped."
}

#----------------------------------------------------------------------------
# Start getPerfInfo's rotation services
#----------------------------------------------------------------------------
Rotation_Service() {
	### 0: is  before collect data; 1: is not before collect data ###
	Com_Bef_Flag=0
	
	### get the rotation's value ###
	ROTATION=$3

	### directory is created when directory does not exist ###
	chk_directory_exist ${ROTATION_DIR_NAME}

	### Delete the unneeded rotation tmp file ###
	DEL_UNneed_TMP

	### Delete the unneeded rotation directory ###
	DEL_UNneed_DIR

	### Delete the unneeded rotation file ###
	DEL_UNneed_ROT

	### check the not archived directory for stop or restart sever ###
	if [ -d ${ROTATION_DIR_NAME} ]; then
		dir_rotation_save_list=`find ${ROTATION_DIR_NAME}/ -name "perf[0-9][0-9][0-9][0-9][0-1][0-9][0-3][0-9][0-2][0-9][0-5][0-9][0-6][0-9]" | awk '{print $1}' | sort -r `
		for dir_rotation_save in $dir_rotation_save_list
		do
			if [[ -d ${dir_rotation_save} ]]; then
				if [[ `ls -a $dir_rotation_save | wc -l` -gt 2 ]]; then
					### Manage the rotation ###
					LP_CompressFilesForRotation $dir_rotation_save
				else
					## delete the null diretory ##
					rm -rf $dir_rotation_save
				fi
			fi
		done
	fi
	
	Com_Bef_Flag=1

	### the RORATION_000 process interrupt ###
	## KILL: Kill signal(9) The signals SIGKILL cannot be caught##
	## TERM: Termination signal(15) ##
	trap "Term_ROTATION &" 15

	while [ 1 = 1 ]
	do
		### getPerfInfo process start to collect data ###
		$COMMANDNAME ROTATION_001 ${@:4} 2>/dev/null

		## begin archive the collect data ##
		dir_rotation_save_list=`find ${ROTATION_DIR_NAME}/ -name "perf[0-9][0-9][0-9][0-9][0-1][0-9][0-3][0-9][0-2][0-9][0-5][0-9][0-6][0-9]" | awk '{print $1}' | sort -r`

		for dir_rotation_save in $dir_rotation_save_list
		do
			if [ -d ${dir_rotation_save} ]; then
				if [[ `ls -a $dir_rotation_save | wc -l` -gt 2 ]] ; then	
					LP_CompressFilesForRotation $dir_rotation_save &	
				else 
					## delete the null diretory ##
					rm -rf $dir_rotation_save
				fi
			fi
		done
	done
}

#----------------------------------------------------------------------------
#      Main start of getperfinfo collection process
#----------------------------------------------------------------------------
### get the rotation flag ###
rotation_Flag=0
if [[ ! -z $1 ]] &&  [[ "$1" = "ROTATION_001" ]]; then
	rotation_Flag=1
	## option's shift ##
	shift
fi

## start the rotation service process  ##
if [[ $1 = "ROTATION_000" ]]; then
	Rotation_Service $@ 
fi

### RPM package check ###
rpm -q sysstat >/dev/null 2>&1
if [ $? != 0 ]; then
	echo "ERROR: Sysstat package is not installed."
	exit 1
fi

### No parameter -> display usage ###
if [ $# -eq 0 ]; then
	LP_help "ERROR: Parameter is not specified." >&2
	exit 1

### Too many parameter -> display usage ###
elif [ $# -gt 10 ]; then
	LP_help "ERROR: There are too many parameters." >&2
	exit 1

fi

DATE=`date +%m%d%H%M%S`
ROT_DATE=`date +%Y%m%d%H%M%S`
DATA_DATE=`/bin/date "+%Y/%m/%d"`

declare  -i INTERVAL=0
declare  -i MAX_COUNT=0
declare  -i COUNT=0
declare  -i IOCOUNT=0
declare  -i BASETIME=0
declare -i ROTATION=7

TOP_COM=0
IOTOP_COM=0
NOIOTOP_COM=0
CAE_COM=0
OPT_FORCE=0
OPT_FILE=0
NETSTAT_COM=0
NOVIRTTOP_COM=0
NOKVM_COM=0
ROTATION_CHECK_FLAG=0

### Set kvm_stat option ###
KVM_STAT_COM=0
#if [[ ${NOKVM_COM} = 0 ]];then
#	kvm_stat --once > /dev/null 2>&1
#	if [ $? = 0 ];then
#		KVM_STAT_COM=1
#	fi
#fi
### Default output option
OUT_OPT="-d"

### Default output directory ###
TEMPDIR="/tmp/perf$DATE"

### Default output file
if [ $rotation_Flag = 1 ]; then
	TEMPDIR="${ROTATION_DIR_NAME}/perf$ROT_DATE"
fi
OUTFILE="/tmp/perf$DATE.tar.gz"

### 1: only interval, 2: count & max ###
FLAG=0

### 0: stop the service faily 1: stop the service successfully ###
Stop_Service_Flag=0

Kill_Suc=0

### save the getPerfInfo's Rotation option ###
CMD_OPTIONS=${@:2}

## --kill parameter ###
if [ $# -eq 2 ] && [ $1 = '-kill' -o $1 = '--kill' ]; then
	TOOLS_ID=$2
 
	### Check specified pid ###
	if [ -f /proc/$TOOLS_ID/status ]; then
 		COMPCOMNAME=`cat /proc/$TOOLS_ID/status 2>/dev/null | head -1 | awk '{printf $2}'`
		if [ "$COMMANDNAME" != "$COMPCOMNAME" ]; then
			echo "Specified pid is not $COMMANDNAME."
			exit 1
		fi
		Process_NM=`ps aux | grep "${TOOLS_ID}" | grep -v grep | grep -v "kill" | awk '{print $13}'`
		if [[ "$Process_NM" != "ROTATION_001" ]] && [[ "$Process_NM" != "ROTATION_000" ]]; then
			LP_pkilltool $TOOLS_ID
			exit 0
		else
			echo "Specified pid is the rotated collection."
			exit 1
		fi
	else
		echo "Specified pid is not existed."
		exit 1
	fi
fi

### Parameter check ###
if [[ "$1" != "" ]] && [[ "$1" = "--rstart" ]]; then
	ROTATION_CHECK_FLAG=1
	TEMPDIR="${ROTATION_DIR_NAME}/perf$ROT_DATE"

	shift
	
	if [[ "$1" != "" ]] && [[ "$1" = "-r" ]]; then
		### Get the value of "-r" ###
		shift
		
		if [ $# = 0 ]; then
			LP_help "ERROR: Rotation's value must be specified correctly." >&2
			exit 1
		fi
		
		LP_Check_Digit $1
		if [ $? != 0 ]; then
			LP_help "ERROR: Specified parameter is not digit." >&2
			exit 1
		else
			if [[ "$1" != "" ]]; then
				if [[ $1 -lt 1 ]] || [[ $1 -gt 1000 ]]; then
					LP_help "ERROR: Rotation parameter should be between 1 and 1000." >&2
					exit 1
				else
					#ROTATION=$1  ### delete for this value can't be transfered into the ROTATION_000 process ###
					shift
				fi 
			fi
		fi
	else
			CMD_OPTIONS='-r 7 '$CMD_OPTIONS
	fi
elif [[ "$1" != "" ]] && [[ $1 = "--rstop" ]]; then 
	if [ $# = 1 ]; then
		### stop the rotation collection ###
		Stop_ROTATION
	else
		LP_help "ERROR: Specified parameter is wrong." >&2
		exit 1
	fi
fi

while [ "$1" != "" ]
do
	if [ -z ${OPTION} ]; then
		if [ `echo @$1 | cut -c2` != "-" ]; then
			case $FLAG in
			0) INTERVAL=$1
			   FLAG=1;;
			1) MAX_COUNT=$1
			   FLAG=2;;
			*) LP_help "ERROR: Specified parameter is wrong." >&2
			   exit 1;;
			esac

			LP_Check_Digit $1
			if [ $? != 0 ]; then
				LP_help "ERROR: Specified parameter is not digit." >&2
				exit 1
			fi

		else
			case $1 in
			--netstat) if [ $NETSTAT_COM = 1 ]; then
				 	LP_help "ERROR: --netstat parameter overlaps." >&2
					exit 1
				else
					### Set netstat command bit ###
					NETSTAT_COM=1
				fi;;
			--notop) if [ $TOP_COM = 1 ]; then
				 	LP_help "ERROR: --notop parameter overlaps." >&2
					exit 1
				else
					### Set top command bit ###
					TOP_COM=1
				fi;;
			--noiotop) if [ $NOIOTOP_COM = 1 ]; then
				 	LP_help "ERROR: --noiotop parameter overlaps." >&2
					exit 1
				else
					### Set iotop command bit ###
					NOIOTOP_COM=1
				fi;;
			--iotop) if [ $IOTOP_COM = 1 ]; then
				 	LP_help "ERROR: --iotop parameter overlaps." >&2
					exit 1
				else
					### Set iotop command bit ###
					IOTOP_COM=1
				fi;;
			--novirttop) if [ $NOVIRTTOP_COM = 1 ]; then
				 	LP_help "ERROR: --novirttop parameter overlaps." >&2
					exit 1
				else
					### Set novirttop command bit ###
					NOVIRTTOP_COM=1
				fi;;
			--nokvm) if [ $NOKVM_COM = 1 ]; then
				 	LP_help "ERROR: --nokvm parameter overlaps." >&2
					exit 1
				else
					### Set nokvm command bit ###
					NOKVM_COM=1
				fi;;
			--cae) if [ $CAE_COM = 1 ]; then
					LP_help "ERROR: --cae parameter overlaps." >&2
					exit 1
				else
					### Set cpuacctex command bit ###
					which perfex >/dev/null 2>&1
					if [ $? = 0 ]; then
						### Super-user only ###
						if [ `whoami` != "root" ]; then
							echo "ERROR: You must be super-user, when you collect cpuacctex."
							exit 1
						fi
						CAE_COM=1
					else
						echo "WARNING: cpuacctex is not installed."
						echo "         So, cpuacctex is not executed."
						CAE_COM=0
					fi
				fi;;
			--force) if [ $OPT_FORCE = 1 ]; then
					LP_help "ERROR: --force parameter overlaps." >&2
					exit 1
				else
					OPT_FORCE=1
				fi;;
			-d)if [ $ROTATION_CHECK_FLAG = 0 ]; then 
				    OPTION="Directory"
				    if [ $OPT_FILE = 1 ]; then
				    	LP_help "ERROR: Specified parameter is wrong." >&2
							exit 1
				    else
				    	OPT_FILE=1
							OUT_OPT="-d"
			   	   fi
			    else
				    	LP_help "ERROR: Specified parameter is wrong." >&2
							exit 1
			    fi;;
			-z)if [ $ROTATION_CHECK_FLAG = 0 ]; then 
				 		OPTION="OutputFile"
			   	 	if [ $OPT_FILE = 1 ]; then
			    		LP_help "ERROR: Specified parameter is wrong." >&2
							exit 1
						else
			    		OPT_FILE=1
							OUT_OPT="-z"
			     	fi
			    else
				  	LP_help "ERROR: Specified parameter is wrong." >&2
				  	exit 1
			    fi;;				
			-v) echo "Version : $VERSION"
			    exit 0;;
			*)  LP_help "ERROR: Specified parameter is wrong." >&2
				exit 1;;
			esac
		fi

	else
		if [ `echo @$1 | cut -c2` = "-" ] ; then
			LP_help "ERROR: Specified parameter is wrong." >&2
			exit 1

		else
			 if [ ${rotation_Flag} = 0 ] && [ $ROTATION_CHECK_FLAG = 0 ]; then 
				case ${OPTION} in
					Directory) TEMPDIR=$1;;
					OutputFile) OUTFILE=$1;;
					*)  LP_help "ERROR: Specified parameter is wrong." >&2
						exit 1;;
				esac
			 fi
		fi
		OPTION=""
	fi
	shift

done

if [[ $NOIOTOP_COM = 1 ]] && [[ $IOTOP_COM = 1 ]]; then
	LP_help "ERROR: Specified parameter is wrong." >&2
	exit 1
fi

case ${OPTION} in
Directory) LP_help "ERROR: Specified parameter is wrong." >&2
		   exit 1;;
OutputFile) LP_help "ERROR: Specified parameter is wrong." >&2
		   exit 1;;
*) ;;
esac

### Check file exists ###
chk_file_exist $TEMPDIR

if [ "$OUT_OPT" = "-z" ];then
	chk_file_exist $OUTFILE
fi

### Check interval and count ###
if [ $FLAG != 2 ]; then
	LP_help "ERROR: interval and count parameters must be specified correctly."
	exit 1
fi

if [ $INTERVAL -le 0 ] || [ $MAX_COUNT -le 0 ]; then
	LP_help "ERROR: interval($INTERVAL) or count($MAX_COUNT) parameter is wrong."
  exit 1
fi

### Check the rotated collection double start ###
if [ $ROTATION_CHECK_FLAG = 1 ]; then
	Start_PID_check="${COMMANDNAME} {0,}--rstart"
	Rotation_PID_check="${COMMANDNAME} ROTATION"
	Start_PID_value=`pgrep -fo "${Start_PID_check}"`
	Pgrep_check=$?
	if [[ ${Pgrep_check} -le 1 ]]; then
		if [[ $$ != ${Start_PID_value} ]]; then
			echo "WARNING: Rotated collection is existed, You should stop the existed getPerfInfo."
			exit 1
		fi
	else
		echo "WARNING: Pgrep command's return value is ${Pgrep_check}. Maybe " \
		"system/machine is in bad state or other unknown circumstances ,"\
		"please wait for a while and then try again."
		exit 1
	fi
	Rotation_PID_value=`pgrep -fo "${Rotation_PID_check}"`
	Pgrep_check_1=$?
	if [[ ${Pgrep_check_1} -le 1 ]]; then
		if [[ ! -z ${Rotation_PID_value} ]]; then
			echo "WARNING: Rotated collection is existed, You should stop the existed getPerfInfo."
			exit 1
		fi
	else
		echo "WARNING: Pgrep command's return value is ${Pgrep_check_1}. Maybe " \
		"system/machine is in bad state or other unknown circumstances ,"\
		"please wait for a while and then try again."
		exit 1
	fi
fi

### stop the process of getPerfInfo --rstart and start rotated process###
if [ $ROTATION_CHECK_FLAG = 1 ]; then 
	### rotation sevice process start ###
	${COMMANDNAME} ROTATION_000 $CMD_OPTIONS &
	echo "INFO: Rotated collection has been started................"
	exit 0
fi

##display start time
if [ $rotation_Flag = 0 ] && [ $ROTATION_CHECK_FLAG = 0 ]; then 
	echo -n "Start time: "
	echo `date "+%T %x"`
fi

### make output directory ###
mkdir -p $TEMPDIR
if [ $CAE_COM = 1 ]; then
	mkdir -p "$TEMPDIR/cpuacctex_$DATE"
fi

### Paramter of iostat should add "-k" in RHEL5 ###
### Paramter of iostat should add "-k -p" in RHEL6 ###
### Paramter of iostat should remove "-n" in RHEL7 ###
DISTRIBUTION=`uname -r | awk -F"-" '{printf $1}'`
OPT_IOSTAT="-xdt"
if [ "$DISTRIBUTION" = "2.6.18" ]; then
	OPT_IOSTAT=$OPT_IOSTAT"k"
elif [[ "$DISTRIBUTION" =~ 2\.6\.3[1-9] ]] || [[ "$DISTRIBUTION" = "3.10.0" ]]  || [[ "$DISTRIBUTION" = "4.18.0" ]]; then
	OPT_IOSTAT=$OPT_IOSTAT"k -p"
fi


### interrupt signal -> kill tool -> exit ###
if [ $rotation_Flag = 0 ]; then 
	trap LP_dispatch_signal INT
elif [ $rotation_Flag = 1 ]; then 
	### kill the child process when the RORATION_001 process interrupt ###
	## KILL: Kill signal(9) The signals SIGKILL cannot be caught##
	## TERM: Termination signal(15) ##
	trap LP_dispatch_signal 15
fi

### Get information only 1 time ###
echo "Version : $VERSION" > "$TEMPDIR/""$COMMANDNAME""_version_$DATE"
cat   /proc/cpuinfo    >  "$TEMPDIR/cpuinfo_$DATE"
#cat   /proc/interrupts >  "$TEMPDIR/interrupts_$DATE"
uname -a               >  "$TEMPDIR/uname-a_$DATE"
#rpm   -qi kernel       >  "$TEMPDIR/kernelrpm_$DATE"
uname -r | grep -i PAE > /dev/null 2>&1
if [ $? = 0 ];then
	rpm   -qi kernel-PAE       >  "$TEMPDIR/kernelrpm_$DATE"
else
	rpm   -qi kernel       >  "$TEMPDIR/kernelrpm_$DATE"
fi
echo `date "+%T %x"`   >  "$TEMPDIR/df-hTP_$DATE"
df    -hTP             >>  "$TEMPDIR/df-hTP_$DATE"
echo `date "+%T %x"`   >  "$TEMPDIR/ps_aux_$DATE"
ps    aux              >>  "$TEMPDIR/ps_aux_$DATE"
mount -l               >  "$TEMPDIR/mount-l_$DATE"
cat   /proc/partitions >  "$TEMPDIR/partitions_$DATE"
sysctl -a              >  "$TEMPDIR/sysctl-a_$DATE"     2>/dev/null
ifconfig -a            >  "$TEMPDIR/ifconfig-a_$DATE"
#cat /proc/cmdline      >  "$TEMPDIR/cmdline_$DATE"
cat /proc/swaps        >  "$TEMPDIR/swaps_$DATE"
cat /etc/redhat-release > "$TEMPDIR/redhat-release_$DATE"
swapon -s               > "$TEMPDIR/swapon-s_$DATE"

### net devices ###
NET_DEV=`ifconfig -a | grep eth | awk '{print $1}'`
if [[ "$DISTRIBUTION" = "3.10.0" ]]; then
 NET_DEV=`ls /sys/class/net`
fi

for IFACE in $NET_DEV
do
	echo "$IFACE"      >> "$TEMPDIR/ethtool_$DATE"
	ethtool $IFACE     >> "$TEMPDIR/ethtool_$DATE" 2>&1
	echo ""            >> "$TEMPDIR/ethtool_$DATE"

	echo "$IFACE"      >> "$TEMPDIR/ethtool-i_$DATE"
	ethtool -i $IFACE  >> "$TEMPDIR/ethtool-i_$DATE" 2>&1
	echo ""            >> "$TEMPDIR/ethtool-i_$DATE"
done

### Getting mem_thresh info ###
if [ -f `dirname $0`/mem_thresh.sh ];then
        `dirname $0`/mem_thresh.sh > "$TEMPDIR/mem_thresh_$DATE" 2>&1
elif [ -f `dirname $0`/lib/mem_thresh.sh ];then
        `dirname $0`/lib/mem_thresh.sh > "$TEMPDIR/mem_thresh_$DATE" 2>&1
elif [ -f /opt/FJSVgetperfinfo/bin/mem_thresh.sh ];then
        /opt/FJSVgetperfinfo/bin/mem_thresh.sh > "$TEMPDIR/mem_thresh_$DATE" 2>&1
fi

### Setting interval for iotop/top or cpuacctex ###
if [ $OPT_FORCE = 1 ]; then
	TOP_CAE_INTERVAL=$INTERVAL
	TOP_CAE_COUNT=$MAX_COUNT
else
	if [ $INTERVAL -le 5 ]; then
		TOP_CAE_INTERVAL=5
	else
		TOP_CAE_INTERVAL=$INTERVAL
	fi
	
	let TOP_CAE_COUNT=$MAX_COUNT*$INTERVAL/$TOP_CAE_INTERVAL
	if [ $TOP_CAE_COUNT = 0 ]; then
		TOP_CAE_COUNT=1
	fi
fi
BASETIME=$INTERVAL\*$MAX_COUNT

### Main routine of collect information ###
mpstat -P ALL                 $INTERVAL $MAX_COUNT > "$TEMPDIR/mpstat-P_ALL_$DATE" &
MPSTAT_ID=$!
sar -A -o "$TEMPDIR/sar-A_$DATE" $INTERVAL $MAX_COUNT >/dev/null 2>&1 &
SAR_ID=$!
iostat $OPT_IOSTAT            $INTERVAL $MAX_COUNT > "$TEMPDIR/iostat""$(echo $OPT_IOSTAT | tr -d ' ')""_""$DATE" &
IOSTAT_ID=$!
if [ -x /usr/bin/nfsiostat ]; then
	/usr/bin/nfsiostat -kt $INTERVAL $MAX_COUNT > "$TEMPDIR/nfsiostat-kt_$DATE" &
fi
NFSIOSTAT_ID=$!

### Get top information ###
if [ $TOP_COM = 0 ]; then
	#top -b -H -d $TOP_CAE_INTERVAL -n $TOP_CAE_COUNT > "$TEMPDIR/top_$DATE" &
	#/bin/echo "date:$DATA_DATE"  > "$TEMPDIR/top_$DATE" 
	/usr/bin/top -b -d 1 -n 1 > /dev/null 2>&1
	if [ $? = 0 ]; then
		COLUMNS=$COLUMNS_NUM /usr/bin/top -b -d $TOP_CAE_INTERVAL -n $TOP_CAE_COUNT > "$TEMPDIR/top_$DATE" &
		TOP_ID=$!
	fi
fi


### Check iotop ###
IOTOP_CMDPATH=""

RET1=`rpm -ql iotop | grep /usr/bin/iotop`
RET2=`rpm -ql iotop | grep /usr/sbin/iotop`
if [[ $IOTOP_COM = 1 ]]; then
	if [[ -x /usr/bin/iotop && -x /usr/sbin/iotop ]]; then
		if [[ -n "$RET1" && -n "$RET2" ]]; then
			echo "WARNING: Unsupported iotop package is installed." 1>&2
		elif [[ -n "$RET1" ]]; then
			IOTOP_CMDPATH=/usr/bin/iotop
		elif [[ -n "$RET2" ]]; then
			IOTOP_CMDPATH=/usr/sbin/iotop
		else
			echo "WARNING: No iotop package is installed." 1>&2
		fi
	elif [[ -x /usr/bin/iotop  && -n "$RET1" ]]; then
		IOTOP_CMDPATH=/usr/bin/iotop
	elif [[ -x /usr/sbin/iotop && -n "$RET2" ]]; then
		IOTOP_CMDPATH=/usr/sbin/iotop
	else 
		echo "WARNING: No iotop package is installed." 1>&2
	fi
fi

### Sub routine of iotop/top information ###
if [[ $IOTOP_COM = 1 && -n "$IOTOP_CMDPATH" ]]; then
	$IOTOP_CMDPATH -bt -n 1 > /dev/null 2>&1
	if [ $? = 0 ]; then
		#/bin/echo "date:$DATA_DATE"  > "$TEMPDIR/iotop-bt_$DATE" 
		$IOTOP_CMDPATH -bt -d $TOP_CAE_INTERVAL -n $TOP_CAE_COUNT > "$TEMPDIR/iotop-bt_$DATE" &
		IOTOP_ID=$!
	fi
fi

### Get cpuacctex information ###
if [ $CAE_COM = 1 ]; then
	perfex -i $TOP_CAE_INTERVAL -n $TOP_CAE_COUNT -d "$TEMPDIR/cpuacctex_$DATE" &
	CAE_ID=$!
fi

### Get virt-top information ###
#virt-top -b -n 1 --stream > /dev/null 2>&1
#if [ $? = 0 ];then
if [ $NOVIRTTOP_COM != 1 ]; then
	/usr/bin/virt-top -b -n 1 --stream > /dev/null 2>&1
	if [ $? = 0 ]; then
		/usr/bin/virt-top -b -n $MAX_COUNT -d $INTERVAL --stream --csv "$TEMPDIR/virt-top-b_$DATE.csv" > "$TEMPDIR/virt-top_$DATE" &
		VIRT_TOP_ID=$!
	fi
fi

### Set kvm_stat option ###
KVM_STAT_COM=0
if [[ ${NOKVM_COM} = 0 ]];then
	kvm_stat --once > /dev/null 2>&1
	if [ $? = 0 ];then
		KVM_STAT_COM=1
	fi
fi

### Sub routine of collect information ###
while [ $COUNT -lt $MAX_COUNT ]
do
	TIME=`date "+%H:%M:%S"`
	LP_Collect_Other_Information $TIME
	COUNT=$COUNT+1
	sleep $INTERVAL
done

wait

### compressing the file when the usual collection ###
LP_ProcessFiles $TEMPDIR $OUT_OPT $OUTFILE
	
if [ $rotation_Flag = 0 ]; then 
	LP_EndMsg
fi
exit 0
