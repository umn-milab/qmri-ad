#!/bin/bash
NIIFOLDER=$1
RESULTFOLDER=$2
SUB=$3
PROTOCOL=$4
MODFILEFOLDER=$5
STAGE=$6
MAXCPUS=$7
DSICPUS=$8

if [ $STAGE -eq 2 ];then
    export ITK_GLOBAL_DEFAULT_NUMBER_OF_THREADS=$MAXCPUS
    export OMP_NUM_THREADS=$MAXCPUS
fi

MODFILEFOLDER=$MODFILEFOLDER/$PROTOCOL/$SUB

red=`tput setaf 1`
green=`tput setaf 2`
yellow=`tput setaf 3`
cyan=`tput setaf 6`
magneta=`tput setaf 5`
bold=$(tput bold)
normal=$(tput sgr0)

print_help()
{
	LINE="===================================================================================================================="	
	SCRIPT_NAME=${0##*/}
	VERSION=27.03.2021	

	echo -e "Help in progress"

	#echo -e "$LINE\nHelp for script performing analysis of the spinal cord diffusion data (ZOOMit and/or RESOLVE), version $VERSION."
	#echo -e "Analysis contains:\n\tdiffusion preprocessing (merge AP and PA b0 images) with or withnout motion correction by sct_dmri_moco\n\ttopup and eddy (with whole FOV or with manually segmented mask of SC from topup_mean image)\n\tDTI estimation (using dtifit)\n\tregistration between T2TRA and DIFF spaces\n\tvertebrae labeling in DIFF space\n\tmasking results from dtifit by mask of SC"
	#echo -e "REQUIREMENTS: Installed bash interpreter, Matlab, FSL and Spinal Cord Toolbox libraries.\n$LINE"
	#echo -e "USAGE:\n\n$SCRIPT_NAME <path to subjects directory> <subject> <diff. seq. order>\n\nEXAMPLE:\n\n$SCRIPT_NAME /md2/NA-CSD 2007B 11001"
	#echo -e "or\n$SCRIPT_NAME /md2/NA-CSD subjects.txt\n$LINE"
	#echo -e "Valosek, Labounek 2018\tfMRI laboratory, Olomouc, CZ\n$LINE"
	exit
}

run_matlab()
{
	# Run Matlab without GUI in bash command line
	$MATLABDIR/bin/matlab -nosplash -nodisplay -nodesktop -r  "$1"
}

main()
{
	if [ $PROTOCOL == "dmri" ];then
	    APSTRING=sub-*_ses-*_acq-mb3_dir-AP_dwi
	    PASTRING=sub-*_ses-*_acq-mb3_dir-PA_dwi
		DMRI_AP=$NIIFOLDER/$APSTRING.nii.gz
		DMRI_PA=$NIIFOLDER/$PASTRING.nii.gz
		READOUT=0.0632499
		BVAL_AP=$NIIFOLDER/$APSTRING.bval
		BVAL_PA=$NIIFOLDER/$PASTRING.bval
		BVEC_AP=$NIIFOLDER/$APSTRING.bvec
		BVEC_PA=$NIIFOLDER/$PASTRING.bvec
		JSON_AP=$NIIFOLDER/$APSTRING.json
		JSON_PA=$NIIFOLDER/$PASTRING.json
	fi
	
	PROTDIR=$(echo ${BVAL_AP} | sed 's:.*/::' | cut -d '_' -f3 | cut -d '-' -f2 | cut -d 'd' -f1)
	
	if [ ! -d $RESULTFOLDER ];then
		mkdir -p $RESULTFOLDER
		chmod 770 $RESULTFOLDER
	fi
	if [ ! -d $RESULTFOLDER/mask ];then
		mkdir -p $RESULTFOLDER/mask
		chmod 770 $RESULTFOLDER/mask
	fi
	if [ ! -d $RESULTFOLDER/mask_mni ];then
		mkdir -p $RESULTFOLDER/mask_mni
		chmod 770 $RESULTFOLDER/mask_mni
	fi
	#if [ ! -d $MPRFOLDER/mask_mni ];then
	#	mkdir -p $MPRFOLDER/mask_mni
	#	chmod 770 $MPRFOLDER/mask_mni
	#fi
	if [ ! -d $RESULTFOLDER/dsistudio ];then
		mkdir -p $RESULTFOLDER/dsistudio
		chmod 770 $RESULTFOLDER/dsistudio
	fi
	if [ ! -d $RESULTFOLDER/dsistudio-tract_voxel_ratio-16 ];then
		mkdir -p $RESULTFOLDER/dsistudio-tract_voxel_ratio-16
		chmod 770 $RESULTFOLDER/dsistudio-tract_voxel_ratio-16
	fi

    if [ $STAGE -eq 1 ] || [ $STAGE -eq 0 ]; then
	    if [ ! -f $RESULTFOLDER/b0.nii.gz ] || [ ! -f $RESULTFOLDER/eddy_input_ap.json ];then
		    diff_prep $DMRI_AP $DMRI_PA $READOUT $RESULTFOLDER $BVAL_AP $BVAL_PA $BVEC_AP $BVEC_PA	$PROTOCOL $JSON_AP $JSON_PA # Call diff_preop function
	    else
		    echo "${green}$(date +%x_%T): Preprocessing of diffusion data in $RESULTFOLDER folder has been done before.${normal}"
	    fi
	    if [ ! -f $RESULTFOLDER/b0_topup.nii.gz ]; then
		    topup_function $RESULTFOLDER		# Call function for topup
	    else
		    echo "${green}$(date +%x_%T): topup on data in $RESULTFOLDER folder has been done before.${normal}"
	    fi
    elif [ $STAGE -eq 2 ] || [ $STAGE -eq 0 ];then
	    if [ ! -f $RESULTFOLDER/eddy.nii.gz ]; then
	        if [ $STAGE -eq 0 ];then
		        export LD_LIBRARY_PATH=/opt/local/cuda-9.1/lib64:$LD_LIBRARY_PATH
		        export PATH=/opt/local/cuda-9.1/lib64:/opt/local/cuda-9.1/bin:$PATH
		    fi
		    eddy_function $RESULTFOLDER # Call function for eddy
	    else
		    echo "${green}$(date +%x_%T): eddy on data in $RESULTFOLDER folder has been done before.${normal}"
	    fi
	    #if [ -f $MODFILEFOLDER/eddy.nii.gz ];then
		#    echo "Manually modified eddy files have been copied."
		#    cp $MODFILEFOLDER/eddy.nii.gz $RESULTFOLDER/eddy.nii.gz
		#    cp $MODFILEFOLDER/eddy_input.bval $RESULTFOLDER/eddy_input.bval
		#    cp $MODFILEFOLDER/eddy.eddy_rotated_bvecs $RESULTFOLDER/eddy.eddy_rotated_bvecs
	    #fi
    elif [ $STAGE -eq 3 ] || [ $STAGE -eq 0 ];then
	    if [ ! -f $RESULTFOLDER/dti_FA.nii.gz ]; then
		    dtifit_function $RESULTFOLDER		# Call function for dtifit
	    else
		    echo "${green}$(date +%x_%T): Estimation of DTI model using dtifit on data in $RESULTFOLDER folder is done.${normal}"
	    fi
	    if [ ! -f $RESULTFOLDER/dti_RD.nii.gz ]; then
		    fslmaths $RESULTFOLDER/dti_L2.nii.gz -add $RESULTFOLDER/dti_L3.nii.gz -div 2 $RESULTFOLDER/dti_RD.nii.gz
	    fi
	    if [ ! -L $RESULTFOLDER/dti_AD.nii.gz ]; then
		    cd $RESULTFOLDER
		    ln -s dti_L1.nii.gz dti_AD.nii.gz
	    fi 
	    if [ ! -L $RESULTFOLDER/dsistudio/data.nii.gz ]; then
		    dt=$(date '+%Y/%m/%d %H:%M:%S');
		    echo "$dt $SUB: symbolic link of dmri data into dsistudio folder started"
		    cd $RESULTFOLDER/dsistudio
		    ln -s ../data.nii.gz data.nii.gz
		    ln -s ../bvals bvals
		    ln -s ../bvecs bvecs
		    ln -s ../nodif_brain_mask.nii.gz nodif_brain_mask.nii.gz
		    dt=$(date '+%Y/%m/%d %H:%M:%S');
		    echo "$dt $SUB: symbolic link of dmri data into dsistudio folder done"
	    fi
		if [ ! -L $RESULTFOLDER/dsistudio-tract_voxel_ratio-16/data.nii.gz ]; then
		    dt=$(date '+%Y/%m/%d %H:%M:%S');
		    echo "$dt $SUB: symbolic link of dmri data into dsistudio-tract_voxel_ratio-16 folder started"
		    cd $RESULTFOLDER/dsistudio-tract_voxel_ratio-16
		    ln -s ../data.nii.gz data.nii.gz
		    ln -s ../bvals bvals
		    ln -s ../bvecs bvecs
		    ln -s ../nodif_brain_mask.nii.gz nodif_brain_mask.nii.gz
		    dt=$(date '+%Y/%m/%d %H:%M:%S');
		    echo "$dt $SUB: symbolic link of dmri data into dsistudio-tract_voxel_ratio-16 folder done"
	    fi
	    if [ ! -f $RESULTFOLDER/NODDI/matlab-toolbox/FIT_odi.nii.gz ]; then
		    noddimatlab_function $RESULTFOLDER	# Call function for dtifit
	    else
		    echo "${green}$(date +%x_%T): Estimation of NODDI model using NODDI-MATLAB-Toolbox on data in $RESULTFOLDER folder is done.${normal}"
	    fi
	    if [ ! -f $RESULTFOLDER/diff2jhu_warp.nii.gz ];then
		    dt=$(date '+%Y/%m/%d %H:%M:%S');
		    echo "$dt $SUB: JHU-FA to diff registration started"
		    fsl_reg $RESULTFOLDER/dti_FA.nii.gz $FSLDIR/data/atlases/JHU/JHU-ICBM-FA-1mm.nii.gz $RESULTFOLDER/diff2jhu -FA -e
		    dt=$(date '+%Y/%m/%d %H:%M:%S');
		    echo "$dt $SUB: JHU-FA to diff registration done"
            fi
            if [ ! -f $RESULTFOLDER/jhu2diff_warp.nii.gz ];then
		    invwarp -w $RESULTFOLDER/diff2jhu_warp.nii.gz -o $RESULTFOLDER/jhu2diff_warp.nii.gz -r $RESULTFOLDER/dti_FA.nii.gz
            fi
            if [ ! -f $RESULTFOLDER/jhu_labels.nii.gz ];then
		    dt=$(date '+%Y/%m/%d %H:%M:%S');
		    echo "$dt $SUB: Warp JHU-ICBM atlas to diff space started"
		    applywarp -i $FSLDIR/data/atlases/JHU/JHU-ICBM-labels-1mm.nii.gz -r $RESULTFOLDER/dti_FA.nii.gz -o $RESULTFOLDER/jhu_labels.nii.gz -w $RESULTFOLDER/jhu2diff_warp.nii.gz --interp=nn
		    dt=$(date '+%Y/%m/%d %H:%M:%S');
		    echo "$dt $SUB: Warp JHU-ICBM atlas to diff space done"
            fi
	    if [ ! -f $RESULTFOLDER/ants_jhu_labels.nii.gz ];then
		    dt=$(date '+%Y/%m/%d %H:%M:%S');
		    echo "$dt $SUB: JHU-FA to diff registration started"
		    fslmaths $FSLDIR/data/atlases/JHU/JHU-ICBM-FA-1mm.nii.gz -bin $RESULTFOLDER/JHU-ICBM-FA-1mm_mask.nii.gz
		    DIM=3
		    II=$FSLDIR/data/atlases/JHU/JHU-ICBM-FA-1mm.nii.gz
		    JJ=$RESULTFOLDER/dti_FA.nii.gz

		    OUTPUTNAME=$RESULTFOLDER/ants  # define the output prefix
		    ITS=" -i 100x100x30 " # 3 optimization levels

		    # different transformation models you can choose
		    TSYNWITHTIME=" -t SyN[0.25,5,0.01] -r Gauss[3,0] " # spatiotemporal (full) diffeomorphism
		    TGREEDYSYN=" -t SyN[0.15] -r Gauss[3,0] "         # fast symmetric normalization
		    TELAST=" -t Elast[1] -r Gauss[0.5,3] "           # elastic
		    TEXP=" -t Exp[0.5,10] -r Gauss[0.5,3] "          # exponential

		    # different metric choices for the user
		    INTMSQ=" -m MSQ[${II},${JJ},1,0] "
		    INTMI=" -m MI[${II},${JJ},1,32] "
		    INTCC=" -m CC[${II},${JJ},1,4] "

		    # these are the forward and backward warps.
		    INVW=" -i ${OUTPUTNAME}Affine.txt ${OUTPUTNAME}InverseWarp.nii.gz "
		    FWDW=" ${OUTPUTNAME}Warp.nii.gz ${OUTPUTNAME}Affine.txt "

		    # SETUP HERE THE REGISTRATION
		    # __________________________________________________________________
		    INT=$INTCC  # choose a  metric ( here , cross-correlation )
		    TRAN=$TGREEDYSYN  # choose a transformation
		    #____________________________________________________________________
		    
		    # run the registration
		    ${ANTSPATH}/ANTS $DIM -o $OUTPUTNAME $ITS $TRAN $INT -x $RESULTFOLDER/JHU-ICBM-FA-1mm_mask.nii.gz

		    # this is how you apply the output transformation
		    #${ANTSPATH}/WarpImageMultiTransform $DIM ${II} ${OUTPUTNAME}IItoJJ.nii.gz -R ${JJ} $INVW
		    #${ANTSPATH}/WarpImageMultiTransform $DIM ${JJ} ${OUTPUTNAME}JJtoII.nii.gz -R ${II} $FWDW

		    ${ANTSPATH}/WarpImageMultiTransform $DIM ${II} ${OUTPUTNAME}JHU-ICBM-FA-1mm.nii.gz -R ${JJ} $INVW
		    ${ANTSPATH}/WarpImageMultiTransform $DIM $FSLDIR/data/atlases/JHU/JHU-ICBM-labels-1mm.nii.gz ${OUTPUTNAME}_jhu_labels.nii.gz -R ${JJ} $INVW --use-NN
		    
		    dt=$(date '+%Y/%m/%d %H:%M:%S');
		    echo "$dt $SUB: JHU-FA to diff registration done"
        fi
    elif [ $STAGE -eq 4 ] || [ $STAGE -eq 0 ];then
	    if [ $STAGE -eq 0 ] && [ $HOSTNAME != "atlas11.cmrr.umn.edu" ] && [ $HOSTNAME != "porto.cmrr.umn.edu" ];then
		    echo "$dt $SUB: terminated prior to bedpostx due to non-working CUDA"
		    exit
	    fi
	    if [ ! -f $RESULTFOLDER.bedpostX/dyads1.nii.gz ]; then
		    dt=$(date '+%Y/%m/%d %H:%M:%S');
		    echo "$dt $SUB: bedpostx_gpu started"
		    if [ $STAGE -eq 0 ];then
		        export LD_LIBRARY_PATH=/opt/local/cuda-9.1/lib64:$LD_LIBRARY_PATH
		        export PATH=/opt/local/cuda-9.1/lib64:/opt/local/cuda-9.1/bin:$PATH
		    fi
		    bedpostx_gpu $RESULTFOLDER -n 3 -model 2
		    dt=$(date '+%Y/%m/%d %H:%M:%S');
		    echo "$dt $SUB: bedpostx_gpu done"
	    fi
    elif [ $STAGE -eq 5 ] || [ $STAGE -eq 0 ];then
	    #SESSNAME=$(echo $SUB | awk -F'/' '{print $2}')
	    if [ ! -f $RESULTFOLDER/dsistudio/bedpostX.fib.gz ]; then
		    dt=$(date '+%Y/%m/%d %H:%M:%S');
		    echo "$dt $SUB: export bedpostx results into DSI Studio file format started"
		    run_matlab "addpath('$NIFTITOOLS'),addpath('$BINDIR/matlab'),ad_bedpostx2trackvis('$RESULTFOLDER'),exit"
		    gzip $RESULTFOLDER/dsistudio/bedpostX.fib
		    chmod 660 $RESULTFOLDER/dsistudio/bedpostX.fib.gz
		    dt=$(date '+%Y/%m/%d %H:%M:%S');
		    echo "$dt $SUB: export bedpostx results into DSI Studio file format done"
	    fi
		if [ ! -f $RESULTFOLDER/dsistudio-tract_voxel_ratio-16/bedpostX.fib.gz ]; then
			cp $RESULTFOLDER/dsistudio/bedpostX.fib.gz $RESULTFOLDER/dsistudio-tract_voxel_ratio-16/bedpostX.fib.gz
		fi
    elif [ $STAGE -eq 6 ] || [ $STAGE -eq 7 ] || [ $STAGE -eq 8 ] || [ $STAGE -eq 9 ];then
		if [ $STAGE -eq 6 ] || [ $STAGE -eq 7 ];then # Dose not work for Stage=0
			DSIFOLDER=dsistudio
		elif [ $STAGE -eq 8 ] || [ $STAGE -eq 9 ];then
			DSIFOLDER=dsistudio-tract_voxel_ratio-16
		fi
        DSITRACTLOGFILE=$RESULTFOLDER/$DSIFOLDER/log_tractography_stage$STAGE      
        if [ $STAGE -eq 6 ] || [ $STAGE -eq 8 ];then
            TRACTLIST=Fasciculus,Tract
        elif [ $STAGE -eq 7 ] || [ $STAGE -eq 9 ];then
            TRACTLIST=Cingulum,Capsule,Radiation,Fornix,Lemniscus,Commissure,Callosum,Cerebellum,Peduncle,Vermis
		fi
        if [ $STAGE -eq 0 ];then # Never happens, else everytime
            HDDLIST=/home/porto-raid1,/home/porto-raid2,/home/porto-raid3,/home/porto-raid4,/home/porto-raid5,/home/range1-raid1,/home/range4-raid1
		else
			HDDLIST=/home/shapiroe
        fi
        if [ -f $RESULTFOLDER/$DSIFOLDER/bedpostX.fib.gz ]; then
            if ( [ ! -f $RESULTFOLDER/dsistudio/Reticular_Tract_R/bedpostX.Reticular_Tract_R.stat.txt ] && [ $STAGE -eq 6 ] ) || ( [ ! -f $RESULTFOLDER/dsistudio/Superior_Cerebellar_Peduncle/bedpostX.Superior_Cerebellar_Peduncle.stat.txt ] && [ $STAGE -eq 7 ] ) || ( [ ! -f $RESULTFOLDER/dsistudio-tract_voxel_ratio-16/Reticular_Tract_R/bedpostX.Reticular_Tract_R.stat.txt ] && [ $STAGE -eq 8 ] ) || ( [ ! -f $RESULTFOLDER/dsistudio-tract_voxel_ratio-16/Superior_Cerebellar_Peduncle/bedpostX.Superior_Cerebellar_Peduncle.stat.txt ] && [ $STAGE -eq 9 ] ); then
                dt=$(date '+%Y/%m/%d %H:%M:%S');
			    echo "$dt $SUB: tractography in DSI Studio started"
			    echo "$dt $SUB: tractography in DSI Studio started" > $DSITRACTLOGFILE.txt
			    cd $RESULTFOLDER/$DSIFOLDER
				if [ $STAGE -eq 6 ] || [ $STAGE -eq 7 ];then
			    	singularity exec -B /etc/machine-id -B /var,/run -B $HDDLIST $DSISTUDIOPATH/dsistudio_latest.sif dsi_studio --action=atk --source=bedpostX.fib.gz --track_id=$TRACTLIST --length_ratio=0.60 --tolerance=16 --track_voxel_ratio=4.0 --tip=16 --export_stat=1 --export_trk=1 --overwrite=0 --default_mask=0 --thread_count=$DSICPUS >> $DSITRACTLOGFILE.txt
				elif [ $STAGE -eq 8 ] || [ $STAGE -eq 9 ];then
				    singularity exec -B /etc/machine-id -B /var,/run -B $HDDLIST $DSISTUDIOPATH/dsistudio_latest.sif dsi_studio --action=atk --source=bedpostX.fib.gz --track_id=$TRACTLIST --length_ratio=0.60 --tolerance=16 --track_voxel_ratio=16.0 --tip=16 --export_stat=1 --export_trk=1 --overwrite=0 --default_mask=0 --thread_count=$DSICPUS >> $DSITRACTLOGFILE.txt
					#singularity exec -B /etc/machine-id -B /var,/run -B $HDDLIST $DSISTUDIOPATH/dsistudio_latest.sif dsi_studio --action=trk --source=bedpostX.fib.gz --track_id=$TRACTLIST --fiber_count=200000 --min_length=30 --max_length=250 --method=1 --initial_dir=1 --tip_iteration=16 --smoothing=0 --interpolation=0 --export_stat=1 --export_trk=1 --export_tdi=1 --overwrite=0 --default_mask=0 --thread_count=$DSICPUS >> $DSITRACTLOGFILE.txt
				fi
			    dt=$(date '+%Y/%m/%d %H:%M:%S');
			    echo "$dt $SUB: tractography in DSI Studio done"
			    echo "$dt $SUB: tractography in DSI Studio done" >> $DSITRACTLOGFILE.txt
            fi
        fi
    fi
}

#-----------------------------------------------------------------------------------------------------------
#-----------------------------------------------------------------------------------------------------------
# Function which is called for diffusion preprocessing of RESOLVE data
diff_prep()
{
	
	DMRI_AP=$1
	DMRI_PA=$2
	READOUT=$3
	DATA=$4
	BVAL_AP=$5
	BVAL_PA=$6
	BVEC_AP=$7
	BVEC_PA=$8
	PRT=$9
	JSON_AP=${10} 
	JSON_PA=${11}

	echo "${yellow}$(date +%x_%T): Starting preprocessing of diffusion data in $DATA folder!${normal}"

	cd $DATA
	
	
	fslmerge -a eddy_input.nii.gz ${DMRI_AP} ${DMRI_PA} # Merge AP and PA ZOOMit data into one file
	
	firstCharacter="`cat ${BVAL_PA}`"
	firstCharacter=${firstCharacter:0:1}
	if [ $firstCharacter == " " ];then
		echo "`cat ${BVAL_AP}``cat ${BVAL_PA}`" > eddy_input.bval	# Create eddy_input.bval file by merge bval files of RESOLVE_AP and RESOLVE_PA
	else
		echo "`cat ${BVAL_AP}` `cat ${BVAL_PA}`" > eddy_input.bval	# Create eddy_input.bval file by merge bval files of RESOLVE_AP and RESOLVE_PA
	fi
	firstCharacter="`cat ${BVEC_PA}`"
	firstCharacter=${firstCharacter:0:1}
	if [ $firstCharacter == " " ];then
		paste -d "" ${BVEC_AP} ${BVEC_PA} > eddy_input.bvec
	else
		paste -d " " ${BVEC_AP} ${BVEC_PA} > eddy_input.bvec	# Create eddy_input.bvec file by merge bvec files of RESOLVE_AP and RESOLVE_PA
	fi
	
	cp ${JSON_AP} eddy_input_ap.json
	cp ${JSON_PA} eddy_input_pa.json
	
	B0INDEX=""
	fslsplit eddy_input.nii.gz temporary	# Split RESOLVE data into infividual images
	B0IND=0
	IMAGEID=0
	CATCH=0
	B0USE=4

	B0AP=13

	MERGECOMMAND="fslmerge -a b0.nii.gz" 
	for BVAL in `cat eddy_input.bval`;do			# Create variable B0INDEX containg order of b0 images in merged file
		if [ $BVAL -le 70 ] && [ $CATCH -lt $B0USE ];then
			B0IND=$(($B0IND+1))
			#fslmaths temporary`printf %04d $IMAGEID`.nii.gz -kernel 2D -fmedian temporary`printf %04d $IMAGEID`.nii.gz
			MERGECOMMAND="$MERGECOMMAND temporary`printf %04d $IMAGEID`.nii.gz"
			CATCH=$(($CATCH+1))
		elif [ $BVAL -le 70 ] && [ $CATCH == $(($B0AP-1)) ];then
			CATCH=0
		elif [ $BVAL -le 70 ] && [ $CATCH -ge $B0USE ];then
			CATCH=$(($CATCH+1))
		fi
		B0INDEX="$B0INDEX $B0IND"
		IMAGEID=$(($IMAGEID+1))
	done
	echo $B0INDEX > index.txt
	B0NUM=`cat index.txt | awk '{print $NF}'`			# Count number of b0 images in merged file


	ph=$(cat ${JSON_AP} | grep \"PhaseEncodingDirection\" | cut -d '"' -f4 | cut -d '"' -f1)
	if [ $ph == "j-" ];then
		echo "0 -1 0 $READOUT" > acq_file.txt
	elif [ $ph == "j" ];then
		echo "0 1 0 $READOUT" > acq_file.txt
	elif [ $ph == "i" ];then
		echo "1 0 0 $READOUT" > acq_file.txt
	elif [ $ph == "i-" ];then
		echo "-1 0 0 $READOUT" > acq_file.txt
	fi
	for MES in `seq 2 $B0NUM`;do					# Create acq_file which is necessary for topup
		if [ $MES -eq $B0USE ];then
			ph1=$ph
		fi
		if [ $MES -gt $B0USE ];then
			ph=$(cat ${JSON_PA} | grep \"PhaseEncodingDirection\" | cut -d '"' -f4 | cut -d '"' -f1)    
		fi
		if [ $ph == "j-" ];then
			echo "0 -1 0 $READOUT" >> acq_file.txt
		elif [ $ph == "j" ];then
			echo "0 1 0 $READOUT" >> acq_file.txt
		elif [ $ph == "i" ];then
			echo "1 0 0 $READOUT" >> acq_file.txt
		elif [ $ph == "i-" ];then
			echo "-1 0 0 $READOUT" >> acq_file.txt
		fi
	done

	`echo $MERGECOMMAND`						# Create file containing only b0 images
	rm temporary*.nii.gz

	chmod 660 eddy_input*
	chmod 660 index.txt
	chmod 660 b0.nii.gz
	chmod 660 acq_file.txt
	if [ $ph1 == $ph ];then
		echo "Same phase encoding acquisition" > acq_note.txt
		chmod 660 acq_note.txt
	fi
	echo "${yellow}$(date +%x_%T): Preprocessing of diffusion data in $DATA folder is done.${normal}"
	
}
#-----------------------------------------------------------------------------------------------------------
#-----------------------------------------------------------------------------------------------------------
# Function which is called for topup and mean of data after topup
topup_function()
{
	DATA=$1
	echo "${yellow}$(date +%x_%T): Starting topup on data in $DATA folder!${normal}"
	cd $DATA
	topup --imain=b0.nii.gz --datain=acq_file.txt --out=topup --subsamp=1,1,1,1,1,1,1,1,1 --config=b02b0.cnf --iout=b0_topup --fout=field_topup > topup_stdout.txt # -v
	fslmaths b0_topup.nii.gz -Tmean b0_topup_mean.nii.gz # mean b0
	bet b0_topup_mean.nii.gz b0_topup_mean_brain -m -o -f 0.25 
	fslmaths b0_topup_mean_brain.nii.gz -thr 20 b0_topup_mean_brain.nii.gz
	fslmaths b0_topup_mean_brain_mask.nii.gz -mas b0_topup_mean_brain.nii.gz -fillh b0_topup_mean_brain_mask.nii.gz
	cluster -i b0_topup_mean_brain_mask.nii.gz -t 0.99 --minextent=100 -o b0_topup_mean_brain_cluster.nii.gz > cluster.log
	CLMAX=$(sed -n '2p' cluster.log | cut -f1)
	fslmaths b0_topup_mean_brain_cluster.nii.gz -thr $CLMAX -bin b0_topup_mean_brain_mask.nii.gz
	rm b0_topup_mean_brain_cluster.nii.gz
	echo "${yellow}$(date +%x_%T): topup on data in $DATA folder is done.${normal}"
	
}
#-----------------------------------------------------------------------------------------------------------
#-----------------------------------------------------------------------------------------------------------
# Function which is called for eddy (eddy uses either manually segmented mask of SC or whole binarized FOV)
eddy_function()
{
	DATA=$1
	echo "${yellow}$(date +%x_%T): Starting eddy on data in $DATA folder!${normal}"
	cd $DATA
	#EDDYCMD="eddy_openmp"
	EDDYCMD="eddy_cuda9.1"
	${EDDYCMD} --imain=eddy_input.nii.gz --mask=b0_topup_mean_brain_mask.nii.gz --index=index.txt --acqp=acq_file.txt --bvecs=eddy_input.bvec --bvals=eddy_input.bval --topup=topup --out=eddy --json=eddy_input_pa.json -v --data_is_shelled --repol --ol_type=both --fwhm=10,6,0,0,0,0 --mporder=6 --s2v_niter=6 --niter=6 > eddy_stdout.txt # --ol_ec=2 add if necessary regarding no outliers and linked correspondence https://www.jiscmail.ac.uk/cgi-bin/webadmin?A2=FSL;38fa964.1912
	echo "${yellow}$(date +%x_%T): eddy on data in $DATA folder is done.${normal}"
}
#-----------------------------------------------------------------------------------------------------------
#-----------------------------------------------------------------------------------------------------------
# Function which is called for estimation of DTI model using dtifit
dtifit_function()
{
	DATA=$1
	echo "${yellow}$(date +%x_%T): Starting estimation of DTI model using dtifit on data in $DATA folder.${normal}"
	cd $DATA
	#cp eddy_medfilt.nii.gz data.nii.gz
	if [ -f eddy.nii.gz ];then
	    cp eddy.nii.gz data.nii.gz
	    cp eddy_input.bval bvals
	    cp eddy.eddy_rotated_bvecs bvecs
	    cp b0_topup_mean_brain_mask.nii.gz nodif_brain_mask.nii.gz
	fi
	dtifit -k data.nii.gz -o dti -m nodif_brain_mask.nii.gz -r bvecs -b bvals -w	
	echo "${yellow}$(date +%x_%T): Estimation of DTI model using dtifit on data in $DATA folder is done.${normal}"	
}
#-----------------------------------------------------------------------------------------------------------
#-----------------------------------------------------------------------------------------------------------
# Function which is called for estimation of DTI model using dtifit
noddimatlab_function()
{
	DATA=$1
	
	echo "${yellow}$(date +%x_%T): Starting estimation of NODDI model using NODDI-MATLAB-Toolbox on data in $DATA folder.${normal}"
	
	if [ ! -d $DATA/NODDI ];then
		mkdir $DATA/NODDI
		chmod 770 $DATA/NODDI
	fi
	if [ ! -d $DATA/NODDI/matlab-toolbox ];then
		mkdir $DATA/NODDI/matlab-toolbox
		chmod 770 $DATA/NODDI/matlab-toolbox
	fi
	cd $DATA
	
	if [ ! -f NODDI/NODDI_DWI.nii.gz ];then
		cp data.nii.gz NODDI/NODDI_DWI.nii.gz
		cp bvals NODDI/NODDI_protocol.bval
		cp bvecs NODDI/NODDI_protocol.bvec
		cp nodif_brain_mask.nii.gz NODDI/roi_mask.nii.gz
	fi

	cd $DATA/NODDI
	gunzip NODDI_DWI.nii.gz
	gunzip roi_mask.nii.gz
	run_matlab "addpath('$BINDIR/matlab'),addpath(genpath('$NIFTILIBDIR')),addpath(genpath('$NODDIMATLABDIR')),bcp_noddi('$DATA/NODDI','roi_mask'),exit"
	gzip NODDI_DWI.nii
	gzip roi_mask.nii
	gzip matlab-toolbox/*.nii
	echo "${yellow}$(date +%x_%T): Estimation of NODDI model using NODDI-MATLAB-Toolbox on data in $DATA folder is done.${normal}"	
}
#-----------------------------------------------------------------------------------------------------------
#-----------------------------------------------------------------------------------------------------------
dt=$(date '+%Y/%m/%d %H:%M:%S');
echo "$dt $SUB: dMRI data processing started"
main
chmod -R g=u $RESULTFOLDER > /dev/null
chmod -R o-rwx $RESULTFOLDER > /dev/null
dt=$(date '+%Y/%m/%d %H:%M:%S');
echo "$dt $SUB: dMRI data processing done"
