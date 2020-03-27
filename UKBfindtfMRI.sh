#!/bin/bash

dirSubjImg="${UKB_SMS}/FN-eid8107_tfMRI-6k.txt"
dirSubjIDsSS="${UKB_SMS}/IDs-eid8107_tfMRI-6k.txt"
dirSubjIDsSS1="${UKB_SMS}/IDs-eid8107_tfMRI-1k.txt"
dirSubjIDsTN="${UKB_SMS}/IDs-eid34077_tfMRI-6k.txt"
dirSubjs="${UKB_SUBJECTS}/subjects4"
tmp=${UKB_SMS}/tmp$$

cd $dirSubjs

# First two path/prune's are important to stop find wasting time in non-T1 directories
ls -1 */fMRI/tfMRI.fsf > $dirSubjImg

awk -F/ '{print $1}' ${dirSubjImg} > ${dirSubjIDsSS}

shuf ${dirSubjIDsSS} | head -n 1000 > ${dirSubjIDsSS1}


# funpack \
#     $tmp \
#     $dirSubjIDsSS \
#     ${UKB_SMS}/bridge_8107_34077.tsv

# # Create plain text list of (our, TN) IDs
# awk -F'\t' '(NR>1){print $2}' \
#     $tmp > \
#     $dirSubjIDsTN

# rm $tmp


