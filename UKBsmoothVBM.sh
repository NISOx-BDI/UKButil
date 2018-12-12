#!/bin/bash

VBMsubj=/vols/Scratch/ukbiobank/nichols/subjs_vbm.txt 
ImgIn=/vols/Data/ukbiobank/FMRIB/IMAGING/data3/SubjectsAll/
ImgOut=/vols/Scratch/ukbiobank/nichols/SelectiveInf/SubjectsVBM/
ImgNmOut=T1_GM_to_template_GM_mod_s3
ScriptOut=/vols/Scratch/ukbiobank/nichols/SCRIPTS/RunSmVBM.sh

echo '#!/bin/bash' > $ScriptOut
chmod +x $ScriptOut

sed 's@^@fslmaths '"${ImgIn}"'@;s/$/ -s 3 /' $VBMsubj > /tmp/$$

awk -F/ '{printf("%s %s/%s_%s\n"), $0,"'"$ImgOut"'",$10,"'"$ImgNmOut"'"}' /tmp/$$ >> $ScriptOut

/bin/rm /tmp/$$
