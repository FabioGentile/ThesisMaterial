#!/bin/bash

crop_pdf(){
	echo $1
	pdfcrop $1
	rm $1 

	if [ "$#" -eq 2 ]; then
		pdfcrop $2
		rm $2
	fi

}


if [ "$#" -eq 1 ]; then
	 ./script_daq.R $1
	crop_pdf "$1/daq.pdf"
	./script_pt.R $1
	crop_pdf "$1/pt_all.pdf" "$1/pt_app.pdf"
  exit 0
fi

rm -f "all.csv" "app.csv" "daq.csv"

echo "\#,Power(W),\$\delta_{power}$,Duration(s),\$\delta_{duration}\$,Energy(J),\$\delta_{energy}\$" > "app.csv"
echo "\#,Power(W),\$\delta_{power}$,Duration(s),\$\delta_{duration}\$,Energy(J),\$\delta_{energy}\$" > "all.csv"
echo "\#,Power(W),\$\delta_{power}$,Duration(s),\$\delta_{duration}\$,Energy(J),\$\delta_{energy}\$" > "daq.csv"

# echo "Config,Power(W),\$\delta_{Power}$,\$\delta_{Power}\$\%,Duration(s),\$\delta_{Duration}\$,\$\delta_{Duration}\$\%,Energy(J),\$\delta_{Energy}\$,\$\delta_{Energy}\$%" > "app.csv"
# echo "Config,Power(W),\$\delta_{Power}$,\$\delta_{Power}\$\%,Duration(s),\$\delta_{Duration}\$,\$\delta_{Duration}\$\%,Energy(J),\$\delta_{Energy}\$,\$\delta_{Energy}\$%" > "all.csv"
# echo "Config,Power(W),\$\delta_{Power}$,\$\delta_{Power}\$\%,Duration(s),\$\delta_{Duration}\$,\$\delta_{Duration}\$\%,Energy(J),\$\delta_{Energy}\$,\$\delta_{Energy}\$%" > "daq.csv"

for dir in `find . ! -path . -type d | grep -v "git"`
do
	echo $dir
	./script_daq.R $dir
	crop_pdf "${dir}/daq.pdf"
	./script_pt.R $dir
	crop_pdf "${dir}/pt_all.pdf" "${dir}/pt_app.pdf"
done