#!/bin/bash

PRECISION=3

#ARGS check
if [ "$#" -ne 1 ]; then
  echo "Usage: LISTENING_PORT" >&2
  exit 1
fi

cur=$(date +%s.%N)
prev=$(date +%s.%N)
max=0
min=65535
avg=0
delta=0
count=0
prev_line="START_LINE"
first_packet=1
last_packet=0
rate=0

nc -k -l $1 | while read line ; \
do \

	cur=$(date +%s.%N)	

	if [[ first_packet -eq 1 ]]; then
		echo "FIRST"
		first_packet=0
		prev_line=$line 
		rate=$(echo $line | cut -d '|' -f 1 | awk -v precision="${PRECISION}" '{printf "%.*f",precision,1/$1}')
	else

		delta=$(echo "$cur $prev" | awk -v precision="${PRECISION}" '{printf "%.*f", precision, $1 - $2}')

		if [ "$line" != "$prev_line" ]; then 
			#NEW payload -> new transmission rate, print statistics
			avg=$(echo "$avg $count" | awk -v precision="${PRECISION}" '{printf "%.*f", precision, $1/$2}')
			abs_diff=$(echo "$avg $rate" | awk -v precision="${PRECISION}" '{printf "%.*f", precision, sqrt(($1-$2)^2)}')
			rel_error=$(echo "$avg $rate" | awk -v precision="2" '{printf "%.*f", precision, sqrt(($1-$2)^2)*100/$2 }')
			echo "MIN: $min MAX: $max AVG: $avg EXPECTED: $rate DIFF: $abs_diff ERROR: $rel_error%" 
			prev_line=$line 
			min=65535
			max=0
			avg=0
			count=0
			rate=$(echo $line | cut -d '|' -f 1 | awk -v precision="${PRECISION}" '{printf "%.*f",precision,1/$1}' 2>/dev/null)

			if [ "$line" == "XXXENDXXX" ]; then 
				echo "LAST"
				cur=$(date +%s.%N)
				prev=$(date +%s.%N)
				max=0
				min=65535
				avg=0
				delta=0
				count=0
				prev_line="START_LINE"
				first_packet=1
				rate=0
				last_packet=0	
				continue			
			fi



		fi
		
		if (( $(echo "$delta > $max" |bc -l) )); then
			max=$delta
		fi

		if (( $(echo "$delta < $min" |bc -l) )); then
			min=$delta
		fi		

		avg=$(echo "$avg + $delta" | bc)
		count=$((count+1))
		 
		#echo "${delta} ${line} $count"
	fi
	
	prev=$cur ;

done
