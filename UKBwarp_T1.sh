#!/bin/bash
#
# Script:  UKBwarp_T1
# Purpose: Warp subject T1 results to MNI space
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

if [ "$FSLDIR" == "" ] ; then
    echo "ERROR: No FSL!"
    exit 1
fi


# Default interpolation
Interp="spline"

###############################################################################
#
# Functions
#
###############################################################################

Usage() {
cat <<EOF
Usage: `basename $0` [options] <T1img> <DestDir> <JobFile>

Creates a job file, to be used with fsl_sub -t, to warp T1.nii.gz to 1mm MNI.

   T1img     Particular file to resample into 1mm MNI (e.g. T1)
   DestDir   Location of where MNI space files should be put; files named:
                   XXXXXX_<T1img>_MNI
   JobFile   Text file with one applywarp command per line.

Options
   -i <Interp>   Specify interpolation. Default is "spline"; use "nn" for 
                 masks.
   -s Subj.txt   Specify subjects (instead of all possible); Subj.txt is text 
                 file, one Id per line.
   -S SubjUsed.txt
                 Search for all possible subjects (as by default) but write 
                 out list of ID's to SubjUsed.txt; saves time on subsequent runs.
   -d SrcDir     Source directory where UKB image data is found; defaults to 
                 $UKB_SUBJECTS
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
  local T1img="$3"
  local Interp="$4"
  local DestDir="$5"

  local FileNm="$(basename "$T1img")"

  echo applywarp \
      -i $SrcDir/$Subj/T1/"$T1img" \
      -r $FSLDIR/data/standard/MNI152_T1_1mm \
      -o "$DestDir"/${Subj}_"${FileNm}"_MNI \
      -w $SrcDir/$Subj/T1/transforms/T1_to_MNI_warp \
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
        "-d")
            shift
	    SrcDir="$1" 
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

if [ "$SrcDir" == "" ] ; then
    if [ "$UKB_SUBJECTS" == "" ] ; then
	echo "ERROR: UKB_SUBJECTS not defined & SrcDir not set with -d"
	exit 1
    fi
    SrcDir="$UKB_SUBJECTS"    
fi
# Make sure no trailing slash
SrcDir="${SrcDir%/}"


if [ "$SubjIds" == "" ] ; then

    SubjIds=${Tmp}SubjId

    # find all subjects with T1's
    find -L "$SrcDir" \
	-maxdepth 3 \
	\! -readable -prune -o \
	-path "*/T1/T1.nii.gz" -print \
	| sed "s@${SrcDir}/@@;s@/T1/T1.nii.gz@@" \
	> $SubjIds
    # When generalising to other filters:
    #    For a filter "*/fMRI/tfMRI.feat" also set maxdepth to correspond to the 
    #    depth of the filter  (this isn't vital, but speeds it up dramatically.

    if [ "$SubjIdsSv" != "" ] ; then
	cp "$SubjIds" "$SubjIdsSv"
    fi

fi

nSubj=$(cat $SubjIds | wc -l)

T1img="${1%.nii.gz}"
DestDir="$2"
JobFile="$3"

touch "$JobFile"

for ((i=1;i<=nSubj;i++)) ; do 

    Subj=$(sed -n ${i}p $SubjIds)

    if [ -f $SrcDir/$Subj/T1/"$T1img".nii.gz ] ; then
        if [ -f $SrcDir/$Subj/T1/transforms/T1_to_MNI_warp.nii.gz ] ; then
		
		ApplyWarpJob "$SrcDir" "$Subj" "$T1img" "$Interp" "$DestDir" >> "$JobFile"

	fi
    fi
		
done

###############################################################################
#
# Exit & Clean up
#
###############################################################################

CleanUp

