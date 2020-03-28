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

# Check for essential env var
if [[ "$FSLDIR" == "" || "$UKB_SMS" == "" ||  "$UKB_SUBJECTS" == "" ||  "$UKB_SCRIPTS" == "" ]] ; then
    echo "ERROR: Key env vars, FSLDIR, UKB_SMS, UKB_SUBJECTS and UKB_SCRIPTS not all set"
    exit 1
fi

# Template Feat file; @@SubjDir@@ is to be replaced with subject dir,
# @@OutDir@@ with output directory
FeatTemplate="/vols/Scratch/ukbiobank/nichols/TEMPLATES/tfMRI_template.fsf"

# Which data, Task? (0= rest)
UseTask=1

###############################################################################
#
# Functions
#
###############################################################################

Usage() {
cat <<EOF
Usage: `basename $0` [options] <SubjIds> <DestDir> <JobFile>

Creates a job file, to be used with fsl_sub -t, to convert UK Biobank task fMRI 
from subject-space to MNI space.

   SubjIds   Plain text file listing the subject Ids to consider (each will
             be  checked to confirm availablity of data).
   DestDir   Location of root under which to create results in the from 
             where MNI space files should be put; files created will be named:
                   XXXXXX/fMRI/tfMRI.{fsf,feat}
   JobFile   Text file with one applywarp command per line.

Options
   -t Template   Template feat file; by default it is:
                 $FeatTemplate
   -r            Use resting data not task data, for when doing 'resting 
                 as task' analyses.

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
  local Npts="$5"
  local ImgData="$6"

  local OutDir="$DestDir"/"$Subj"/fMRI/tfMRI.feat
  local OutFsf="$DestDir"/"$Subj"/fMRI/tfMRI.fsf

  sed "s@/tfMRI@/${ImgData}@;s%@@SubjDir@@%$SrcDir"/"$Subj"%';'s%@@OutDir@@%"$OutDir"%';'"s/@@Npts@@/$Npts/" "$Template" > "$OutFsf"
  
  echo $UKB_SCRIPTS/UKButil/feat_then_clean.sh "$OutFsf"

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
        "-r")
            shift
	    UseTask=0
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

if (( $# != 3 )) ; then
    Usage
fi

if (( $UseTask == 1 )) ; then
    ImgData=tfMRI
else
    ImgData=rfMRI
fi

SubjIds="$1"
DestDir="$2"
JobFile="$3"

cp /dev/null "$JobFile"


SrcDir=$UKB_SUBJECTS/subjectsAll

for Subj in `cat $SubjIds` ; do

	if [ "$(imtest $SrcDir/$Subj/fMRI/$ImgData)" = 1 ] ; then

	    echo -n "$Subj "
	    
	    Npts=$(fslnvols $SrcDir/$Subj/fMRI/$ImgData)

	    mkdir -p $DestDir/$Subj/fMRI
	    ReplTemplate "$SrcDir" "$Subj" "$DestDir" "$FeatTemplate" "$Npts" "$ImgData" >> "$JobFile"

	fi
	
done
    

echo " "

###############################################################################
#
# Exit & Clean up
#
###############################################################################

CleanUp

