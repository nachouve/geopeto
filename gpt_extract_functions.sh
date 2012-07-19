#!/bin/bash -       
#===============================================================================
## Title           :gpt_extract_functions.sh
## Description     :This script will make a extraction of all Geopeto functions
## Copyright (C) 2012 Nacho Uve - All Rights Reserved
#===============================================================================
## Author          :Nacho Varela
## Last_revised    :201206
## Version         :0.1
## License         :GPL3
## Notes           :It works with PostGIS-1.5.1
## Bash_version    :4.1.5(1)-release
#===============================================================================

usage()
{
cat <<EOF
usage: $0 options
This script will make a extraction of all Geopeto functions

OPTIONS:
   -h      Show this message
   -m      export to multiple files. Default all to a single file: nice to import to the DB
   -d      Database name
   -o      Output file ('geopeto_functions.sql' default)
   -f      Output folder
   -v      Verbose
EOF
}

# Modes:
#   'single': export all functions to a unique file
#   'multi': export to multiple each function to a file
mode='single'
db='desourb'
folder='.'

output='geopeto_functions.sql'

while getopts hf:d:m option; do
    case "$option" in
	h)usage
	    exit 1;;
	o)output="$OPTARG";;
	f)folder="$OPTARG";;
	d)db="$OPTARG";;
	m)mode='multi';;
	[?])usage
	    exit 1;;
    esac
done

suffix="uve_ gpt_"
aux='__aux_'$db'.sql'
aux_list=$output'.list'

rm $output
rm $aux_list

touch $aux_list
touch $output

echo "Exporting schema... "
pg_dump -Fc -s $db > $aux

echo "Filtering functions... "
for i in $suffix; do
    echo $i
    pg_restore -l $aux | grep FUNCTION | grep $i | sed s/'.*FUNCTION '// |sed s/'.*public '// | sed s/') .*'/")\n"/ >> $aux_list
done

echo "Saving functions on..."
IFS=$'\n'
for i in `cat $aux_list`; do
    if [ "$mode" == "single" ]; then 
	pg_restore $aux -P $i >> $output
    fi
    if [ "$mode" == "multi" ]; then 
	output=`echo $i | sed s/\(.*/''/g`
	echo "=="$output
	pg_restore $aux -P $i > $folder/$output'.sql'
    fi
done

rm $aux
rm $aux_list
