# UKButil

Utilities to share between fMRIB and BDI compute environments.

Set global environmental variable for each site.  In FMRIB:

```
export UKB_SMS=/vols/Data/ukbiobank/FMRIB/SMS
export UKB_SUBJECTS=/vols/Data/ukbiobank/FMRIB/IMAGING/data3
export UKB_SCRIPTS=/vols/Scratch/ukbiobank/nichols/SCRIPTS
export UKB_TEMPLATES=/vols/Scratch/ukbiobank/nichols/TEMPLATES
```

In BDI
```
export UKB_SMS=/well/nichols/projects/UKB/SMS
export UKB_SUBJECTS=/well/win-biobank/projects/imaging/data/data3
export UKB_SCRIPTS=/well/nichols/scripts
export UKB_TEMPLATES=/well/nichols/scripts/TEMPLATES
```

# Scripts for selecting/processing files

 - `UKBfindVBM.sh`: Find all subjects with VBM data; basically a find one-liner.
 - `UKBsmoothVBM.sh`: [FMRIB-specific! Needs updating!] Apply smoothing to VBM outputs.

 - `Run_WarpfMRI-1.sh`: Create command files and launch fsl_sub to complete warping, calling `UKBwarp_tfMRI.sh`.
 - `Run_WarpfMRI-2.sh`: QC/post processsing: Create count mask, run slicesdir, compute 1-sample t-test.

 - `UKBwarp_tfMRI.sh`: Run apply warp for a given task fMRI FEAT results directory.

# Utility function (functions to be run once, or only infrequently)

 - `ConvCategories.sh`: Converts from a one-category-per-column format used at UKB Rodeo to the current `ukbparse` format.
 - `UKBscrape.sh`: Pull all possible field (variable) ID's from the UKB Showcase website.


# FMRIB-only files, OLD... don't use for now
 - UKBclonefMRI-Run.sh
 - UKBclonefMRI.sh
