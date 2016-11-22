#!/system/bin/sh

#ROOT check
if ! [ $(/system/xbin/id -u) = 0 ]; then
    echo "ERROR: This program must be executed as root" 
    exit 1
fi

#ARGS check
if [ "$#" -ne 2 ]; then
  echo "Usage: DURATION(s) NUM_CORE" >&2
  exit 1
fi

duration=$1
NUM_CORE=$(($2 - 1))
NUM_CORE_P1=$2
source "/sdcard/BENCHMARK/utility.sh"

cpu_stress(){
	START=$(/system/xbin/date +%s.%N)

	stress -t $1 -c ${NUM_CORE_P1}
	sleep $1
	
	END=$(/system/xbin/date +%s.%N)
	DIFF=$(echo "$END $START - p" | dc)
	echo " $DIFF"
}


main(){
	#Turn on all core
	for i in `seq 0 ${NUM_CORE}`; do
		echo "1" > "${CPU_STAT_ROOT}/cpu${i}/online"
		#Force min freq
		echo $1 > "${CPU_STAT_ROOT}/cpu${i}/cpufreq/scaling_min_freq"
	done


	#Set manual cpu governor
	#set_cpu_governor "userspace" ${NUM_CORE}
	#get_cpu_governor ${NUM_CORE}

	#For each frequency, set all core and perform test
	for var in "$@"
	do
		echo "SETTO ${var} ${NUM_CORE}"
    	set_cpu_freq $var ${NUM_CORE}
    	get_cpu_freq
    	cpu_stress ${duration} ${CORE_NUMBER}
    	#/system/xbin/sleep ${duration}
	done

	#Restore automatic cpu governor
	# set_cpu_governor "ondemand" ${NUM_CORE}
	# get_cpu_governor ${NUM_CORE}
	
}


#Stop core management service
stop mpdecision
main ${AVAILABLE_FREQ} 

set_cpu_freq 300000 ${NUM_CORE}