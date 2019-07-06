#!/bin/bash
TEMP=.tmp

setup(){
	printf "\n* Running setup tasks\n"
	printf -- "- Installing fonts ."
	mkdir -p /usr/share/fonts/ttf
	find resources/fonts/ -iname *.ttf -exec cp {} /usr/share/fonts/ttf \;
	if [ $? -eq 0 ]
	then
		printf ". OK\n"
	else
		printf ". NOK\n"
		exit -1
	fi
}

generate_pdf_pages(){
	printf "\n* Generating PDF from $*\n"
	rm -Rf $TEMP
	mkdir -p $TEMP
	for i in $*
	do
		if [ -f $i ]
		then
			FILENAME=$(basename $i .svg)
			printf -- "- Converting $FILENAME ."
			inkscape -f $i --export-pdf=$TEMP/$FILENAME.pdf
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

join_pdf_pages(){
	OUTPUT=$1
	rm -f $OUTPUT
	printf "+ Writing $OUTPUT ."
	gs -dBATCH -dNOPAUSE -q -sDEVICE=pdfwrite -sOutputFile=$OUTPUT $TEMP/*
	if [ $? -eq 0 ]
	then
		printf ". OK\n"
	else
		printf ". NOK\n"
		exit -1
	fi
	rm -Rf $TEMP
}

setup

generate_pdf_pages pages/en/*
join_pdf_pages Pablo.Mansilla.Ojeda.cv.en.pdf

generate_pdf_pages pages/es/*
join_pdf_pages Pablo.Mansilla.Ojeda.cv.es.pdf

echo
