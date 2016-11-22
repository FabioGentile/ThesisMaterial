#!/bin/bash

#ARGS check
if [ "$#" -ne 1 ]; then
  echo "Usage: UID" >&2
  exit 1
fi

#./get_log.sh

./main.py -c
mv out.csv out_all.csv

./main.py -c -u $1
mv out.csv out_app.csv

./gen_ods.py

#rm -r out_all.csv out_app.csv