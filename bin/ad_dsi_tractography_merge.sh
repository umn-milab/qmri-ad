#!/bin/bash

DATAFOLDER=$1

TRACKVOXELRATIO=$2

if [ $TRACKVOXELRATIO -eq 4 ];then
    DSIBASENAME=dsistudio
else
    DSIBASENAME=dsistudio-tract_voxel_ratio-$TRACKVOXELRATIO
fi

NIIFOLDER=$DATAFOLDER/bids
RESULTFOLDER=$DATAFOLDER/results
TABLEFOLDER=$DATAFOLDER/tables

cd $NIIFOLDER

for TRACT in Acoustic_Radiation_L Acoustic_Radiation_R Anterior_Commissure Arcuate_Fasciculus_L Arcuate_Fasciculus_R Cerebellum_L Cerebellum_R Cingulum_Frontal_Parahippocampal_L Cingulum_Frontal_Parahippocampal_R Cingulum_Frontal_Parietal_L Cingulum_Frontal_Parietal_R Cingulum_Parahippocampal_L Cingulum_Parahippocampal_R Cingulum_Parahippocampal_Parietal_L Cingulum_Parahippocampal_Parietal_R Cingulum_Parolfactory_L Cingulum_Parolfactory_R Corpus_Callosum_Body Corpus_Callosum_Forceps_Major Corpus_Callosum_Forceps_Minor Corpus_Callosum_Tapetum Corticobulbar_Tract_L Corticobulbar_Tract_R Corticopontine_Tract_Frontal_L Corticopontine_Tract_Frontal_R Corticopontine_Tract_Occipital_L Corticopontine_Tract_Occipital_R Corticopontine_Tract_Parietal_L Corticopontine_Tract_Parietal_R Corticospinal_Tract_L Corticospinal_Tract_R Corticostriatal_Tract_Anterior_L Corticostriatal_Tract_Anterior_R Corticostriatal_Tract_Posterior_L Corticostriatal_Tract_Posterior_R Corticostriatal_Tract_Superior_L Corticostriatal_Tract_Superior_R Dentatorubrothalamic_Tract_L Dentatorubrothalamic_Tract_R Extreme_Capsule_L Extreme_Capsule_R Fornix_L Fornix_R Frontal_Aslant_Tract_L Frontal_Aslant_Tract_R Inferior_Cerebellar_Peduncle_L Inferior_Cerebellar_Peduncle_R Inferior_Fronto_Occipital_Fasciculus_L Inferior_Fronto_Occipital_Fasciculus_R Inferior_Longitudinal_Fasciculus_L Inferior_Longitudinal_Fasciculus_R Medial_Lemniscus_L Medial_Lemniscus_R Middle_Cerebellar_Peduncle Middle_Longitudinal_Fasciculus_L Middle_Longitudinal_Fasciculus_R Optic_Radiation_L Optic_Radiation_R Parietal_Aslant_Tract_L Parietal_Aslant_Tract_R Reticular_Tract_L Reticular_Tract_R Superior_Cerebellar_Peduncle Superior_Longitudinal_Fasciculus1_L Superior_Longitudinal_Fasciculus1_R Superior_Longitudinal_Fasciculus2_L Superior_Longitudinal_Fasciculus2_R Superior_Longitudinal_Fasciculus3_L Superior_Longitudinal_Fasciculus3_R Thalamic_Radiation_Anterior_L Thalamic_Radiation_Anterior_R Thalamic_Radiation_Posterior_L Thalamic_Radiation_Posterior_R Thalamic_Radiation_Superior_L Thalamic_Radiation_Superior_R Uncinate_Fasciculus_L Uncinate_Fasciculus_R Vermis Vertical_Occipital_Fasciculus_L Vertical_Occipital_Fasciculus_R; do
    for BASENAME in dmri; do # dmri79-offline dmri79-nordic dmri-6shell dmri-6shell-offline dmri-6shell-nordic
        echo -e "SUBID\tnumber_of_tracts\tmean_length_mm\tspan_mm\tcurl\telongation\tdiameter_mm\tvolume_mm3\ttrunk_volume_mm3\tbranch_volume_mm3\ttotal_surface_area_mm2\ttotal_radius_of_end_regions_mm\ttotal_area_of_end_regions_mm2\tirregularity\tarea_of_end_region_1_mm2\tradius_of_end_region_1_mm\tirregularity_of_end_region_1\tarea_of_end_region_2_mm2\tradius_of_end_region_2_mm\tirregularity_of_end_region_2\tqa\tFA\tfsum\tAD\tMD\tRD\td\tkappa\tficvf\tfiso\todi\tf1dispersion\tf2dispersion\tf3dispersion\tpreprocessing\tdmri_ap_vols\tdmri_pa_vols" > $TABLEFOLDER/${BASENAME}_${DSIBASENAME}_${TRACT}.tsv
    done  
    for SUB in `ls -d sub-*/ses-*`; do
	    for PRCTL in dmri; do
		    for donordic in 0;do
			    if [ $donordic -eq 0 ] && [ $PRCTL == "6shell" ];then
				    folder="dmri-$PRCTL"
			    elif [ $donordic -eq 1 ] && [ $PRCTL == "6shell" ];then
				    folder="dmri-$PRCTL-nordic"
			    elif [ $donordic -eq 2 ] && [ $PRCTL == "6shell" ];then
				    folder="dmri-$PRCTL-offline"
			    elif [ $donordic -eq 0 ] && [ $PRCTL == "dmri" ];then
				    folder="$PRCTL"
			    elif [ $donordic -eq 1 ] && [ $PRCTL == "dmri" ];then
				    folder="$PRCTL-nordic"
			    elif [ $donordic -eq 2 ] && [ $PRCTL == "dmri" ];then
				    folder="$PRCTL-offline"
			    fi
			    TRACTFILE=$RESULTFOLDER/$folder/$SUB/$DSIBASENAME/${TRACT}/bedpostX.${TRACT}
				EDDYFILE=$RESULTFOLDER/$folder/$SUB/eddy.nii.gz
				DWIPAFILE=$NIIFOLDER/$SUB/dwi/sub-*_ses-*_acq-mb3_dir-PA_dwi.nii.gz
				DWIAPFILE=$NIIFOLDER/$SUB/dwi/sub-*_ses-*_acq-mb3_dir-AP_dwi.nii.gz
				if [ -f $EDDYFILE ];then
					PREPROC=topup+eddy
				else
					PREPROC=NaN
				fi
				if [ -f $DWIPAFILE ];then
					nvolspa=`${FSLDIR}/bin/fslval $DWIPAFILE dim4`
				else
					nvolspa=NaN
				fi
				if [ -f $DWIAPFILE ];then
					nvolsap=`${FSLDIR}/bin/fslval $DWIAPFILE dim4`
				else
					nvolsap=NaN
				fi
			    if [ -f $TRACTFILE.stat.txt ] && [ $SUB != "20181029-ST001-MNBCP439999-v04-2-20mo" ]; then
			        NTRACT=$(cat $TRACTFILE.stat.txt | grep "^number of tracts" | cut -d$'\t' -f2)
			        MLENGTH=$(cat $TRACTFILE.stat.txt | grep "^mean length(mm)" | cut -d$'\t' -f2)
			        SPAN=$(cat $TRACTFILE.stat.txt | grep "^span(mm)" | cut -d$'\t' -f2)
			        CURL=$(cat $TRACTFILE.stat.txt | grep "^curl" | cut -d$'\t' -f2)
			        ELONGATION=$(cat $TRACTFILE.stat.txt | grep "^elongation" | cut -d$'\t' -f2)
			        DIAMETER=$(cat $TRACTFILE.stat.txt | grep "^diameter(mm)" | cut -d$'\t' -f2)
			        VOLUME=$(cat $TRACTFILE.stat.txt | grep "^volume(mm^3)" | cut -d$'\t' -f2)
			        TRUNKVOLUME=$(cat $TRACTFILE.stat.txt | grep "^trunk volume(mm^3)" | cut -d$'\t' -f2)
			        BRANCHVOLUME=$(cat $TRACTFILE.stat.txt | grep "^branch volume(mm^3)" | cut -d$'\t' -f2)
			        SURFACE=$(cat $TRACTFILE.stat.txt | grep "^total surface area(mm^2)" | cut -d$'\t' -f2)
			        ENDRADIUS=$(cat $TRACTFILE.stat.txt | grep "^total radius of end regions(mm)" | cut -d$'\t' -f2)
			        ENDSURFACE=$(cat $TRACTFILE.stat.txt | grep "^total area of end regions(mm^2)" | cut -d$'\t' -f2)
			        IRREGULARITY=$(cat $TRACTFILE.stat.txt | grep "^irregularity" | head -n 1 | cut -d$'\t' -f2)
			        ENDSURFACE1=$(cat $TRACTFILE.stat.txt | grep "^area of end region 1(mm^2)" | cut -d$'\t' -f2)
			        ENDRADIUS1=$(cat $TRACTFILE.stat.txt | grep "^radius of end region 1(mm)" | cut -d$'\t' -f2)
			        ENDIRREGULARITY1=$(cat $TRACTFILE.stat.txt | grep "^irregularity of end region 1" | cut -d$'\t' -f2)
			        ENDSURFACE2=$(cat $TRACTFILE.stat.txt | grep "^area of end region 2(mm^2)" | cut -d$'\t' -f2)
			        ENDRADIUS2=$(cat $TRACTFILE.stat.txt | grep "^radius of end region 2(mm)" | cut -d$'\t' -f2)
			        ENDIRREGULARITY2=$(cat $TRACTFILE.stat.txt | grep "^irregularity of end region 2" | cut -d$'\t' -f2)
			        QA=$(cat $TRACTFILE.stat.txt | grep "^qa" | cut -d$'\t' -f2)
			        FA=$(cat $TRACTFILE.stat.txt | grep "^FA" | cut -d$'\t' -f2)
			        FSUM=$(cat $TRACTFILE.stat.txt | grep "^fsum" | cut -d$'\t' -f2)
			        AD=$(cat $TRACTFILE.stat.txt | grep "^AD" | cut -d$'\t' -f2)
			        MD=$(cat $TRACTFILE.stat.txt | grep "^MD" | cut -d$'\t' -f2)
			        RD=$(cat $TRACTFILE.stat.txt | grep "^RD" | cut -d$'\t' -f2)
			        D=$(cat $TRACTFILE.stat.txt | grep "^d" | tail -n 1 | cut -d$'\t' -f2)
			        KAPPA=$(cat $TRACTFILE.stat.txt | grep "^kappa" | cut -d$'\t' -f2)
			        FICVF=$(cat $TRACTFILE.stat.txt | grep "^ficvf" | cut -d$'\t' -f2)
			        FISO=$(cat $TRACTFILE.stat.txt | grep "^fiso" | cut -d$'\t' -f2)
			        ODI=$(cat $TRACTFILE.stat.txt | grep "^odi" | cut -d$'\t' -f2)
			        F1DISPERSION=$(cat $TRACTFILE.stat.txt | grep "^f1dispersion" | cut -d$'\t' -f2)
			        F2DISPERSION=$(cat $TRACTFILE.stat.txt | grep "^f2dispersion" | cut -d$'\t' -f2)
			        F3DISPERSION=$(cat $TRACTFILE.stat.txt | grep "^f3dispersion" | cut -d$'\t' -f2)
			        
			        echo -e "$SUB\t$NTRACT\t$MLENGTH\t$SPAN\t$CURL\t$ELONGATION\t$DIAMETER\t$VOLUME\t$TRUNKVOLUME\t$BRANCHVOLUME\t$SURFACE\t$ENDRADIUS\t$ENDSURFACE\t$IRREGULARITY\t$ENDSURFACE1\t$ENDRADIUS1\t$ENDIRREGULARITY1\t$ENDSURFACE2\t$ENDRADIUS2\t$ENDIRREGULARITY2\t$QA\t$FA\t$FSUM\t$AD\t$MD\t$RD\t$D\t$KAPPA\t$FICVF\t$FISO\t$ODI\t$F1DISPERSION\t$F2DISPERSION\t$F3DISPERSION\t$PREPROC\t$nvolsap\t$nvolspa" >> $TABLEFOLDER/${folder}_${DSIBASENAME}_${TRACT}.tsv
			    else
			        echo -e "$SUB\tNaN\tNaN\tNaN\tNaN\tNaN\tNaN\tNaN\tNaN\tNaN\tNaN\tNaN\tNaN\tNaN\tNaN\tNaN\tNaN\tNaN\tNaN\tNaN\tNaN\tNaN\tNaN\tNaN\tNaN\tNaN\tNaN\tNaN\tNaN\tNaN\tNaN\tNaN\tNaN\tNaN\t$PREPROC\t$nvolsap\t$nvolspa" >> $TABLEFOLDER/${folder}_${DSIBASENAME}_${TRACT}.tsv
			    fi
		    done
	    done
    done
	echo "Merge of tractography results is done for $TRACT and track2voxel ratio $TRACKVOXELRATIO."
done
