#!/bin/bash

dirSubjIDsSS="${UKB_SMS}/IDs-eid8107_VBM-6k.txt"
dirSubjIDsTN="${UKB_SMS}/IDs-eid34077_VBM-6k.txt"
dirSubjs="${UKB_SUBJECTS}/subjects4"
tmp=${UKB_SMS}/tmp$$

cd $dirSubjs

# First two path/prune's are important to stop find wasting time in non-T1 directories
find -L . \
    \! -readable -prune -o \
    -path '*/T2*' -prune -o \
    -path '*/[lfSdIQ]*' -prune -o \
    -path "*/T1/T1_vbm/T1_GM_to_template_GM_mod.nii.gz" -print | \
    awk -F/ '{print $2}' > ${dirSubjIDsSS}

# Create temp briding file just for these subjects
ukbparse --no_builtins --overwrite \
    $tmp \
    $dirSubjIDsSS \
    ${UKB_SMS}/bridge_8107_34077.tsv

# Create plain text list of (our, TN) IDs
awk -F'\t' '(NR>1){print $2}' \
    $tmp > \
    $dirSubjIDsTN

rm $tmp


