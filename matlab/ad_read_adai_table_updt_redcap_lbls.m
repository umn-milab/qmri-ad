clear all;
close all;
clc;

csv_path = '/home/range1-raid1/labounek/data-on-porto/ADAI/RedCap';
% csv_filename = 'BreakthroughsInADBlo_DATA_2024-10-08_1057.csv';
% csv_filename = 'BreakthroughsInADBlo_DATA_2025-01-21_1520.csv';
csv_filename = 'BreakthroughsInADBlo_DATA_LABELS_2025-04-03_1829.csv';


tbl = readtable(fullfile(csv_path,csv_filename),'PreserveVariableNames',1);

pidn = cell2mat(table2cell(tbl(:,'PIDN')));
pidn_uni = unique(pidn);

rpt = table2cell(tbl(:,'Repeat Instrument'));
rpt_inst = cell2mat(table2cell(tbl(:,'Repeat Instance')));


pidn2 = cell2mat(table2cell(tbl(strcmp(rpt,'participant_demographics'),'PIDN')));
sex = cell2mat(table2cell(tbl(strcmp(rpt,'participant_demographics'),'Sex')));
homeless = cell2mat(table2cell(tbl(strcmp(rpt,'participant_demographics'),'homeless')));
tribe = cell2mat(table2cell(tbl(strcmp(rpt,'participant_demographics'),'tribe')));
hp_memprob = cell2mat(table2cell(tbl(strcmp(rpt,'participant_demographics'),'hp_memprob')));
hp_mem_comp = cell2mat(table2cell(tbl(strcmp(rpt,'participant_demographics'),'hp_mem_comp')));

mmse_date = table2cell(tbl(strcmp(rpt,'mmse') & rpt_inst==1,'mmse_date'));
mmse_pind = cell2mat(table2cell(tbl(strcmp(rpt,'mmse') & rpt_inst==1,'PIDN')));
mmse_totalscore_val = cell2mat(table2cell(tbl(strcmp(rpt,'mmse') & rpt_inst==1,'mmse_totalscore')));

data_adai_cell = cell(size(sex,1),1);
mmse_totalscore = NaN*ones(size(sex));
for ind = 1:size(mmse_pind,1)
    pos = find(pidn2==mmse_pind(ind,1));
    for x = 1:size(pos,1)
        data_adai_cell{ pos(x) , 1 } = mmse_date{ind,1};
        
        mmse_totalscore( pos(x) , 1 ) = mmse_totalscore_val(ind,1);
    end
end

hp_tidx1 = find(string(tbl.Properties.VariableNames) == "hp_conditions___1");
hp_tidx2 = find(string(tbl.Properties.VariableNames) == "hp_conditions___10");

hp_conditions_val = cell2mat(table2cell(tbl(strcmp(rpt,'hp_for_second_visit') & rpt_inst==1,hp_tidx1:hp_tidx2)));
hp_conditions_orignames = tbl.Properties.VariableNames(hp_tidx1:hp_tidx2);
hp_conditions_names = {'Hypertension' 'Hyperlipidemia' 'Kidney_disease' 'Heart_problems' ...
    'Type_I_diabetes_mellitus' 'Type_II_diabetes_mellitus' 'Any_cancer_history' 'Stroke_history' ...
    'Other_miscellaneous_conditions/diagnoses' 'None'};

hp_date = table2cell(tbl(strcmp(rpt,'hp_for_second_visit') & rpt_inst==1,'hp_date'));
hp_pind = cell2mat(table2cell(tbl(strcmp(rpt,'hp_for_second_visit') & rpt_inst==1,'PIDN')));
height_val = cell2mat(table2cell(tbl(strcmp(rpt,'hp_for_second_visit') & rpt_inst==1,'height')));
weight_val = cell2mat(table2cell(tbl(strcmp(rpt,'hp_for_second_visit') & rpt_inst==1,'weight')));
dom_hand_val = cell2mat(table2cell(tbl(strcmp(rpt,'hp_for_second_visit') & rpt_inst==1,'dom_hand')));
hp_adls_val = cell2mat(table2cell(tbl(strcmp(rpt,'hp_for_second_visit') & rpt_inst==1,'hp_adls')));
hp_adls_mem_val = cell2mat(table2cell(tbl(strcmp(rpt,'hp_for_second_visit') & rpt_inst==1,'hp_adls_mem')));
hp_famhist_val = cell2mat(table2cell(tbl(strcmp(rpt,'hp_for_second_visit') & rpt_inst==1,'hp_famhist')));
hp_moodchange_val = cell2mat(table2cell(tbl(strcmp(rpt,'hp_for_second_visit') & rpt_inst==1,'hp_moodchange')));
hp_moodmed_val = cell2mat(table2cell(tbl(strcmp(rpt,'hp_for_second_visit') & rpt_inst==1,'hp_moodmed')));
hp_halluc_val = cell2mat(table2cell(tbl(strcmp(rpt,'hp_for_second_visit') & rpt_inst==1,'hp_halluc')));
hp_sleephours_val = cell2mat(table2cell(tbl(strcmp(rpt,'hp_for_second_visit') & rpt_inst==1,'hp_sleephours')));
hp_sleeptrouble_val = cell2mat(table2cell(tbl(strcmp(rpt,'hp_for_second_visit') & rpt_inst==1,'hp_sleeptrouble')));
hp_sleepmed_val = cell2mat(table2cell(tbl(strcmp(rpt,'hp_for_second_visit') & rpt_inst==1,'hp_sleepmed')));
hp_snore_val = cell2mat(table2cell(tbl(strcmp(rpt,'hp_for_second_visit') & rpt_inst==1,'hp_snore')));
hp_snore_awake_val = cell2mat(table2cell(tbl(strcmp(rpt,'hp_for_second_visit') & rpt_inst==1,'hp_snore_awake')));
hp_snore_slpapnea_val = cell2mat(table2cell(tbl(strcmp(rpt,'hp_for_second_visit') & rpt_inst==1,'hp_snore_slpapnea')));
hp_schoolyears_val = cell2mat(table2cell(tbl(strcmp(rpt,'hp_for_second_visit') & rpt_inst==1,'hp_schoolyears')));
hp_learndisability_val = cell2mat(table2cell(tbl(strcmp(rpt,'hp_for_second_visit') & rpt_inst==1,'hp_learndisability')));
hp_alcohol_val = cell2mat(table2cell(tbl(strcmp(rpt,'hp_for_second_visit') & rpt_inst==1,'hp_alcohol')));
hp_tobacco_val = cell2mat(table2cell(tbl(strcmp(rpt,'hp_for_second_visit') & rpt_inst==1,'hp_tobacco')));
hp_marijuana_val = cell2mat(table2cell(tbl(strcmp(rpt,'hp_for_second_visit') & rpt_inst==1,'hp_marijuana')));
hp_recdrug_val = cell2mat(table2cell(tbl(strcmp(rpt,'hp_for_second_visit') & rpt_inst==1,'hp_recdrug')));
hp_exercise_val = cell2mat(table2cell(tbl(strcmp(rpt,'hp_for_second_visit') & rpt_inst==1,'hp_exercise')));
hp_falls_val = cell2mat(table2cell(tbl(strcmp(rpt,'hp_for_second_visit') & rpt_inst==1,'hp_falls')));
hp_surgeries_val = cell2mat(table2cell(tbl(strcmp(rpt,'hp_for_second_visit') & rpt_inst==1,'hp_surgeries')));
hp_hospital_val = cell2mat(table2cell(tbl(strcmp(rpt,'hp_for_second_visit') & rpt_inst==1,'hp_hospital')));
hp_headtrauma_val = cell2mat(table2cell(tbl(strcmp(rpt,'hp_for_second_visit') & rpt_inst==1,'hp_headtrauma')));
hp_impairment_val = cell2mat(table2cell(tbl(strcmp(rpt,'hp_for_second_visit') & rpt_inst==1,'hp_impairment')));


hp_conditions_val2 = cell2mat(table2cell(tbl(strcmp(rpt,'hp_for_second_visit') & rpt_inst==2,hp_tidx1:hp_tidx2)));

hp_date2 = table2cell(tbl(strcmp(rpt,'hp_for_second_visit') & rpt_inst==2,'hp_date'));
hp_pind2 = cell2mat(table2cell(tbl(strcmp(rpt,'hp_for_second_visit') & rpt_inst==2,'PIDN')));
height_val2 = cell2mat(table2cell(tbl(strcmp(rpt,'hp_for_second_visit') & rpt_inst==2,'height')));
weight_val2 = cell2mat(table2cell(tbl(strcmp(rpt,'hp_for_second_visit') & rpt_inst==2,'weight')));
dom_hand_val2 = cell2mat(table2cell(tbl(strcmp(rpt,'hp_for_second_visit') & rpt_inst==2,'dom_hand')));
hp_adls_val2 = cell2mat(table2cell(tbl(strcmp(rpt,'hp_for_second_visit') & rpt_inst==2,'hp_adls')));
hp_adls_mem_val2 = cell2mat(table2cell(tbl(strcmp(rpt,'hp_for_second_visit') & rpt_inst==2,'hp_adls_mem')));
hp_famhist_val2 = cell2mat(table2cell(tbl(strcmp(rpt,'hp_for_second_visit') & rpt_inst==2,'hp_famhist')));
hp_moodchange_val2 = cell2mat(table2cell(tbl(strcmp(rpt,'hp_for_second_visit') & rpt_inst==2,'hp_moodchange')));
hp_moodmed_val2 = cell2mat(table2cell(tbl(strcmp(rpt,'hp_for_second_visit') & rpt_inst==2,'hp_moodmed')));
hp_halluc_val2 = cell2mat(table2cell(tbl(strcmp(rpt,'hp_for_second_visit') & rpt_inst==2,'hp_halluc')));
hp_sleephours_val2 = cell2mat(table2cell(tbl(strcmp(rpt,'hp_for_second_visit') & rpt_inst==2,'hp_sleephours')));
hp_sleeptrouble_val2 = cell2mat(table2cell(tbl(strcmp(rpt,'hp_for_second_visit') & rpt_inst==2,'hp_sleeptrouble')));
hp_sleepmed_val2 = cell2mat(table2cell(tbl(strcmp(rpt,'hp_for_second_visit') & rpt_inst==2,'hp_sleepmed')));
hp_snore_val2 = cell2mat(table2cell(tbl(strcmp(rpt,'hp_for_second_visit') & rpt_inst==2,'hp_snore')));
hp_snore_awake_val2 = cell2mat(table2cell(tbl(strcmp(rpt,'hp_for_second_visit') & rpt_inst==2,'hp_snore_awake')));
hp_snore_slpapnea_val2 = cell2mat(table2cell(tbl(strcmp(rpt,'hp_for_second_visit') & rpt_inst==2,'hp_snore_slpapnea')));
hp_schoolyears_val2 = cell2mat(table2cell(tbl(strcmp(rpt,'hp_for_second_visit') & rpt_inst==2,'hp_schoolyears')));
hp_learndisability_val2 = cell2mat(table2cell(tbl(strcmp(rpt,'hp_for_second_visit') & rpt_inst==2,'hp_learndisability')));
hp_alcohol_val2 = cell2mat(table2cell(tbl(strcmp(rpt,'hp_for_second_visit') & rpt_inst==2,'hp_alcohol')));
hp_tobacco_val2 = cell2mat(table2cell(tbl(strcmp(rpt,'hp_for_second_visit') & rpt_inst==2,'hp_tobacco')));
hp_marijuana_val2 = cell2mat(table2cell(tbl(strcmp(rpt,'hp_for_second_visit') & rpt_inst==2,'hp_marijuana')));
hp_recdrug_val2 = cell2mat(table2cell(tbl(strcmp(rpt,'hp_for_second_visit') & rpt_inst==2,'hp_recdrug')));
hp_exercise_val2 = cell2mat(table2cell(tbl(strcmp(rpt,'hp_for_second_visit') & rpt_inst==2,'hp_exercise')));
hp_falls_val2 = cell2mat(table2cell(tbl(strcmp(rpt,'hp_for_second_visit') & rpt_inst==2,'hp_falls')));
hp_surgeries_val2 = cell2mat(table2cell(tbl(strcmp(rpt,'hp_for_second_visit') & rpt_inst==2,'hp_surgeries')));
hp_hospital_val2 = cell2mat(table2cell(tbl(strcmp(rpt,'hp_for_second_visit') & rpt_inst==2,'hp_hospital')));
hp_headtrauma_val2 = cell2mat(table2cell(tbl(strcmp(rpt,'hp_for_second_visit') & rpt_inst==2,'hp_headtrauma')));
hp_impairment_val2 = cell2mat(table2cell(tbl(strcmp(rpt,'hp_for_second_visit') & rpt_inst==2,'hp_impairment')));

height = NaN*ones(size(sex));
weight = NaN*ones(size(sex));
dom_hand = NaN*ones(size(sex));
hp_adls = NaN*ones(size(sex));
hp_adls_mem = NaN*ones(size(sex));
hp_famhist = NaN*ones(size(sex));
hp_moodchange = NaN*ones(size(sex));
hp_moodmed = NaN*ones(size(sex));
hp_halluc = NaN*ones(size(sex));
hp_sleephours = NaN*ones(size(sex));
hp_sleeptrouble = NaN*ones(size(sex));
hp_sleepmed = NaN*ones(size(sex));
hp_snore = NaN*ones(size(sex));
hp_snore_awake = NaN*ones(size(sex));
hp_snore_slpapnea = NaN*ones(size(sex));
hp_schoolyears = NaN*ones(size(sex));
hp_learndisability = NaN*ones(size(sex));
hp_alcohol = NaN*ones(size(sex));
hp_tobacco = NaN*ones(size(sex));
hp_marijuana = NaN*ones(size(sex));
hp_recdrug = NaN*ones(size(sex));
hp_exercise = NaN*ones(size(sex));
hp_falls = NaN*ones(size(sex));
hp_surgeries = NaN*ones(size(sex));
hp_hospital = NaN*ones(size(sex));
hp_headtrauma = NaN*ones(size(sex));
hp_impairment = NaN*ones(size(sex));
hp_conditions = NaN*ones(size(sex,1),size(hp_conditions_orignames,2));
for ind = 1:size(hp_pind,1)
    pos = find(pidn2==hp_pind(ind,1));
    for x = 1:size(pos,1)
        data_adai_cell{ pos(x) , 2 } = hp_date{ind,1};
        
        height( pos(x) , 1 ) = height_val(ind,1);
        weight( pos(x) , 1 ) = weight_val(ind,1);
        dom_hand( pos(x) , 1 ) = dom_hand_val(ind,1);
        hp_adls( pos(x) , 1 ) = hp_adls_val(ind,1);
        hp_adls_mem( pos(x) , 1 ) = hp_adls_mem_val(ind,1);
        hp_famhist( pos(x) , 1 ) = hp_famhist_val(ind,1);
        hp_moodchange( pos(x) , 1 ) = hp_moodchange_val(ind,1);
        hp_moodmed( pos(x) , 1 ) = hp_moodmed_val(ind,1);
        hp_halluc( pos(x) , 1 ) = hp_halluc_val(ind,1);
        hp_sleephours( pos(x) , 1 ) = hp_sleephours_val(ind,1);
        hp_sleeptrouble( pos(x) , 1 ) = hp_sleeptrouble_val(ind,1);
        hp_sleepmed( pos(x) , 1 ) = hp_sleepmed_val(ind,1);
        hp_snore( pos(x) , 1 ) = hp_snore_val(ind,1);
        hp_snore_awake( pos(x) , 1 ) = hp_snore_awake_val(ind,1);
        hp_snore_slpapnea( pos(x) , 1 ) = hp_snore_slpapnea_val(ind,1);
        hp_schoolyears( pos(x) , 1 ) = hp_schoolyears_val(ind,1);
        hp_learndisability( pos(x) , 1 ) = hp_learndisability_val(ind,1);
        hp_alcohol( pos(x) , 1 ) = hp_alcohol_val(ind,1);
        hp_tobacco( pos(x) , 1 ) = hp_tobacco_val(ind,1);
        hp_marijuana( pos(x) , 1 ) = hp_marijuana_val(ind,1);
        hp_recdrug( pos(x) , 1 ) = hp_recdrug_val(ind,1);
        hp_exercise( pos(x) , 1 ) = hp_exercise_val(ind,1);
        hp_falls( pos(x) , 1 ) = hp_falls_val(ind,1);
        hp_surgeries( pos(x) , 1 ) = hp_surgeries_val(ind,1);
        hp_hospital( pos(x) , 1 ) = hp_hospital_val(ind,1);
        hp_headtrauma( pos(x) , 1 ) = hp_headtrauma_val(ind,1);
        hp_impairment( pos(x) , 1 ) = hp_impairment_val(ind,1);
        hp_conditions( pos(x) , : ) = hp_conditions_val(ind,:);
    end
end

for ind = 1:size(hp_pind2,1)
    if hp_pind2(ind,1) == 45
        pos = find(pidn2==hp_pind2(ind,1));
        for x = 1:size(pos,1)
            data_adai_cell{ pos(x) , 2 } = hp_date{ind,1};

            height( pos(x) , 1 ) = height_val2(ind,1);
            weight( pos(x) , 1 ) = weight_val2(ind,1);
            dom_hand( pos(x) , 1 ) = dom_hand_val2(ind,1);
            hp_adls( pos(x) , 1 ) = hp_adls_val2(ind,1);
            hp_adls_mem( pos(x) , 1 ) = hp_adls_mem_val2(ind,1);
            hp_famhist( pos(x) , 1 ) = hp_famhist_val2(ind,1);
            hp_moodchange( pos(x) , 1 ) = hp_moodchange_val2(ind,1);
            hp_moodmed( pos(x) , 1 ) = hp_moodmed_val2(ind,1);
            hp_halluc( pos(x) , 1 ) = hp_halluc_val2(ind,1);
            hp_sleephours( pos(x) , 1 ) = hp_sleephours_val2(ind,1);
            hp_sleeptrouble( pos(x) , 1 ) = hp_sleeptrouble_val2(ind,1);
            hp_sleepmed( pos(x) , 1 ) = hp_sleepmed_val2(ind,1);
            hp_snore( pos(x) , 1 ) = hp_snore_val2(ind,1);
            hp_snore_awake( pos(x) , 1 ) = hp_snore_awake_val2(ind,1);
            hp_snore_slpapnea( pos(x) , 1 ) = hp_snore_slpapnea_val2(ind,1);
            hp_schoolyears( pos(x) , 1 ) = hp_schoolyears_val2(ind,1);
            hp_learndisability( pos(x) , 1 ) = hp_learndisability_val2(ind,1);
            hp_alcohol( pos(x) , 1 ) = hp_alcohol_val2(ind,1);
            hp_tobacco( pos(x) , 1 ) = hp_tobacco_val2(ind,1);
            hp_marijuana( pos(x) , 1 ) = hp_marijuana_val2(ind,1);
            hp_recdrug( pos(x) , 1 ) = hp_recdrug_val2(ind,1);
            hp_exercise( pos(x) , 1 ) = hp_exercise_val2(ind,1);
            hp_falls( pos(x) , 1 ) = hp_falls_val2(ind,1);
            hp_surgeries( pos(x) , 1 ) = hp_surgeries_val2(ind,1);
            hp_hospital( pos(x) , 1 ) = hp_hospital_val2(ind,1);
            hp_headtrauma( pos(x) , 1 ) = hp_headtrauma_val2(ind,1);
            hp_impairment( pos(x) , 1 ) = hp_impairment_val2(ind,1);
            hp_conditions( pos(x) , : ) = hp_conditions_val2(ind,:);
        end
    end
end


tr_tidx1 = find(string(tbl.Properties.VariableNames) == "tr_vb12");
tr_tidx2 = find(string(tbl.Properties.VariableNames) == "tr_ptau181");

tr_pind = cell2mat(table2cell(tbl(strcmp(rpt,'test_results') & rpt_inst==1,'PIDN')));

tr_val = cell2mat(table2cell(tbl(strcmp(rpt,'test_results') & rpt_inst==1,tr_tidx1:tr_tidx2)));
tr_data_names = tbl.Properties.VariableNames(tr_tidx1:tr_tidx2);

tr_data = NaN*ones(size(sex,1),size(tr_data_names,2));
for ind = 1:size(tr_pind,1)
    pos = find(pidn2==tr_pind(ind,1));
    for x = 1:size(pos,1)        
        tr_data( pos(x) , : ) = tr_val(ind,:);
    end
end

data_adai = [ pidn2 sex height weight dom_hand homeless tribe hp_memprob hp_mem_comp mmse_totalscore ...
    hp_adls hp_adls_mem hp_famhist hp_moodchange hp_moodmed hp_halluc ...
    hp_sleephours hp_sleeptrouble hp_sleepmed ...
    hp_snore hp_snore_awake hp_snore_slpapnea hp_schoolyears hp_learndisability ...
    hp_alcohol hp_tobacco hp_marijuana hp_recdrug hp_exercise hp_falls hp_surgeries hp_hospital ...
    hp_headtrauma hp_impairment hp_conditions ...
    tr_data ...
    ];