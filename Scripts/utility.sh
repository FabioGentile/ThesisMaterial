#!/system/bin/sh

get_core_number(){
	CORE_NUMBER=`grep -c ^processor /proc/cpuinfo`
	echo "${CORE_NUMBER}"
}

set_cpu_freq(){
	#echo "**DEBUG**set_cpu_freq** Setting on `seq 0 ${2}`"
	for i in `seq 0 ${2}`; do
		#echo "**DEBUG**set_cpu_freq** turn $i"
		echo $1 > "${CPU_STAT_ROOT}/cpu${i}/cpufreq/scaling_setspeed"
	done
}

set_cpu_governor(){
	#echo "**DEBUG**set_cpu_governor** Setting on `seq 0 ${2}`"
	for i in `seq 0 ${2}`; do
		echo $1 > "${CPU_STAT_ROOT}/cpu${i}/cpufreq/scaling_governor"
	done
}

get_cpu_freq(){
	cpu_freq=""
	for i in `seq 0 ${CORE_NUMBER_ZERO}`; do
		cur_f=`cat "${CPU_STAT_ROOT}/cpu${i}/cpufreq/cpuinfo_cur_freq"`
		cpu_freq="${cpu_freq} ${cur_f}"
	done
	echo "${cpu_freq}"
}

get_cpu_governor(){
	cpu_gov=""
	for i in `seq 0 ${1}`; do
		cur_gov=`cat "${CPU_STAT_ROOT}/cpu${i}/cpufreq/scaling_governor"`
		cpu_gov="${cpu_gov}${cur_gov} "
	done
	echo "${cpu_gov}"
}

get_cpu_max_frequency(){
	max=`cat "${CPU_STAT_ROOT}/cpu0/cpufreq/scaling_max_freq"` 
	echo "${max}"
}

get_cpu_min_frequency(){
	min=`cat "${CPU_STAT_ROOT}/cpu0/cpufreq/scaling_min_freq"` 
	echo "${min}"
}

get_lcd_lum(){
	ret=`cat ${LCD_STAT_FILE}`
	echo "${ret}"
}

set_lcd_lum(){
	echo $1 > ${LCD_STAT_FILE}
}

turn_on_core(){
	for i in `seq 0 $1`; do
		echo "1" > "${CPU_STAT_ROOT}/cpu${i}/online"
	done
}

turn_off_core(){
	for i in `seq 1 $1`; do
		echo "0" > "${CPU_STAT_ROOT}/cpu${i}/online"
	done
}

get_lock(){
	echo "Getting wakelock. Remember to call remove_lock"
	echo temporary > /sys/power/wake_lock
}

remove_lock(){
	echo "Removing wakelock"
	echo temporary > /sys/power/wake_unlock
}




CPU_STAT_ROOT="/sys/devices/system/cpu"
LCD_STAT_FILE="/sys/class/leds/lcd-backlight/brightness"

#0-based index
CORE_NUMBER=$(get_core_number)
CORE_NUMBER_ZERO=$((${CORE_NUMBER} - 1))
AVAILABLE_FREQ=`cat ${CPU_STAT_ROOT}/cpu0/cpufreq/scaling_available_frequencies`

