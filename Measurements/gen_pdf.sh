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

for dir in `find . ! -path . -type d | grep -v "git"`
do
	echo $dir
	./script_daq.R $dir
	crop_pdf "${dir}/daq.pdf"
	./script_pt.R $dir
	crop_pdf "${dir}/pt_all.pdf" "${dir}/pt_app.pdf"
done