#!/bin/bash

dirSubjList="${UKB_SMS}/ID-eid8107_VBM-6k.txt"
dirSubjs="${UKB_SUBJECTS}/subjects4"

cd $dirSubjs

# First two path/prune's are important to stop find wasting time in non-T1 directories
find -L . \
    \! -readable -prune -o \
    -path '*/T2*' -prune -o \
    -path '*/[lfSdIQ]*' -prune -o \
    -path "*/T1/T1_vbm/T1_GM_to_template_GM_mod.nii.gz" -print > $dirSubjList
