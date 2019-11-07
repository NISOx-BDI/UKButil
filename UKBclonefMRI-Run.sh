#!/bin/bash

Base=/vols/Scratch/ukbiobank/nichols

$Base/SCRIPTS/UKButil/UKBclonefMRI.sh -t $Base/TEMPLATES/tfMRI_template-0sm.fsf \
    $Base/ReProc0sm $Base/SCRIPTS/ReProcAll.txt
