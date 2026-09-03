#!/bin/bash

#DATAFOLDER=$1
#DATAFOLDER=/home/range1-raid1/labounek/data-on-porto/ADAI
DATAFOLDER=/home/range1-raid1/labounek/data-on-porto/ADNI/ADNI_ADAI_match

NIIFOLDER=$DATAFOLDER/bids
RESULTFOLDER=$DATAFOLDER/results
TABLEFOLDER=$DATAFOLDER/tables

#CONNECTIVITYRESULTFOLDER=$RESULTFOLDER/dmri-hamza/adai_pass_10M_connectivity/dsi_studio_output
CONNECTIVITYRESULTFOLDER=$RESULTFOLDER/dmri-hamza/adni_adai_match_pass_10M_connectivity/dsi_studio_output

cd $CONNECTIVITYRESULTFOLDER

for SUB in sub-*; do
	SUBSESSFOLDER=$(ls -d $RESULTFOLDER/dmri/$SUB/ses-* | head -n 1)
	if [ ! -d $SUBSESSFOLDER/dsistudio-connectivity ]; then
		mkdir $SUBSESSFOLDER/dsistudio-connectivity
		chmod 770 $SUBSESSFOLDER/dsistudio-connectivity
	fi
	for ATLAS in HCP-MMP Brodmann Gordan_rsfMRI333; do
		NETWORKFILE=track_${SUB}.tt.gz.$ATLAS.count.pass.network_measures
		tail -n 15 $SUB/$NETWORKFILE.txt > $SUBSESSFOLDER/dsistudio-connectivity/$NETWORKFILE.nodes.tsv
		echo -e 'network_measures\tvalue' > $SUBSESSFOLDER/dsistudio-connectivity/$NETWORKFILE.global.tsv
		head -n 27 $SUB/$NETWORKFILE.txt >> $SUBSESSFOLDER/dsistudio-connectivity/$NETWORKFILE.global.tsv
	done
	chmod 660 $SUBSESSFOLDER/dsistudio-connectivity/track*.tsv
	echo "$SUB done"
done
