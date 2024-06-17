#!/bin/bash
DATAFOLDER=rlaboune@agate.msi.umn.edu:/home/shapiroe/shared/ADAI
MIRRORFOLDER=/home/porto-raid4/nestrasil-data/msi-rsync

rsyncommand="rsync -e ssh -avzur --no-o --no-g --relative"

if [ ! -d $MIRRORFOLDER ];then
	mkdir -p $MIRRORFOLDER
	chmod 770 $MIRRORFOLDER
fi

`echo $rsyncommand $DATAFOLDER/results/dmri $MIRRORFOLDER` # $DATAFOLDER/bids
#rm -r rlaboune@agate.msi.umn.edu\:
