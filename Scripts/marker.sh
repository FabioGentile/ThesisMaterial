#!/system/bin/sh

#ARGS check
if [ "$#" -ne 1 ]; then
  echo "Usage: STEP_DURATION_HIGH (in s)" >&2
  exit 1
fi

DURATION_HIGH=$1
source "/sdcard/BENCHMARK/utility.sh"


#echo "lancio ${CORE_NUMBER} per ${DURATION_HIGH}"

stress -c ${CORE_NUMBER} -t 60 &
/system/xbin/sleep ${DURATION_HIGH}
killall stress
