#!/bin/bash

clean(){
	printf "\n * Cleaning:\n"
	for i in $(find pages -iname '*.pdf')
	do
		printf -- "- Deleting $i\n"
		rm -f --verbose $i
	done
	rm -f --verbose Pablo.Mansilla.Ojeda.cv.*.pdf
}

generate_pdf_pages(){
	printf "\n* Generating PDF files:\n"
	FILES=$(find pages -iname '*.svg' | sort)
	for i in $FILES
	do
		if [ -f $i ]
		then
			FILENAME=$(basename $i .svg)
			DST=$(dirname $i)/$FILENAME.pdf
			printf -- "- Converting $i to $DST ."
			dbus-run-session inkscape --without-gui -f $i --export-pdf=$DST
			if [ $? -eq 0 ]
			then
				printf ". OK\n"
			else
				printf ". NOK\n"
				exit -1
			fi
		fi
	done
}

join_pages(){
	printf "\n* Joining files:\n"
	for i in $(ls -1 pages)
	do
		printf -- "- Joining $i\n"
		FILES=$(IFS=' ' ls -1 pages/$i/*.pdf | tr '\n' ' ')
		gs -dBATCH -dNOPAUSE -q -sDEVICE=pdfwrite -sOutputFile=Pablo.Mansilla.Ojeda.cv.$i.pdf $FILES
	done

}

clean
generate_pdf_pages
join_pages
