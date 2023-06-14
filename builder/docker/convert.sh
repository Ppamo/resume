#!/bin/bash
TEMP=.tmp

setup(){
	printf "\n* Running setup tasks\n"
	printf -- "- Installing fonts ."
	mkdir -p /usr/share/fonts/ttf
	FILESCOUNT=$(find resources/fonts/ -iname *.ttf -exec cp {} /usr/share/fonts/ttf \; -exec echo -n "." \; | wc -c)
	printf "* %s files copied\n" "$FILESCOUNT"
	fc-cache
	if [ $? -eq 0 ]
	then
		printf ". OK\n"
	else
		printf ". NOK\n"
		exit -1
	fi
}

generate_pdf_pages(){
	printf "\n* Generating PDF from $1/*.svg\n"
	rm -Rf $TEMP
	mkdir -p $TEMP
	printf -- "- Converting $FILENAME ."
	inkscape --export-overwrite --export-type=pdf $1/*.svg 2>/dev/null
	if [ $? -eq 0 ]
	then
		printf ". OK\n"
	else
		printf ". NOK\n"
		exit -1
	fi
	mv $1/*.pdf $TEMP
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

generate_pdf_pages pages/en
join_pdf_pages Pablo.Mansilla.Ojeda.cv.en.pdf

generate_pdf_pages pages/es
join_pdf_pages Pablo.Mansilla.Ojeda.cv.es.pdf

echo
