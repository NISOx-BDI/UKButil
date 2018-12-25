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

if [ "$UKB_SUBJECTS" == "" ] ; then
    echo "ERROR: UKB_SUBJECTS not defined."
    exit 1
fi

if [ "$FSLDIR" == "" ] ; then
    echo "ERROR: No FSL!"
    exit 1
fi

# Make sure no trailing slash
UKB_SUBJECTS=${UKB_SUBJECTS%/}

# Default interpolation
Interp="spline"

###############################################################################
#
# Functions
#
###############################################################################

Usage() {
cat <<EOF
Usage: `basename $0` [options] <FeatImg> <DestDir> <JobFile>

Creates a job file, to be used with fsl_sub -t, to convert UK Biobank task fMRI 
from subject-space to MNI space.

   FeatImg   File in a feat directory; e.g. mask or stats/cope1
   DestDir   Location of where MNI space files should be put; files named:
                   XXXXXX_tfMRI_<FeatFileNm>_MNI
             where FeatFileNm is FeatImg with any directory removed.
   JobFile   Text file with one applywarp command per line.

Options
   -i <Interp>   Specify interpolation. Default is "spline"; use "nn" for 
                 masks.
   -s Subj.txt   Specify subjects (instead of all possible); Subj.txt is text 
                 file, one Id per line.
   -S SubjUsed.txt
                 Search for all possible subjects (as by default) but write 
                 out list of ID's to SubjUsed.txt; saves time on subsequent runs.
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
  local DestDir="$5"

  local FileNm="$(basename "$FeatFile")"

  echo applywarp \
      -i $SrcDir/$Subj/fMRI/tfMRI.feat/"$FeatFile" \
      -r $FSLDIR/data/standard/MNI152_T1_2mm \
      -o "$DestDir"/${Subj}_tfMRI_"${FileNm}"_MNI \
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
        "-s")
            shift
	    SubjIds="$1" 
	    shift
            ;;
        "-S")
            shift
	    SubjIdsSv="$1" 
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


if [ "$SubjIds" == "" ] ; then

    SubjIds=${Tmp}SubjId

    # find all subjects with task fMRI
    find -L "$UKB_SUBJECTS" \
	-maxdepth 3 \
	\! -readable -prune -o \
	-path "*/fMRI/tfMRI.feat" -print \
	| sed "s@${UKB_SUBJECTS}/@@;s@/fMRI/tfMRI.feat@@" \
	> $SubjIds
    # When generalising to other filters:
    #    For a filter "*/fMRI/tfMRI.feat" also set maxdepth to correspond to the 
    #    depth of the filter  (this isn't vital, but speeds it up dramatically.

    if [ "$SubjIdsSv" != "" ] ; then
	cp "$SubjIds" "$SubjIdsSv"
    fi

fi

nSubj=$(cat $SubjIds | wc -l)

SrcDir="$UKB_SUBJECTS"

FeatFile="${1%.nii.gz}"
DestDir="$2"
JobFile="$3"

touch "$JobFile"

for ((i=1;i<=nSubj;i++)) ; do 

    Subj=$(sed -n ${i}p $SubjIds)

    if [ -f $SrcDir/$Subj/fMRI/tfMRI.feat/"$FeatFile".nii.gz ] ; then
        if [ -f $SrcDir/$Subj/fMRI/tfMRI.feat/reg/example_func2standard_warp.nii.gz ] ; then
		
		ApplyWarpJob "$SrcDir" "$Subj" "$FeatFile" "$Interp" "$DestDir" >> "$JobFile"

	fi
    fi
		
done

###############################################################################
#
# Exit & Clean up
#
###############################################################################

CleanUp
