#!/bin/bash

cd /vols/Scratch/ukbiobank/FMRIB/IMAGING/data3/SubjectsAll

dirSubjList="/vols/Scratch/ukbiobank/nichols/subjs_vbm.txt"
dirSubjs="/vols/Data/ukbiobank/FMRIB/IMAGING/data3/SubjectsAll"

cd $dirSubjs

find -L . \! -readable -prune -o \
    -path '*/T2*' -prune -o \
    -path '*/[lfSdIQ]*' -prune -o \
    -path "*/T1/T1_vbm/T1_GM_to_template_GM_mod.nii.gz" -print | \
    > $dirSubjList


