#!/bin/bash
#
# Script:  UKBclonefMRI.sh
# Purpose: Clone a feat analysis
# Author: T. Nichols, F. Alfaro Almagro
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

# Lists of subject ID's and corresponding base directories
dirSubjLists=("/vols/Scratch/ukbiobank/nichols/subj1.txt" \
              "/vols/Scratch/ukbiobank/nichols/subj2.txt" )
dirSubjs=( "/vols/Data/ukbiobank/FMRIB/IMAGING/data3/subjects" \
           "/vols/Data/ukbiobank/FMRIB/IMAGING/data3/subjects2" )

# Template Feat file; @@SubjDir@@ is to be replaced with subject dir,
# @@OutDir@@ with output directory
FeatTemplate="/vols/Scratch/ukbiobank/nichols/TEMPLATES/tfMRI_template.fsf"



###############################################################################
#
# Functions
#
###############################################################################

Usage() {
cat <<EOF
Usage: `basename $0` [options] <DestDir> <JobFile>

Creates a job file, to be used with fsl_sub -t, to convert UK Biobank task fMRI 
from subject-space to MNI space.

   DestDir   Location of root under which to create results in the formwhere MNI space files should be put; files named:
                   XXXXXX/fMRI/tfMRI.{fsf,feat}
   JobFile   Text file with one applywarp command per line.

Options
   -t Template   Template feat file; by default it is:
                 $FeatTemplate
_________________________________________________________________________
Version 1.0
EOF
exit
}

CleanUp () {
    /bin/rm -f /tmp/`basename $0`-${$}-*
    exit 0
}

ReplTemplate() {
  local SrcDir="$1"
  local Subj="$2"
  local DestDir="$3"
  local Template="$4"

  local OutDir="$DestDir"/"$Subj"/fMRI/tfMRI.feat
  local OutFsf="$DestDir"/"$Subj"/fMRI/tfMRI.fsf

  sed s%@@SubjDir@@%"$SrcDir"/"$Subj"%';'s%@@OutDir@@%"$OutDir"% "$Template" > "$OutFsf"
  echo feat "$OutFsf"
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
        "-t")
            shift
	    FeatTemplate="$1"
	    shift
            ;;
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

if (( $# != 2 )) ; then
    Usage
fi

DestDir="$1"
JobFile="$2"

cp /dev/null "$JobFile"

for ((i==0;i<${#dirSubjs[*]};i++)) ; do 
    SrcDir=${dirSubjs[i]}
    SrcList=${dirSubjLists[i]}

    for Subj in `cat $SrcList` ; do
	if [ -f $SrcDir/$Subj/fMRI/tfMRI.fsf ] ; then
	    echo -n "$Subj "
	    
	    mkdir -p $DestDir/$Subj/fMRI
	    ReplTemplate "$SrcDir" "$Subj" "$DestDir" "$FeatTemplate" >> "$JobFile"

	fi
    done
    
done

echo " "

###############################################################################
#
# Exit & Clean up
#
###############################################################################

CleanUp

