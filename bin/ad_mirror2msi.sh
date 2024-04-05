#!/bin/bash
DATAFOLDER=/home/porto-raid4/nestrasil-data/AD
MIRRORFOLDER=rlaboune@mesabi.msi.umn.edu:/home/shapiroe/shared/AD

rsyncommand="rsync -e ssh -avzur --no-o --no-g --relative"

#if [ ! -d $MIRRORFOLDER ];then
#	mkdir -p $MIRRORFOLDER
#	chmod 770 $MIRRORFOLDER
#fi

cd $DATAFOLDER
`echo $rsyncommand bids $MIRRORFOLDER` # results/dmri
