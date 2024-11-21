#!/bin/bash
DATAFOLDER=/home/range1-raid1/labounek/data-on-porto/ADNI/ADNI_ADAI_match
#DATAFOLDER=/home/shapiroe/shared/ADAI

DICOMFOLDER=$DATAFOLDER/dicom/ADNI
BIDSFOLDER=$DATAFOLDER/bids

TSVFILE=$DATAFOLDER/ADAI-ADNI_matched.tsv

lin=1
while IFS=$'\t' read -r -a data; do
	if [ $lin -gt 1 ];then
		SUB="${data[0]}"
		SESS="${data[19]}"
		SCANDATE="${data[7]}"

		SUBstr=$(echo "${SUB//_}")
		SUBstr=sub-$SUBstr
		SESSstr=ses-$SESS
		MM=$(echo $SCANDATE | cut -d '/' -f1)
		DD=$(echo $SCANDATE | cut -d '/' -f2)
		YYYY=$(echo $SCANDATE | cut -d '/' -f3)

		#echo $SUBstr
		#echo $SESSstr
		#echo $SCANDATE
		#echo $DD
		#echo $MM
		#echo $YYYY

		DICOMDATA=$DICOMFOLDER/$SUB/*/$YYYY-$MM-$DD*/*
		if [ ! -d $BIDSFOLDER/$SUBstr/$SESSstr/dwi ];then
			echo "dcm2bids -d $DICOMDATA -o $BIDSFOLDER -c ~/git/qmri-ad/etc/config-bids.json -p $SUBstr -s $SESSstr"
			dcm2bids -d $DICOMDATA -o $BIDSFOLDER -c ~/git/qmri-ad/etc/config-bids.json -p $SUBstr -s $SESSstr
			#exit
		fi
	fi
	lin=$(($lin+1))
done < $TSVFILE
