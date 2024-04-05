#!/bin/bash
PREPROCMETHOD=$1
PRTCL=$2
SUB=$3
DATAFOLDER=$4
STAGE=$5
MAXCPUS=$6
DSICPUS=$7

# Define BINDIR
export BINDIR=$(echo $0 | sed 's:/[^/]*$::' | sed 's:/[^/]*$::')

# Looking for source config file which setup paths to libraries as MATLAB, SPM, FSL or SCT
# There are two possible locations ~/.dcm-pro/config and $BINDIR/etc/config
# ~/.qmri-ad/config overwrites $BINDIR/etc/config setting if same variable is setup over both files
source "$BINDIR"/etc/config
if [ -f ~/.qmri-ad/config ];then
	source ~/.qmri-ad/config
fi

DICOMFOLDER=$DATAFOLDER/dicom
NIIFOLDER=$DATAFOLDER/bids
RESULTFOLDER=$DATAFOLDER/results
EXCLUDELISTFOLDER=$RESULTFOLDER/exclude
MODFILEFOLDER=$RESULTFOLDER/manual-modification

DMRI79RESULT=$RESULTFOLDER/dmri

#FSFOLDER=$DATAFOLDER/results/fs
#ITKFOLDER=$DATAFOLDER/results/itk-snap

if [ ! -d $RESULTFOLDER ];then
	mkdir $RESULTFOLDER
        chmod 770 $RESULTFOLDER
fi
if [ ! -d $DMRI79RESULT ];then
	mkdir -p $DMRI79RESULT
    chmod -R 770 $DMRI79RESULT
fi

ad_dmri_process.sh $NIIFOLDER/$SUB/dwi $DMRI79RESULT/$SUB $SUB dmri $MODFILEFOLDER $STAGE $MAXCPUS $DSICPUS
