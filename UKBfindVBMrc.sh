#!/bin/bash

dirSubjList="${UKB_SMS}/ukb25120-VBM-6k.txt"
dirSubjs="${UKB_SUBJECTS}/subjects4"

cd $dirSubjs

find -L . \! -readable -prune -o -path "*/T1/T1_vbm/T1_GM_to_template_GM_mod.nii.gz" -print > $dirSubjList


