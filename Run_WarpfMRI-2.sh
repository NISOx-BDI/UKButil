#!/bin/bash -x
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
if false; then
    fslmaths $FSLDIR/data/standard/MNI152_T1_2mm -mul 0 fMRI_mask_MNI_sum
    ((i=0))
    for f in [0-9]*mask* ; do 
	fslmaths fMRI_mask_MNI_sum -add $f fMRI_mask_MNI_sum ;  
	((i++))
    done
    gzip fMRI_mask_MNI_sum.nii
    
    immv fMRI_mask_MNI_sum fMRI_mask_MNI_sum${i}
fi

# If problems try:
if false ; then
    slicesdir [0-9]*mask*
    mv slicesdir fMRI_mask_MNI_slicesdir${i}
    fslstats.sh -V [0-9]*mask* > fMRI_mask_MNI_Cnt${i}.txt
    sort -n fMRI_mask_MNI_Vcnt.txt | head
fi

# Manually create a one-sample t-test... ignoring missing... only correct where there's no missingness
if true ; then
    fslmaths $FSLDIR/data/standard/MNI152_T1_2mm -mul 0 fMRI_cope1_MNI_mean
    fslmaths fMRI_cope1_MNI_mean fMRI_cope1_MNI_std
    ((i=0))
    for f in [0-9]*cope1* ; do 
    	echo $i
    	fslmaths $f      -add fMRI_cope1_MNI_mean fMRI_cope1_MNI_mean
    	fslmaths $f -sqr -add fMRI_cope1_MNI_std  fMRI_cope1_MNI_std
    	((i++))
    done
    fslmaths fMRI_cope1_MNI_mean -div $i fMRI_cope1_MNI_mean
    fslmaths fMRI_cope1_MNI_std  -div $i fMRI_cope1_MNI_std   #  variance here
    fslmaths fMRI_cope1_MNI_mean -sqr -mul -1 -add fMRI_cope1_MNI_std -sqrt fMRI_cope1_MNI_std
    fslmaths fMRI_cope1_MNI_mean -div fMRI_cope1_MNI_std -mul $(echo "sqrt($i)"|bc -l) fMRI_cope1_MNI_tstat

    gzip fMRI_cope1_MNI_{mean,std,tstat}.nii
    
    mv fMRI_cope1_MNI_mean.nii.gz fMRI_cope1_MNI_mean-${i}.nii.gz
    mv fMRI_cope1_MNI_std.nii.gz fMRI_cope1_MNI_std-${i}.nii.gz
    mv fMRI_cope1_MNI_tstat.nii.gz fMRI_cope1_MNI_tstat-${i}.nii.gz
fi

