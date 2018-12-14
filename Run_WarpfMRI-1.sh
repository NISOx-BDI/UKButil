#!/bin/bash -x
# 
# "Run" script to warp task fMRI images to MNI space, part 1:
#
# Create and queue jobs to do the warping
#

module add fsl
module add fsl_sub

cd /users/nichols/kfh142/group/scripts

UKButil=/well/nichols/scripts/UKButil
Dest=/well/nichols/projects/UKB/MNI

$UKButil/UKBwarp_tfMRI.sh -S IDs_tfMRI.txt       stats/cope1 $Dest Cmd_Warp_tfMRIcope.txt
fsl_sub -l ~/log -t Cmd_Warp_tfMRIcope.txt

$UKButil/UKBwarp_tfMRI.sh -s IDs_tfMRI.txt -i nn mask        $Dest Cmd_Warp_tfMRImask.txt
fsl_sub -l ~/log -t Cmd_Warp_tfMRImask.txt

Cnt=$(cat IDs_tfMRI.txt | wc -l)
mv IDs_tfMRI.txt IDs_tfMRI-${Cnt}.txt
