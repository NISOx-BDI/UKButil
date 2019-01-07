#!/bin/bash -x
# Outline draft of a script to scrape UKB for list of all field IDs seen at the showcase

URL=(\
     'http://biobank.ctsu.ox.ac.uk/crystal/list.cgi?it=0&vt=11' \
	 'http://biobank.ctsu.ox.ac.uk/crystal/list.cgi?it=0&vt=21' \
	 'http://biobank.ctsu.ox.ac.uk/crystal/list.cgi?it=0&vt=22' \
	 'http://biobank.ctsu.ox.ac.uk/crystal/list.cgi?it=0&vt=31' \
	 'http://biobank.ctsu.ox.ac.uk/crystal/list.cgi?it=0&vt=41' \
	 'http://biobank.ctsu.ox.ac.uk/crystal/list.cgi?it=0&vt=51' \
	 'http://biobank.ctsu.ox.ac.uk/crystal/list.cgi?it=0&vt=61' \
	 'http://biobank.ctsu.ox.ac.uk/crystal/list.cgi?it=0&vt=101' )
Type=( 'Integer' \
	   'CategoricalSingle' \
	   'CategoricalMultiple' \
	   'Continuous' \
	   'Text' \
	   'Date' \
	   'Time' \
	   'Compound' )

cp /dev/null IDs_All.txt

for ((i=0;i<${#URL[@]};i++)) ; do
    wget -O /tmp/$$ "${URL[i]}"
    grep 'field.cgi?id=' /tmp/$$ | sed 's/^.*field.cgi?id=\([0-9]*\).*$/\1/' > "IDs_${Type[i]}.txt"
    cat IDs_${Type[i]}.txt >> IDs_All.txt
done

	 

    
