#!/bin/bash

shopt -s nullglob

featdir=$(grep outputdir "$1"|tail -1|awk '{print $NF}'|sed 's/"//g')
feat "$1"
cd "$featdir"
while [ ! -f rendered_thresh_zstat1.png ] ; do
    sleep 120
done
sleep 60
rm -rf tsplot
rm -f \
    rendered_thresh* \
    thresh_z* \
    cluster_* \
    lmax_* \
    design*{png,ppm} \
    filtered_func_data.nii.gz \
    prefiltered_func_data.nii.gz \
    stats/z* \
    stats/threshac1.nii.gz \
    thresh_*.nii.gz \
    stats/res4d*
mv  reg/example_func2standard_warp.nii.gz .
rm -rf reg
mkdir reg
mv example_func2standard_warp.nii.gz reg

