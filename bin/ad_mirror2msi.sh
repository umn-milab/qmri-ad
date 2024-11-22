#!/bin/bash
DATAFOLDER=/home/porto-raid4/nestrasil-data/ADAI
MIRRORFOLDER=rlaboune@agate.msi.umn.edu:/home/shapiroe/shared/ADAI

DATAFOLDER2=/home/range1-raid1/labounek/data-on-porto/ADNI/ADNI_ADAI_match
MIRRORFOLDER2=rlaboune@agate.msi.umn.edu:/home/shapiroe/shared/ADNI/ADNI_ADAI_match

rsyncommand="rsync -e ssh -avzur --no-o --no-g --relative"

#if [ ! -d $MIRRORFOLDER ];then
#	mkdir -p $MIRRORFOLDER
#	chmod 770 $MIRRORFOLDER
#fi

cd $DATAFOLDER
`echo $rsyncommand bids $MIRRORFOLDER` # results/dmri

cd $DATAFOLDER2
`echo $rsyncommand bids $MIRRORFOLDER2` # results/dmri
