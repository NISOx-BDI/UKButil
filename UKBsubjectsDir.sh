#!/bin/bash

# Make a version of subjectsDir that has symbolic links named after my 
# own (not Steve's) application numbers

subjDirSrc=/well/win-biobank/projects/imaging/data/data3/subjectsAll
subjDirNew=/gpfs2/well/nichols/projects/UKB/IMAGING/subjectsAll
Bridge=/gpfs2/well/nichols/projects/UKB/SMS/bridge_8107_34077.tsv

mkdir -p "$subjDirNew"

nSubj=$(cat "$Bridge" | wc -l)

for ((i=2;i<=$nSubj;i++)) ; do
    tmp=( $(sed -n ${i}p "$Bridge") )
    if (( ${#tmp[*]} != 2 )) ; then
	echo "ERROR on bridge file line $i ($tmp)"
	exit
    fi
    SrcId="${tmp[0]}"
    NewId="${tmp[1]}"
    for v in 2 3 ; do
	if [  -e  "$subjDirSrc"/"${v}${SrcId}" ] ; then
	    echo "Old $SrcId -> New $NewId (visit $v)"
	    if [ -e "$subjDirNew"/"${v}${NewId}" ] ; then
		/bin/rm "$subjDirNew"/"${v}${NewId}" 
	    fi
	    ln -s "$subjDirSrc"/"${v}${SrcId}" "$subjDirNew"/"${v}${NewId}" 
	fi
    done
done



