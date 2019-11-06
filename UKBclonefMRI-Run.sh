#!/bin/bash

Base=/vols/Scratch/ukbiobank/nichols

$Base/SCRIPTS/UKBclonefMRI.sh -t $Base/TEMPLATES/tfMRI_template-0sm.fsf \
    $Base/ReProc $Base/SCRIPTS/ReProcAll.txt
