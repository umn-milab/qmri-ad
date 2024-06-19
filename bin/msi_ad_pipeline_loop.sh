#!/bin/bash

PROJECTFOLDER=$1
MAXCPUS=16
DSICPUS=128
CUDAVERSION=11.2
RESULTFOLDER=$PROJECTFOLDER/results
cd $PROJECTFOLDER/bids

red=`tput setaf 1`
green=`tput setaf 2`
yellow=`tput setaf 3`
cyan=`tput setaf 6`
magneta=`tput setaf 5`
bold=$(tput bold)
normal=$(tput sgr0)

batch_init()
{
    PBSFILE=$1
    echo "#!/bin/bash -l" > $PBSFILE.sh
    echo "#SBATCH --time=$2" >> $PBSFILE.sh
    echo "#SBATCH --ntasks=$3" >> $PBSFILE.sh
    echo "#SBATCH --mem=$4" >> $PBSFILE.sh
    echo "#SBATCH --tmp=$5" >> $PBSFILE.sh
    #echo "#SBATCH -p small" >> $PBSFILE.sh
    echo "#SBATCH --mail-type=FAIL" >> $PBSFILE.sh
    echo "#SBATCH --mail-user=$6@umn.edu" >> $PBSFILE.sh
}

create_folders()
{
    ROOTFOLDER=$1
    SUB=$2
    if [ ! -d $ROOTFOLDER ];then
        mkdir -p $ROOTFOLDER
        chmod -R 770 $ROOTFOLDER
    fi
    if [ ! -d $ROOTFOLDER/$SUB ];then
        mkdir -p $ROOTFOLDER/$SUB
        chmod -R 770 $ROOTFOLDER/$SUB
    fi
    if [ ! -d $ROOTFOLDER/$SUB/log-msi ];then
        mkdir -p $ROOTFOLDER/$SUB/log-msi
        chmod -R 770 $ROOTFOLDER/$SUB/log-msi
    fi
}

for SUB in sub-0073/ses-* ;do # sub-0073/ses-* sub-0105/ses-* sub-0115/ses-* sub-0117/ses-* sub-0120/ses-* sub-0126/ses-* sub-0127/ses-* sub-0134/ses-* sub-0137/ses-* sub-0141/ses-* sub-0142/ses-* sub-0144/ses-* sub-0149/ses-* sub-0185/ses-* sub-0050/ses-* sub-0065/ses-* sub-0058/ses-* sub-0074/ses-* sub-0085/ses-* sub-0099/ses-* sub-0104/ses-* sub-0105/ses-* sub-0106/ses-* sub-0112/ses-* sub-0115/ses-* sub-0117/ses-* sub-0127/ses-* sub-0136/ses-* sub-0141/ses-* sub-0142/ses-* sub-0161/ses-* # sub-0060/ses-*
	for NRD in 0;do # 0 1 2
		for PRT in dmri;do #  dmri79 6shell
			if [[ $SUB == "sub-779253/ses-13mo" && $PRT == "dmri79" ]]; then
				echo "$SUB-$PRT-$NRD: dMRI data of poor quality or non-preprocessed"
			else
		        PRTFOLDER=$PRT
			    if [ $NRD -eq 1 ];then
	                JOBFOLDER=$RESULTFOLDER/$PRTFOLDER-nordic
	                tSNRJOBFOLDER=$RESULTFOLDER/tsnr-$PRTFOLDER-nordic
	                SNRJOBFOLDER=$RESULTFOLDER/snr-$PRTFOLDER-nordic
                elif [ $NRD -eq 2 ];then
	                JOBFOLDER=$RESULTFOLDER/$PRTFOLDER-offline
	                tSNRJOBFOLDER=$RESULTFOLDER/tsnr-$PRTFOLDER-offline
	                SNRJOBFOLDER=$RESULTFOLDER/snr-$PRTFOLDER-offline
                else
	                JOBFOLDER=$RESULTFOLDER/$PRTFOLDER
	                tSNRJOBFOLDER=$RESULTFOLDER/tsnr-$PRTFOLDER
	                SNRJOBFOLDER=$RESULTFOLDER/snr-$PRTFOLDER
                fi
                create_folders $JOBFOLDER $SUB
                if [ ! -f $JOBFOLDER/$SUB/dsistudio/Superior_Cerebellar_Peduncle/bedpostX.Superior_Cerebellar_Peduncle.stat.txt ] || [ ! -f $JOBFOLDER/$SUB/dsistudio/Reticular_Tract_R/bedpostX.Reticular_Tract_R.stat.txt ] || [ ! -f $JOBFOLDER/$SUB/dsistudio-tract_voxel_ratio-16/Superior_Cerebellar_Peduncle/bedpostX.Superior_Cerebellar_Peduncle.stat.txt ] || [ ! -f $JOBFOLDER/$SUB/dsistudio-tract_voxel_ratio-16/Reticular_Tract_R/bedpostX.Reticular_Tract_R.stat.txt ] || [ ! -f $JOBFOLDER/$SUB/eddy.qc/qc.pdf ];then
                    STAGE=1
                    for STAGE in `seq 1 9`;do
                        if [ $STAGE -eq 1 ];then
                            TIME="48:45:00"
                            NTASKS=1
                            MEM=2g
                            TMP=2g
                            QUEUE=msismall
                        elif [ $STAGE -eq 2 ];then
                            TIME="06:15:00"
                            NTASKS=1
                            MEM=15g
                            TMP=5g
                            QUEUE=a100-4,a100-8  #v100 # working on mesabi: v100,k40 #,k40
                        elif [ $STAGE -eq 3 ];then
                            TIME="94:45:00"
                            NTASKS=$MAXCPUS
                            MEM=24g
                            TMP=5g
                            QUEUE=msismall
                        elif [ $STAGE -eq 4 ];then
                            TIME="03:15:00"
                            NTASKS=1
                            MEM=5g
                            TMP=5g
                            QUEUE=a100-4,a100-8  #v100 # working on mesabi: v100,k40 #,k40
                        elif [ $STAGE -eq 5 ];then
                            TIME="00:10:00"
                            NTASKS=16
                            MEM=8g
                            TMP=5g
                            QUEUE=msismall
                        elif [ $STAGE -eq 6 ] || [ $STAGE -eq 7 ];then
                            TIME="19:55:00"
                            NTASKS=$DSICPUS
                            MEM=4g
                            TMP=5g
                            QUEUE=msismall
						elif [ $STAGE -eq 8 ] || [ $STAGE -eq 9 ];then
                            TIME="89:55:00"
                            NTASKS=$DSICPUS
                            MEM=8g
                            TMP=5g
                            QUEUE=msismall
                        fi
			            PBSFILE=$JOBFOLDER/$SUB/log-msi/msi_ad_pipeline_stage$STAGE
	                    batch_init $PBSFILE $TIME $NTASKS $MEM $TMP $USER
                        if [ $STAGE -gt 1 ];then
                            echo "#SBATCH --dependency=afterok:$JOBID" >> $PBSFILE.sh
                        fi
                        if [ $STAGE -eq 2 ] || [ $STAGE -eq 4 ];then
                            echo "#SBATCH --gres=gpu:1" >> $PBSFILE.sh
                            #echo "module load cuda/9.1 cuda-sdk/9.1" >> $PBSFILE.sh
							echo "module load cuda/$CUDAVERSION cuda-sdk/$CUDAVERSION" >> $PBSFILE.sh
                        fi
                        if [ $STAGE -ge 6 ];then
                            echo "module load singularity" >> $PBSFILE.sh
                        fi
				        echo "ad_dmri_pipeline.sh $NRD $PRT $SUB $PROJECTFOLDER $STAGE $MAXCPUS $DSICPUS $CUDAVERSION > $PBSFILE.stdout" >> $PBSFILE.sh		
				        chmod 775 $PBSFILE.sh
				        dt=$(date '+%Y/%m/%d %H:%M:%S');
				        if	[ $STAGE -le 5 ];then			
			                JOBID=$(sbatch -p $QUEUE $PBSFILE.sh | sed 's/.* //') > /dev/null
				            echo "${yellow}$dt $SUB: Job ID $JOBID has been submitted for dataset $JOBFOLDER/$SUB${normal}"
			                echo $JOBID > $PBSFILE.$JOBID
			            else
			                TRACTID=$(sbatch -p $QUEUE $PBSFILE.sh | sed 's/.* //') > /dev/null
			                echo "${yellow}$dt $SUB: Job ID $TRACTID has been submitted for dataset $JOBFOLDER/$SUB${normal}" 
			                echo $TRACTID > $PBSFILE.$TRACTID
			            fi
				    done
			    else
			        dt=$(date '+%Y/%m/%d %H:%M:%S');
			        echo "${green}$dt $SUB: dMRI analysis appears to be completed for dataset $JOBFOLDER/$SUB${normal}"
		        fi
			fi
		done
	done
done
