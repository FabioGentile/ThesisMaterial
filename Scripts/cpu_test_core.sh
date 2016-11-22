#!/system/bin/sh

#ROOT check
if ! [ $(/system/xbin/id -u) = 0 ]; then
    echo "ERROR: This program must be executed as root" 
    exit 1
fi

#ARGS check
if [ "$#" -ne 1 ]; then
  echo "Usage: DURATION(s)" >&2
  exit 1
fi

duration=$1
source "/sdcard/BENCHMARK/utility.sh"

cpu_stress(){
	START=$(/system/xbin/date +%s.%N)

	stress -t $1 -c $2
	sleep $1
	
	END=$(/system/xbin/date +%s.%N)
	DIFF=$(echo "$END $START - p" | dc)
	echo " $DIFF"
}


test_freq(){
	ACTIVE_CORE_P1=$((${ACTIVE_CORE} + 1))
	#For each frequency, set all core and perform test
	for var in "$@"
	do
		echo "SETTO ${var} ${ACTIVE_CORE}"
    	set_cpu_freq $var ${ACTIVE_CORE}
    	get_cpu_freq
    	cpu_stress ${duration} ${ACTIVE_CORE_P1}
	done	
}

# Turn off all cores
turn_off_core 3
sleep 1

for core in `seq 0 3`
do
	ACTIVE_CORE=$core
	turn_on_core ${core}
	set_cpu_governor "userspace" ${core}
	get_cpu_governor ${core}
	/system/xbin/sleep 0.1

	test_freq 300000 422400 652800 729600 883200 960000 1036800 1190400 1267200 1497600 1574400 1728000 1958400 2265600
	sleep 5
done