#!/bin/bash
# 
# "Run" script to warp task fMRI images to MNI space, part 2
#
# Compute mask sum image, and possibly other diagonostics to identify bad subjects 
#

module add fsl
module add fsl_sub

UKButil=/well/nichols/scripts/UKButil
Dest=/well/nichols/projects/UKB/MNI

export FSLOUTPUTTYPE=NIFTI

cd $Dest

# Create a count mask
fslmaths $FSLDIR/data/standard/MNI152_T1_2mm -mul 0 fMRI_mask_MNI_sum
((i=0))
for f in [0-9]*mask* ; do 
    fslmaths fMRI_mask_MNI_sum -add $f fMRI_mask_MNI_sum ;  
    ((i++))
done
gzip fMRI_mask_MNI_sum.nii

immv fMRI_mask_MNI_sum fMRI_mask_MNI_sum${i}

# If problems try:
if false ; then
    slicesdir [0-9]*mask*
    mv slicesdir fMRI_mask_MNI_slicesdir${i}
    fslstats.sh -V [0-9]*mask* > fMRI_mask_MNI_Cnt${i}.txt
    sort -n fMRI_mask_MNI_Vcnt.txt | head
fi
