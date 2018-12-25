#!/bin/bash
#
# Script: ConvCategories
# Purpose: Convert one-variable-per-line UKB variable category 
#          definitions into form expected by ukbparse (one-line-per-category)
# Author: T. Nichols
# Version: 1.0
#

###############################################################################
#
# Environment set up
#
###############################################################################

shopt -s nullglob # No-match globbing expands to null
Tmp=/tmp/`basename $0`-${$}-
trap CleanUp INT

###############################################################################
#
# Functions
#
###############################################################################

Usage() {
cat <<EOF
Usage: `basename $0` CatIn.tsv

CatIn.tsv is tab-separated, one-line-per-variable definition of UKB
variable categories. First row is header row; first column are the
integer UKB variable ids; second column is a text description of the
variable (ignored); third and subsequent columns define categories:
Header row defines the name of the categorisation, each row in the
column is either blank (that variable excluded from this
categorisation) or has the name of a category in which a given
variable falls.  Any quotes found are removed.

For each catorisation, a TSV file is created based on the header row
name.  E.g. if 3rd column has header "MyCats", then a file
"MyCats.tsv" will be created.  The format is one-row-per-category,
with a header row defining columns: ID, Category, Variables.  ID's are
based on alphabetical sorting of the category names, variables are
listed separated by commas.
_________________________________________________________________________
EOF
exit
}

CleanUp () {
    /bin/rm -f /tmp/`basename $0`-${$}-*
    exit 0
}

###############################################################################
#
# Parse arguments
#
###############################################################################

while (( $# > 1 )) ; do
    case "$1" in
        "-help")
            Usage
            ;;
#         "-t")
#             shift
#             tval="$1"
#             shift
#             ;;
        -*)
            echo "ERROR: Unknown option '$1'"
            exit 1
            break
            ;;
        *)
            break
            ;;
    esac
done

if (( $# < 1 )) ; then
    Usage
fi
In="$1"
if [ ! -f "$In" ] ; then
    echo "ERROR: Cannot open '$In'"
    exit 1
fi



###############################################################################
#
# Script Body
#
###############################################################################

nCat=$(head -1 "$In" | awk -F'\t' '{print NF-2}')
echo "Found $nCat categorisations"

for ((Col=3;Col<3+nCat;Col++)) ; do 

    Name=$(awk -F'\t' '(NR==1){print $'$Col'}' "$In")

    echo "${Name//\"/}..."

    Out="${Name//\"/}.tsv"

    echo "ID	Category	Variables" > "$Out"

    awk -F'\t' '(NR>1)&&($'$Col'!=""){print $'$Col'}' "$In" | sort | sed 's/"//g' | uniq > $Tmp
    Ncat=$(cat $Tmp | wc -l)

    for ((i=1;i<=Ncat;i++)) ; do
	Cat=$(sed -n ${i}p $Tmp)
	echo -n "${i}	${Cat}	" >> "$Out"
	awk -F'\t' '($'$Col'=="\"'"$Cat"'\""){if(First==0){printf("%d",$1);First++}else{printf(",%d",$1)}}' "$In" >> "$Out"
	echo >> "$Out"
    done

done

###############################################################################
#
# Exit & Clean up
#
###############################################################################

CleanUp
