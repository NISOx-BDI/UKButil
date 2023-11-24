#!/bin/bash
# 
# "Run" script to warp task fMRI images to MNI space, part 1:
#
# Create and queue jobs to do the warping
#

module add fsl

cd /well/nichols/scripts

IDs=$UKB_SMS/IDs-eid8107_tfMRI-72k.txt
UKButil=/well/nichols/scripts/UKButil


Dest=/well/nichols/projects/UKB/IMAGING/tfMRI-MNI/cope5

$UKButil/UKBwarp_tfMRI.sh -v -1        $IDs stats/cope5 $Dest Cmd_Warp_tfMRIcope.txt
fsl_sub -l ~/logs -t Cmd_Warp_tfMRIcope.txt


Dest=/well/nichols/projects/UKB/IMAGING/tfMRI-MNI/mask

$UKButil/UKBwarp_tfMRI.sh -v -1 -i nn  $IDs mask        $Dest Cmd_Warp_tfMRImask.txt
fsl_sub -l ~/logs -t Cmd_Warp_tfMRImask.txt
