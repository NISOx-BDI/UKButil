#!/bin/bash

dirSubjs="${UKB_SUBJECTS}/subjectsAll"

dirSubjImg="${UKB_SMS}/FN-eid8107_VBM-72k.txt"
dirSubjIDsSS="${UKB_SMS}/IDs-eid8107_VBM-72k.txt"
dirSubjIDsTN="${UKB_SMS}/IDs-eid34077_VBM-72k.txt"

tmp=${UKB_SMS}/tmp$$

cd $dirSubjs

cp /dev/null $dirSubjImg
for i in {0..9} ; do
    for j in {0..9} ; do
	echo -n "."
	ls -1 *${i}${j}/T1/T1_vbm/T1_GM_to_template_GM_mod.nii.gz >> $dirSubjImg
    done
done
echo " done."

awk -F/ '{print $1}' ${dirSubjImg} >> ${dirSubjIDsSS}.txt
echo "eid" > ${dirSubjIDsSS}.csv
cat ${dirSubjIDsSS}.txt >> ${dirSubjIDsSS}.csv


module load Anaconda3/2023.07-2
eval "$(conda shell.bash hook)"
conda activate py310

fmrib_unpack \
    ${tmp}.tsv \
    ${dirSubjIDsSS}.csv \
    ${UKB_SMS}/bridge_8107_34077-long.tsv

# Create plain text list of (our, TN) IDs
awk -F'\t' '(NR>1){print $2}' \
    ${tmp}.tsv > \
    ${dirSubjIDsTN}.txt

rm ${tmp}.tsv

