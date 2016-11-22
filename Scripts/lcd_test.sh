#!/system/bin/sh

if [ "$#" -ne 2 ]; then
  echo "Usage: STEP_DURATION (in ms) VALUE_INCREMENT(0-255)" >&2
  exit 1
fi

#if ! [ $(/system/xbin/id -u) = 0 ]; then
#    echo "ERROR: This program must be executed as root" 
#    exit 1
#fi

#Compute wait time in seconds
WAIT_S=$(echo "$1 1000 / p" | dc)

#LCD Path
cd /sys/class/leds/lcd-backlight

brigh_val=0
while [ "${brigh_val}" -lt 255 ]; do
	echo "${brigh_val}" > brightness
	echo "${brigh_val}"
	brigh_val=$((brigh_val+$2))
	/system/xbin/sleep $WAIT_S
done
	