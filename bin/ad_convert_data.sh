#!/bin/bash
DATAFOLDER=/home/range1-raid1/labounek/data-on-porto/AD
#DATAFOLDER=/home/shapiroe/shared/AD

DICOMFOLDER=$DATAFOLDER/dicom
BIDSFOLDER=$DATAFOLDER/bids

cd $DICOMFOLDER
for SUBSESS in 20*;do
    SUB=$(echo $SUBSESS | cut -d '-' -f3)
	SUBstr=$(printf %04d $SUB)
    SESS=01
	SESSstr=$SESS
	if [ ! -d $BIDSFOLDER/sub-$SUBstr/ses-$SESSstr/anat ];then
        dcm2bids -d $SUBSESS -o $BIDSFOLDER -c ~/git/qmri-ad/etc/config-bids.json -p $SUBstr -s $SESSstr
		exit
    fi
done
