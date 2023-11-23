#!/bin/bash

dirSubjs="${UKB_SUBJECTS}/subjectsAll"

   dirSubjImg="${UKB_SMS}/FN-eid8107_tfMRI-72k.txt"
 dirSubjIDsSS="${UKB_SMS}/IDs-eid8107_tfMRI-72k"
 dirSubjIDsTN="${UKB_SMS}/IDs-eid34077_tfMRI-72k"

tmp=${UKB_SMS}/tmp$$

cd $dirSubjs

cp /dev/null $dirSubjImg
for i in {0..9} ; do
    for j in {0..9} ; do
	echo -n "."
	ls -1 *${i}${j}/fMRI/tfMRI.fsf >> $dirSubjImg
    done
done
echo " done."

awk -F/ '{print $1}' ${dirSubjImg} >> ${dirSubjIDsSS}.txt
echo "eid" > ${dirSubjIDsSS}.csv
cat ${dirSubjIDsSS}.txt >> ${dirSubjIDsSS}.csv

# shuf ${dirSubjIDsSS} | head -n 1000 > ${dirSubjIDsSS1}
# comm -3 <(sort ${dirSubjIDsSS}) <(${dirSubjIDsSS1}) ${dirSubjIDsSS1} | tr -d '\t' > ${dirSubjIDsSS5}

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

rm $tmp
