#!/bin/bash
#
# Script:  UKBwarpfMRI
# Purpose: Warp subject-level fMRI results to MIN space
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

# Default interpolation
Interp="spline"

###############################################################################
#
# Functions
#
###############################################################################

Usage() {
cat <<EOF
Usage: `basename $0` [options] <FeatFile> <DestDir> <JobFile>

Creates a job file, to be used with fsl_sub -t, to convert UK Biobank task fMRI 
from subject-space to MNI space.

   DestDir   Location of where MNI space files should be put; files named:
                   XXXXXX_fMRI_<FeatFileNm>_MNI
             where FeatFileNm is FeatFile with any directory removed.
   JobFile   Text file with one applywarp command per line.
   FeatFile  File in a feat directory; e.g. mask or stats/cope1
             (do not include an extension)

Options
   -i <Interp>   Specify interpolation. Default is "spline"; use "nn" for 
                 masks.
_________________________________________________________________________
Version 1.0
EOF
exit
}

CleanUp () {
    /bin/rm -f /tmp/`basename $0`-${$}-*
    exit 0
}

ApplyWarpJob() {
  local SrcDir="$1"
  local Subj="$2"
  local FeatFile="$3"
  local Interp="$4"

  local FileNm="$(basename "$FeatFile")"

  echo applywarp \
      -i $SrcDir/$Subj/fMRI/tfMRI.feat/"$FeatFile" \
      -r $FSLDIR/data/standard/MNI152_T1_2mm \
      -o "$DestDir"/${Subj}_fMRI_"${FileNm}"_MNI \
      -w $SrcDir/$Subj/fMRI/tfMRI.feat/reg/example_func2standard_warp \
      --interp="$Interp"
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
        "-i")
            shift
	    Interp="$1"
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

if (( $# != 3 )) ; then
    Usage
fi

FeatFile="$1"
DestDir="$2"
JobFile="$3"

touch "$JobFile"

for ((i==0;i<${#dirSubjs[*]};i++)) ; do 
    SrcDir=${dirSubjs[i]}
    SrcList=${dirSubjLists[i]}

    for Subj in `cat $SrcList` ; do
	if [ -f $SrcDir/$Subj/fMRI/tfMRI.feat/"$FeatFile".nii.gz ] ; then
            if [ -f $SrcDir/$Subj/fMRI/tfMRI.feat/reg/example_func2standard_warp.nii.gz ] ; then
		
		ApplyWarpJob "$SrcDir" "$Subj" "$FeatFile" "$Interp" >> "$JobFile"

	    fi
	fi
    done
		
done

###############################################################################
#
# Exit & Clean up
#
###############################################################################

CleanUp

