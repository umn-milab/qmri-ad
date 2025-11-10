%% Useful commands:
% sub(squeeze(tract_data(strcmp(tract_data_name_dsi,'branch_volume_mm3'),2,1,:))>4000,1)
% area_end_regio = squeeze(tract_data(strcmp(tract_data_name_dsi,'total_area_of_end_regions_mm2'),strcmp(tract_tractorder,'cst'),:,:))';
%% Initiate
clear all;
clc;
close all;
data_folder='/home/range1-raid1/labounek/data-on-porto';
extract_data_filename='extract_data_20250422.mat';
project_folder=fullfile(data_folder,'ADAI');
table_folder=fullfile(project_folder,'tables');

project_folder2=fullfile(data_folder,'ADNI','ADNI_ADAI_match');
table_folder2=fullfile(project_folder2,'tables');

jhu_roi = 'reconstruction_specific';
save_path = fullfile(project_folder,'pictures','ad_paper_export_20251107');
% jhu_roi = 'same'; % Use NORDIC JHU mask for JHU-atlas based dMRI value extraction
% save_folder = fullfile(project_folder,'pictures','bcp_paper_export_same_jhu_roi');
extract_data_file = fullfile(project_folder,'results',extract_data_filename);
extract_data_file_meanstd = [extract_data_file(1:end-4) '_meanstd.mat'];

extract_data = 0;
estimate_stats = 1;

if estimate_stats ~= 1
    load(extract_data_file_meanstd)
end
if extract_data ~= 1
        if estimate_stats == 0
            modst = 1;
        else
            modst = 0;
        end
        load(extract_data_file)
        extract_data = 0;
        save_path = fullfile(project_folder,'pictures','ad_paper_export_20251107');
        if modst == 1
            estimate_stats = 0;
        end
end

export_images = 1;
pthr=0.05/7; % 7 paired t-tests per boxplot
tract_voxel_ratio=16; % DSI Studio --atk input parameter
fntsz=14;
lnwdth=2;
clr_grey = [1 1 1]*0.4;
voxel_edge = 1.5;% mm i.e. voxel size edge
FAx_vec = 0:0.01:1;
% Set figure sizes
fig_size_age_dependence = [50 50 1800 1280];
fig_scatterplot_size=[50 50 1600 1200];

addpath('/home/range1-raid1/labounek/toolbox/matlab/spm12');
addpath('/home/range1-raid1/labounek/toolbox/matlab/path_functions');

%% Extract data
if extract_data == 1      
    %% Read subject and session data
    if tract_voxel_ratio == 4
            dsi_basename = 'dsistudio';
    else
            dsi_basename = ['dsistudio-tract_voxel_ratio-' num2str(tract_voxel_ratio)];
    end
    t_adai = tdfread(fullfile(table_folder,['dmri_' dsi_basename '_Cingulum_Frontal_Parahippocampal_L.tsv']));
    t_adni = tdfread(fullfile(table_folder2,['dmri_' dsi_basename '_Cingulum_Frontal_Parahippocampal_L.tsv']));
    
    adai = tdfread(fullfile(project_folder2,'ADAI-ADAI.tsv'));
    adni = tdfread(fullfile(project_folder2,'ADAI-ADNI_matched.tsv'));
    
    adai_subsess = cellstr(t_adai.SUBID);
    adni_subsess = cellstr(t_adni.SUBID);
    
    adai_preprocessing = cellstr(t_adai.preprocessing);
    adni_preprocessing = cellstr(t_adni.preprocessing);
    
    adni_ptid = cellstr(adni.PTID);
    adni_viscode = cellstr(adni.VISCODE);
    
    adai_dmriAPvols = t_adai.dmri_ap_vols;
    adni_dmriAPvols = t_adni.dmri_ap_vols;
    
    adai_dmriPAvols = t_adai.dmri_pa_vols;
    adni_dmriPAvols = t_adni.dmri_pa_vols;
    
    adai_sex = cell(size(adai_subsess));
    adai_age = NaN*ones(size(adai_subsess));
    adai_height = NaN*ones(size(adai_subsess));
    adai_weight = NaN*ones(size(adai_subsess));
    adai_bmi = NaN*ones(size(adai_subsess));
    adai_education = NaN*ones(size(adai_subsess));
    adai_hypertension = NaN*ones(size(adai_subsess));
    adai_apoe4 = NaN*ones(size(adai_subsess));
    adai_apoe3 = NaN*ones(size(adai_subsess));
    adai_apoe2 = NaN*ones(size(adai_subsess));
    adai_mmse = NaN*ones(size(adai_subsess));
    a_subsess = cellstr(strcat(adai.SUB,'/',adai.SESS));
    pos_dmri = zeros(size(a_subsess));
    for ind = 1:size(adai_subsess,1)
        pos = strcmp(a_subsess,adai_subsess{ind,1});
        adai_sex{ind,1} =  adai.Sex(pos,1);
        adai_age(ind,1) =  adai.Age0x5By0x5D(pos,1);
        adai_height(ind,1) = adai.Height0x5Bcm0x5D(pos,1);
        adai_weight(ind,1) = adai.Weight0x5Bkg0x5D(pos,1);
%         adai_height(ind,1) = 100*convlength(adai.height(pos,1),'in','m');
        adai_bmi(ind,1) =  adai_weight(ind,1) ./ (adai_height(ind,1)/100)^2;
        adai_education(ind,1) = adai.hp_schoolyears(pos,1);
        adai_hypertension(ind,1) = adai.Hypertension(pos,1);
        adai_apoe4(ind,1) = adai.tr_apoee4(pos,1);
        adai_apoe3(ind,1) = adai.tr_apoee3(pos,1);
        adai_apoe2(ind,1) = adai.tr_apoee2(pos,1);
        adai_mmse(ind,1) = adai.mmse_totalscore(pos,1);
        
        pos_dmri = pos_dmri + pos;
    end
    
    adni_sex = cell(size(adni_subsess));
    adni_age = NaN*ones(size(adni_subsess));
    adni_height = NaN*ones(size(adni_subsess));
    adni_weight = NaN*ones(size(adni_subsess));
    adni_bmi = NaN*ones(size(adni_subsess));
    adni_education = NaN*ones(size(adni_subsess));
    adni_hypertension = NaN*ones(size(adni_subsess));
    adni_apoe4 = NaN*ones(size(adni_subsess));
    adni_apoe3 = NaN*ones(size(adni_subsess));
    adni_apoe2 = NaN*ones(size(adni_subsess));
    adni_mmse = NaN*ones(size(adni_subsess));
    b_subsess = cellstr(strcat('sub-',adni.Subject_ID,'/ses-',adni.VISCODE));
    b_subsess = regexprep(b_subsess,'[_]','');
    for ind = 1:size(adni_subsess,1)
        pos = strcmp(b_subsess,adni_subsess{ind,1});
        adni_sex{ind,1} =  adni.Sex(pos,1);
        adni_age(ind,1) =  adni.Age(pos,1);
        adni_weight(ind,1) =  adni.Weight(pos,1);
        adni_education(ind,1) =  adni.PTEDUCAT(pos,1);
        adni_hypertension(ind,1) =  adni.HMHYPERT(pos,1);
        adni_apoe4(ind,1) =  adni.APOE4(pos,1);
        adni_apoe3(ind,1) =  adni.APOE3COUNT(pos,1);
        adni_apoe2(ind,1) =  adni.APOE2COUNT(pos,1);
        adni_mmse(ind,1) =  adni.MMSE(pos,1);
    end
    
    subsess = [adai_subsess; adni_subsess];
    race = [ ones(size(adai_subsess,1),1); zeros(size(adni_subsess,1),1) ];
    sex = [adai_sex; adni_sex];
    age = [adai_age; adni_age];
    weight = [adai_weight; adni_weight];
    education = [adai_education; adni_education];
    hypertension = [adai_hypertension; adni_hypertension];
    apoe4 = [adai_apoe4; adni_apoe4];
    apoe3 = [adai_apoe3; adni_apoe3];
    apoe2 = [adai_apoe2; adni_apoe2];
    mmse = [adai_mmse; adni_mmse];
    
    preprocessing = [adai_preprocessing; adni_preprocessing];
    dmriAPvols = [adai_dmriAPvols; adni_dmriAPvols];
    dmriPAvols = [adai_dmriPAvols; adni_dmriPAvols];
    
    selection = ones(size(age));
    selection(apoe4==2 | isnan(apoe4)) = 0;
    selection(mmse<23) = 0;
    
    adai_selection = ones(size(adai_age));
    adai_selection(adai_apoe4==2 | isnan(adai_apoe4)) = 0;
    adai_selection(adai_mmse<23) = 0;
    
    adni_selection = ones(size(adni_age));
    adni_selection(adni_apoe4==2 | isnan(adni_apoe4)) = 0;
    adni_selection(adni_mmse<23) = 0;
    
    pos_nodmri = ones(size(pos_dmri)) - pos_dmri;
    adai_nodmri_mmse = adai.mmse_totalscore(pos_nodmri & ~isnan(adai.tr_apoee4) & adai.tr_apoee4~=2 );
    adai_nodmri_apoe4 = adai.tr_apoee4(pos_nodmri & ~isnan(adai.tr_apoee4) & adai.tr_apoee4~=2);
    
    %% Filter selected data only
%     subsess = subsess(selection~=0);
    sub = extractBefore(subsess,'/');
    sess = extractAfter(subsess,'/');
    race = race(selection~=0);
    sex = sex(selection~=0);
    age = age(selection~=0);
    weight = weight(selection~=0);
    education = education(selection~=0);
    hypertension = hypertension(selection~=0);
    apoe4 = apoe4(selection~=0);
    apoe3 = apoe3(selection~=0);
    apoe2 = apoe2(selection~=0);
    mmse = mmse(selection~=0);
    preprocessing = preprocessing(selection~=0);
    dmriAPvols = dmriAPvols(selection~=0);
    dmriPAvols = dmriPAvols(selection~=0);
    subsess = subsess(selection~=0);
    
%     selection = selection(selection~=0);
    selection2 = selection(selection~=0);
    
    apoe4_bin = apoe4;
    apoe4_bin(apoe4>1) = NaN;
    female = strcmp(sex,'F');
    race_cat = cell(size(race));
    race_cat(race==1,1) = {'NatAm'};
    race_cat(race==0,1) = {'White'};
    %% MMSE APOE4 stats
    pW_mmse = ranksum (mmse(apoe4_bin==0),mmse(apoe4_bin==1));
    
    apoe4_carrier_female(1,1) = sum(female(apoe4_bin==1));
    apoe4_carrier_female(1,2) = sum(female(apoe4_bin==1)) / sum(apoe4_bin==1);
    apoe4_noncarrier_female(1,1) = sum(female(apoe4_bin==0));
    apoe4_noncarrier_female(1,2) = sum(female(apoe4_bin==0)) / sum(apoe4_bin==0);
    
    apoe4_carrier_age = [ mean(age(apoe4_bin==1),'omitnan') std(age(apoe4_bin==1),'omitnan') ];
    apoe4_noncarrier_age = [ mean(age(apoe4_bin==0),'omitnan') std(age(apoe4_bin==0),'omitnan') ];
    [~, pT_apoe4_age] = ttest2(age(apoe4_bin==0),age(apoe4_bin==1));
    
    apoe4_carrier_weight = [ mean(weight(apoe4_bin==1),'omitnan') std(weight(apoe4_bin==1),'omitnan') ];
    apoe4_noncarrier_weight = [ mean(weight(apoe4_bin==0),'omitnan') std(weight(apoe4_bin==0),'omitnan') ];
    [~, pT_apoe4_weight] = ttest2(weight(apoe4_bin==0),weight(apoe4_bin==1));
    
    apoe4_carrier_education = [ mean(education(apoe4_bin==1),'omitnan') std(education(apoe4_bin==1),'omitnan') ];
    apoe4_noncarrier_education = [ mean(education(apoe4_bin==0),'omitnan') std(education(apoe4_bin==0),'omitnan') ];
    [~, pT_apoe4_education] = ttest2(education(apoe4_bin==0),education(apoe4_bin==1));
    
    apoe4_carrier_mmse = [ mean(mmse(apoe4_bin==1),'omitnan') std(mmse(apoe4_bin==1),'omitnan') ];
    apoe4_noncarrier_mmse = [ mean(mmse(apoe4_bin==0),'omitnan') std(mmse(apoe4_bin==0),'omitnan') ];
    [~, pT_apoe4_mmse] = ttest2(mmse(apoe4_bin==0),mmse(apoe4_bin==1));
    pW_apoe4_mmse = ranksum(mmse(apoe4_bin==0),mmse(apoe4_bin==1));
    
    apoe4_carrier_hypertension(1,1) = sum(hypertension==1 & apoe4_bin==1);
    apoe4_carrier_hypertension(1,2) = sum(hypertension==1 & apoe4_bin==1) / sum(apoe4_bin==1);
    apoe4_noncarrier_hypertension(1,1) = sum(hypertension==1 & apoe4_bin==0);
    apoe4_noncarrier_hypertension(1,2) = sum(hypertension==1 & apoe4_bin==0) / sum(apoe4_bin==0);
    
    apoe4_carrier_nohypertension(1,1) = sum(hypertension==0 & apoe4_bin==1);
    apoe4_carrier_nohypertension(1,2) = sum(hypertension==0 & apoe4_bin==1) / sum(apoe4_bin==1);
    apoe4_noncarrier_nohypertension(1,1) = sum(hypertension==0 & apoe4_bin==0);
    apoe4_noncarrier_nohypertension(1,2) = sum(hypertension==0 & apoe4_bin==0) / sum(apoe4_bin==0);
    
    apoe4_adai_carrier_female(1,1) = sum(female(race==1 & apoe4_bin==1));
    apoe4_adai_carrier_female(1,2) = sum(female(race==1 & apoe4_bin==1)) / sum(race==1 & apoe4_bin==1);
    apoe4_adai_noncarrier_female(1,1) = sum(female(race==1 & apoe4_bin==0));
    apoe4_adai_noncarrier_female(1,2) = sum(female(race==1 & apoe4_bin==0)) / sum(race==1 & apoe4_bin==0);
    
    apoe4_adai_carrier_age = [ mean(age(race==1 & apoe4_bin==1),'omitnan') std(age(race==1 & apoe4_bin==1),'omitnan') ];
    apoe4_adai_noncarrier_age = [ mean(age(race==1 & apoe4_bin==0),'omitnan') std(age(race==1 & apoe4_bin==0),'omitnan') ];
    [~, pT_apoe4_adai_age] = ttest2(age(race==1 & apoe4_bin==0),age(race==1 & apoe4_bin==1));
    
    apoe4_adai_carrier_weight = [ mean(weight(race==1 & apoe4_bin==1),'omitnan') std(weight(race==1 & apoe4_bin==1),'omitnan') ];
    apoe4_adai_noncarrier_weight = [ mean(weight(race==1 & apoe4_bin==0),'omitnan') std(weight(race==1 & apoe4_bin==0),'omitnan') ];
    [~, pT_apoe4_adai_adai_weight] = ttest2(weight(race==1 & apoe4_bin==0),weight(race==1 & apoe4_bin==1));
    
    apoe4_adai_carrier_education = [ mean(education(race==1 & apoe4_bin==1),'omitnan') std(education(race==1 & apoe4_bin==1),'omitnan') ];
    apoe4_adai_noncarrier_education = [ mean(education(race==1 & apoe4_bin==0),'omitnan') std(education(race==1 & apoe4_bin==0),'omitnan') ];
    [~, pT_apoe4_adai_education] = ttest2(education(race==1 & apoe4_bin==0),education(race==1 & apoe4_bin==1));
    
    apoe4_adai_carrier_mmse = [ mean(mmse(race==1 & apoe4_bin==1),'omitnan') std(mmse(race==1 & apoe4_bin==1),'omitnan') ];
    apoe4_adai_noncarrier_mmse = [ mean(mmse(race==1 & apoe4_bin==0),'omitnan') std(mmse(race==1 & apoe4_bin==0),'omitnan') ];
    [~, pT_adai_apoe4_mmse] = ttest2(mmse(race==1 & apoe4_bin==0),mmse(race==1 & apoe4_bin==1));
    pW_adai_apoe4_mmse = ranksum(mmse(race==1 & apoe4_bin==0),mmse(race==1 & apoe4_bin==1));
    apoe4_adai_carrier_mmse_quantile = quantile(mmse(race==1 & apoe4_bin==1),[0.5 0.25 0.75]) ;
    apoe4_adai_noncarrier_mmse_quantile = quantile(mmse(race==1 & apoe4_bin==0),[0.5 0.25 0.75]);
    
    apoe4_adai_carrier_hypertension(1,1) = sum(hypertension==1 & race==1 & apoe4_bin==1);
    apoe4_adai_carrier_hypertension(1,2) = sum(hypertension==1 & race==1 & apoe4_bin==1) / sum(race==1 & apoe4_bin==1);
    apoe4_adai_noncarrier_hypertension(1,1) = sum(hypertension==1 & race==1 & apoe4_bin==0);
    apoe4_adai_noncarrier_hypertension(1,2) = sum(hypertension==1 & race==1 & apoe4_bin==0) / sum(race==1 & apoe4_bin==0);
    
    apoe4_adai_carrier_nohypertension(1,1) = sum(hypertension==0 & race==1 & apoe4_bin==1);
    apoe4_adai_carrier_nohypertension(1,2) = sum(hypertension==0 & race==1 & apoe4_bin==1) / sum(race==1 & apoe4_bin==1);
    apoe4_adai_noncarrier_nohypertension(1,1) = sum(hypertension==0 & race==1 & apoe4_bin==0);
    apoe4_adai_noncarrier_nohypertension(1,2) = sum(hypertension==0 & race==1 & apoe4_bin==0) / sum(race==1 & apoe4_bin==0);
    
    apoe4_adni_carrier_female(1,1) = sum(female(race==0 & apoe4_bin==1));
    apoe4_adni_carrier_female(1,2) = sum(female(race==0 & apoe4_bin==1)) / sum(race==0 & apoe4_bin==1);
    apoe4_adni_noncarrier_female(1,1) = sum(female(race==0 & apoe4_bin==0));
    apoe4_adni_noncarrier_female(1,2) = sum(female(race==0 & apoe4_bin==0)) / sum(race==0 & apoe4_bin==0);
    
    apoe4_adni_carrier_age = [ mean(age(race==0 & apoe4_bin==1),'omitnan') std(age(race==0 & apoe4_bin==1),'omitnan') ];
    apoe4_adni_noncarrier_age = [ mean(age(race==0 & apoe4_bin==0),'omitnan') std(age(race==0 & apoe4_bin==0),'omitnan') ];
    [~, pT_apoe4_adni_age] = ttest2(age(race==0 & apoe4_bin==0),age(race==0 & apoe4_bin==1));
    
    apoe4_adni_carrier_weight = [ mean(weight(race==0 & apoe4_bin==1),'omitnan') std(weight(race==0 & apoe4_bin==1),'omitnan') ];
    apoe4_adni_noncarrier_weight = [ mean(weight(race==0 & apoe4_bin==0),'omitnan') std(weight(race==0 & apoe4_bin==0),'omitnan') ];
    [~, pT_apoe4_adni_adni_weight] = ttest2(weight(race==0 & apoe4_bin==0),weight(race==0 & apoe4_bin==1));
    
    apoe4_adni_carrier_education = [ mean(education(race==0 & apoe4_bin==1),'omitnan') std(education(race==0 & apoe4_bin==1),'omitnan') ];
    apoe4_adni_noncarrier_education = [ mean(education(race==0 & apoe4_bin==0),'omitnan') std(education(race==0 & apoe4_bin==0),'omitnan') ];
    [~, pT_apoe4_adni_education] = ttest2(education(race==0 & apoe4_bin==0),education(race==0 & apoe4_bin==1));
    
    apoe4_adni_carrier_mmse = [ mean(mmse(race==0 & apoe4_bin==1),'omitnan') std(mmse(race==0 & apoe4_bin==1),'omitnan') ];
    apoe4_adni_noncarrier_mmse = [ mean(mmse(race==0 & apoe4_bin==0),'omitnan') std(mmse(race==0 & apoe4_bin==0),'omitnan') ];
    [~, pT_adni_apoe4_mmse] = ttest2(mmse(race==0 & apoe4_bin==0),mmse(race==0 & apoe4_bin==1));
    pW_adni_apoe4_mmse = ranksum(mmse(race==0 & apoe4_bin==0),mmse(race==0 & apoe4_bin==1));
    apoe4_adni_carrier_mmse_quantile = quantile(mmse(race==0 & apoe4_bin==1),[0.5 0.25 0.75]);
    apoe4_adni_noncarrier_mmse_quantile = quantile(mmse(race==0 & apoe4_bin==0),[0.5 0.25 0.75]);
    
    apoe4_adni_carrier_hypertension(1,1) = sum(hypertension==1 & race==0 & apoe4_bin==1);
    apoe4_adni_carrier_hypertension(1,2) = sum(hypertension==1 & race==0 & apoe4_bin==1) / sum(race==0 & apoe4_bin==1);
    apoe4_adni_noncarrier_hypertension(1,1) = sum(hypertension==1 & race==0 & apoe4_bin==0);
    apoe4_adni_noncarrier_hypertension(1,2) = sum(hypertension==1 & race==0 & apoe4_bin==0) / sum(race==0 & apoe4_bin==0);
    
    apoe4_adni_carrier_nohypertension(1,1) = sum(hypertension==0 & race==0 & apoe4_bin==1);
    apoe4_adni_carrier_nohypertension(1,2) = sum(hypertension==0 & race==0 & apoe4_bin==1) / sum(race==0 & apoe4_bin==1);
    apoe4_adni_noncarrier_nohypertension(1,1) = sum(hypertension==0 & race==0 & apoe4_bin==0);
    apoe4_adni_noncarrier_nohypertension(1,2) = sum(hypertension==0 & race==0 & apoe4_bin==0) / sum(race==0 & apoe4_bin==0);
    
    %% Filter AI APOE4 carriers - heterozygotes
    ai_subsess_apoe4_heterozygote_female = subsess(race==1 & apoe4==1 & female==1);
    ai_subsess_apoe4_heterozygote_male = subsess(race==1 & apoe4==1 & female==0);
    %% ADAI selection applied
    adai_sex = adai_sex(adai_selection~=0);
    adai_age = adai_age(adai_selection~=0);
    adai_weight = adai_weight(adai_selection~=0);
    adai_education = adai_education(adai_selection~=0);
    adai_hypertension = adai_hypertension(adai_selection~=0);
    adai_apoe4 = adai_apoe4(adai_selection~=0);
    adai_apoe3 = adai_apoe3(adai_selection~=0);
    adai_apoe2 = adai_apoe2(adai_selection~=0);
    adai_mmse = adai_mmse(adai_selection~=0);
    adai_preprocessing = adai_preprocessing(adai_selection~=0);
    adai_dmriAPvols = adai_dmriAPvols(adai_selection~=0);
    adai_dmriPAvols = adai_dmriPAvols(adai_selection~=0);
%     
%     adai_selection = adai_selection(adai_selection~=0);
    
    adai_apoe4_bin = adai_apoe4;
%     adai_apoe4_bin(adai_apoe4>1) = NaN;
    adai_female = strcmp(adai_sex,'F');
    
    adai_nodmri_mmse_quantile = quantile(adai_nodmri_mmse,[0.5 0.25 .75]);
    pW_adai_nodmri_mmse = ranksum(adai_nodmri_mmse,adai_mmse);
    
    %% ADNI selection
    adni_sex = adni_sex(adni_selection~=0);
    adni_age = adni_age(adni_selection~=0);
    adni_weight = adni_weight(adni_selection~=0);
    adni_education = adni_education(adni_selection~=0);
    adni_hypertension = adni_hypertension(adni_selection~=0);
    adni_apoe4 = adni_apoe4(adni_selection~=0);
    adni_apoe3 = adni_apoe3(adni_selection~=0);
    adni_apoe2 = adni_apoe2(adni_selection~=0);
    adni_mmse = adni_mmse(adni_selection~=0);
    adni_preprocessing = adni_preprocessing(adni_selection~=0);
    adni_dmriAPvols = adni_dmriAPvols(adni_selection~=0);
    adni_dmriPAvols = adni_dmriPAvols(adni_selection~=0);
    
    adni_ptid = adni_ptid(adni_selection~=0);
    adni_viscode = adni_viscode(adni_selection~=0);
    
%     adni_selection = adni_selection(adni_selection~=0);
    
    adni_apoe4_bin = adni_apoe4;
%     adni_apoe4_bin(adni_apoe4>1) = NaN;
    adni_female = strcmp(adni_sex,'F');
    
    adni_list = table(adni_ptid,adni_viscode,'VariableNames',{'PTID','VISCODE'});
    
    %% Chi-squared statistics - femnales and hypertension for ADAI and ADNI separately
    [chitbl_adai_female,chi2stat_adai_female,chi_p_adai_female] = crosstab(adai_apoe4_bin,adai_female);
    [chitbl_adai_hypertension,chi2stat_adai_hypertension,chi_p_adai_hypertension] = crosstab(adai_apoe4_bin,adai_hypertension);
    
    [chitbl_adni_female,chi2stat_adni_female,chi_p_adni_female] = crosstab(adni_apoe4_bin,adni_female);
    [chitbl_adni_hypertension,chi2stat_adni_hypertension,chi_p_adni_hypertension] = crosstab(adni_apoe4_bin,adni_hypertension);
    
    %% Demographic stats
    stats_demography{1,2} = 'ADAI';
    stats_demography{1,3} = 'ADNI';
    stats_demography{1,4} = 'p';
    stats_demography{2,1} = 'Subjects';
    stats_demography{3,1} = 'Females';
    stats_demography{4,1} = 'Age [y]';
    stats_demography{5,1} = 'Weight [kg]';
    stats_demography{6,1} = 'Education [y]';
    stats_demography{7,1} = 'MMSE';
    
    stats_demography{9,1} = 'APOE4';
    stats_demography{10,1} = 'Non-carriers';
    stats_demography{11,1} = '1-allele';
    stats_demography{12,1} = '2-allele';
    stats_demography{13,1} = 'Unknown';
    
    stats_demography{15,1} = 'APOE3';
    stats_demography{16,1} = 'Non-carriers';
    stats_demography{17,1} = '1-allele';
    stats_demography{18,1} = '2-allele';
    stats_demography{19,1} = 'Unknown';
    
    stats_demography{21,1} = 'APOE2';
    stats_demography{22,1} = 'Non-carriers';
    stats_demography{23,1} = '1-allele';
    stats_demography{24,1} = '2-allele';
    stats_demography{25,1} = 'Unknown';
    
    stats_demography{27,1} = 'Hypertension';
    stats_demography{28,1} = 'No';
    stats_demography{29,1} = 'Yes';
    stats_demography{30,1} = 'Unknown';
    
    stats_demography{2,2} = size(adai_age,1);
    stats_demography{3,2} = [num2str(sum(adai_female)) ' (' num2str(100*sum(adai_female)/size(adai_female,1),'%.1f') '%)'];
    stats_demography{4,2} = [ num2str(mean(adai_age),'%.1f') '±' num2str(std(adai_age),'%.1f') ];
    stats_demography{5,2} = [ num2str(mean(adai_weight),'%.1f') '±' num2str(std(adai_weight),'%.1f') ];
    stats_demography{6,2} = [ num2str(mean(adai_education,'omitnan'),'%.1f') '±' num2str(std(adai_education,'omitnan'),'%.1f') ];
    stats_demography{7,2} = [ num2str(mean(adai_mmse,'omitnan'),'%.1f') '±' num2str(std(adai_mmse,'omitnan'),'%.1f') ];
    
    stats_demography{10,2} = [num2str(sum(adai_apoe4==0)) ' (' num2str(100*sum(adai_apoe4==0)/size(adai_female,1),'%.1f') '%)'];
    stats_demography{11,2} = [num2str(sum(adai_apoe4==1)) ' (' num2str(100*sum(adai_apoe4==1)/size(adai_female,1),'%.1f') '%)'];
    stats_demography{12,2} = [num2str(sum(adai_apoe4==2)) ' (' num2str(100*sum(adai_apoe4==2)/size(adai_female,1),'%.1f') '%)'];
    stats_demography{13,2} = [num2str(sum(isnan(adai_apoe4))) ' (' num2str(100*sum(isnan(adai_apoe4))/size(adai_female,1),'%.1f') '%)'];
    
    stats_demography{16,2} = [num2str(sum(adai_apoe3==0)) ' (' num2str(100*sum(adai_apoe3==0)/size(adai_female,1),'%.1f') '%)'];
    stats_demography{17,2} = [num2str(sum(adai_apoe3==1)) ' (' num2str(100*sum(adai_apoe3==1)/size(adai_female,1),'%.1f') '%)'];
    stats_demography{18,2} = [num2str(sum(adai_apoe3==2)) ' (' num2str(100*sum(adai_apoe3==2)/size(adai_female,1),'%.1f') '%)'];
    stats_demography{19,2} = [num2str(sum(isnan(adai_apoe3))) ' (' num2str(100*sum(isnan(adai_apoe3))/size(adai_female,1),'%.1f') '%)'];
    
    stats_demography{22,2} = [num2str(sum(adai_apoe2==0)) ' (' num2str(100*sum(adai_apoe2==0)/size(adai_female,1),'%.1f') '%)'];
    stats_demography{23,2} = [num2str(sum(adai_apoe2==1)) ' (' num2str(100*sum(adai_apoe2==1)/size(adai_female,1),'%.1f') '%)'];
    stats_demography{24,2} = [num2str(sum(adai_apoe2==2)) ' (' num2str(100*sum(adai_apoe2==2)/size(adai_female,1),'%.1f') '%)'];
    stats_demography{25,2} = [num2str(sum(isnan(adai_apoe2))) ' (' num2str(100*sum(isnan(adai_apoe2))/size(adai_female,1),'%.1f') '%)'];
    
    stats_demography{28,2} = [num2str(sum(adai_hypertension==0)) ' (' num2str(100*sum(adai_hypertension==0)/size(adai_female,1),'%.1f') '%)'];
    stats_demography{29,2} = [num2str(sum(adai_hypertension==1)) ' (' num2str(100*sum(adai_hypertension==1)/size(adai_female,1),'%.1f') '%)'];
    stats_demography{30,2} = [num2str(sum(isnan(adai_hypertension))) ' (' num2str(100*sum(isnan(adai_hypertension))/size(adai_female,1),'%.1f') '%)'];
    
    stats_demography{2,3} = size(adni_age,1);
    stats_demography{3,3} = [num2str(sum(adni_female)) ' (' num2str(100*sum(adni_female)/size(adni_female,1),'%.1f') '%)'];
    stats_demography{4,3} = [ num2str(mean(adni_age),'%.1f') '±' num2str(std(adni_age),'%.1f') ];
    stats_demography{5,3} = [ num2str(mean(adni_weight),'%.1f') '±' num2str(std(adni_weight),'%.1f') ];
    stats_demography{6,3} = [ num2str(mean(adni_education),'%.1f') '±' num2str(std(adni_education),'%.1f') ];
    stats_demography{7,3} = [ num2str(mean(adni_mmse,'omitnan'),'%.1f') '±' num2str(std(adni_mmse,'omitnan'),'%.1f') ];
    
    stats_demography{10,3} = [num2str(sum(adni_apoe4==0)) ' (' num2str(100*sum(adni_apoe4==0)/size(adni_female,1),'%.1f') '%)'];
    stats_demography{11,3} = [num2str(sum(adni_apoe4==1)) ' (' num2str(100*sum(adni_apoe4==1)/size(adni_female,1),'%.1f') '%)'];
    stats_demography{12,3} = [num2str(sum(adni_apoe4==2)) ' (' num2str(100*sum(adni_apoe4==2)/size(adni_female,1),'%.1f') '%)'];
    stats_demography{13,3} = [num2str(sum(isnan(adni_apoe4))) ' (' num2str(100*sum(isnan(adni_apoe4))/size(adni_female,1),'%.1f') '%)'];
    
    stats_demography{16,3} = [num2str(sum(adni_apoe3==0)) ' (' num2str(100*sum(adni_apoe3==0)/size(adni_female,1),'%.1f') '%)'];
    stats_demography{17,3} = [num2str(sum(adni_apoe3==1)) ' (' num2str(100*sum(adni_apoe3==1)/size(adni_female,1),'%.1f') '%)'];
    stats_demography{18,3} = [num2str(sum(adni_apoe3==2)) ' (' num2str(100*sum(adni_apoe3==2)/size(adni_female,1),'%.1f') '%)'];
    stats_demography{19,3} = [num2str(sum(isnan(adni_apoe3))) ' (' num2str(100*sum(isnan(adni_apoe3))/size(adni_female,1),'%.1f') '%)'];
    
    stats_demography{22,3} = [num2str(sum(adni_apoe2==0)) ' (' num2str(100*sum(adni_apoe2==0)/size(adni_female,1),'%.1f') '%)'];
    stats_demography{23,3} = [num2str(sum(adni_apoe2==1)) ' (' num2str(100*sum(adni_apoe2==1)/size(adni_female,1),'%.1f') '%)'];
    stats_demography{24,3} = [num2str(sum(adni_apoe2==2)) ' (' num2str(100*sum(adni_apoe2==2)/size(adni_female,1),'%.1f') '%)'];
    stats_demography{25,3} = [num2str(sum(isnan(adni_apoe2))) ' (' num2str(100*sum(isnan(adni_apoe2))/size(adni_female,1),'%.1f') '%)'];
    
    stats_demography{28,3} = [num2str(sum(adni_hypertension==0)) ' (' num2str(100*sum(adni_hypertension==0)/size(adni_female,1),'%.1f') '%)'];
    stats_demography{29,3} = [num2str(sum(adni_hypertension==1)) ' (' num2str(100*sum(adni_hypertension==1)/size(adni_female,1),'%.1f') '%)'];
    stats_demography{30,3} = [num2str(sum(isnan(adni_hypertension))) ' (' num2str(100*sum(isnan(adni_hypertension))/size(adni_female,1),'%.1f') '%)'];
    
    [~, stats_demography{4,4}] = ttest2(adai_age,adni_age);
    [~, stats_demography{5,4}] = ttest2(adai_weight,adni_weight);
    [~, stats_demography{6,4}] = ttest2(adai_education,adni_education);
    [~, stats_demography{7,4}] = ttest2(adai_mmse,adni_mmse);
    
    adai_mmse_quantile = quantile(adai_mmse,[0.5 0.25 0.75]);
    adni_mmse_quantile = quantile(adni_mmse,[0.5 0.25 0.75]);
    pW_mmse_NHWvsAI = ranksum(adai_mmse,adni_mmse);
    
    %% Chi-squared statistics - femnales and hypertension
    x1 = [ ones(size(adai_female)); 2*ones(size(adni_female))];
    x2 = [adai_female; adni_female];
    [chitbl_female,chi2stat_female,chi_p_female] = crosstab(x1,x2);
    
    x1 = [ ones(size(adai_hypertension)); 2*ones(size(adni_hypertension))];
    x2 = [adai_hypertension; adni_hypertension];
    [chitbl_hypertension,chi2stat_hypertension,chi_p_hypertension] = crosstab(x1,x2);
    %% Define tract database and tracts of interest
    tract_list = {
            'Anterior_Commissure'
            'Arcuate_Fasciculus_L'
            'Arcuate_Fasciculus_R'
            'Cerebellum_L'
            'Cerebellum_R'
            'Cingulum_Frontal_Parahippocampal_L'
            'Cingulum_Frontal_Parahippocampal_R'
            'Cingulum_Frontal_Parietal_L'
            'Cingulum_Frontal_Parietal_R'
            'Cingulum_Parahippocampal_L'
            'Cingulum_Parahippocampal_Parietal_L'
            'Cingulum_Parahippocampal_Parietal_R'
            'Cingulum_Parahippocampal_R'
            'Cingulum_Parolfactory_L'
            'Cingulum_Parolfactory_R'
            'Corpus_Callosum_Body'
            'Corpus_Callosum_Forceps_Major'
            'Corpus_Callosum_Forceps_Minor'
            'Corticobulbar_Tract_L'
            'Corticobulbar_Tract_R'
            'Corticopontine_Tract_Frontal_L'
            'Corticopontine_Tract_Frontal_R'
            'Corticopontine_Tract_Occipital_L'
            'Corticopontine_Tract_Occipital_R'
            'Corticopontine_Tract_Parietal_L'
            'Corticopontine_Tract_Parietal_R'
            'Corticospinal_Tract_L'
            'Corticospinal_Tract_R'
            'Corticostriatal_Tract_Anterior_L'
            'Corticostriatal_Tract_Anterior_R'
            'Corticostriatal_Tract_Posterior_L'
            'Corticostriatal_Tract_Posterior_R'
            'Corticostriatal_Tract_Superior_L'
            'Corticostriatal_Tract_Superior_R'
            'Dentatorubrothalamic_Tract_L'
            'Dentatorubrothalamic_Tract_R'
            'Extreme_Capsule_L'
            'Extreme_Capsule_R'
            'Fornix_L'
            'Fornix_R'
            'Frontal_Aslant_Tract_L'
            'Frontal_Aslant_Tract_R'
            'Inferior_Cerebellar_Peduncle_L'
            'Inferior_Cerebellar_Peduncle_R'
            'Inferior_Fronto_Occipital_Fasciculus_L'
            'Inferior_Fronto_Occipital_Fasciculus_R'
            'Inferior_Longitudinal_Fasciculus_L'
            'Inferior_Longitudinal_Fasciculus_R'
            'Medial_Lemniscus_L'
            'Medial_Lemniscus_R'
            'Middle_Cerebellar_Peduncle'
            'Middle_Longitudinal_Fasciculus_L'
            'Middle_Longitudinal_Fasciculus_R'
            'Optic_Radiation_L'
            'Optic_Radiation_R'
            'Parietal_Aslant_Tract_L'
            'Parietal_Aslant_Tract_R'
            'Reticular_Tract_L'
            'Reticular_Tract_R'
            'Superior_Cerebellar_Peduncle'
            'Superior_Longitudinal_Fasciculus1_L'
            'Superior_Longitudinal_Fasciculus1_R'
            'Superior_Longitudinal_Fasciculus2_L'
            'Superior_Longitudinal_Fasciculus2_R'
            'Superior_Longitudinal_Fasciculus3_L'
            'Superior_Longitudinal_Fasciculus3_R'
            'Thalamic_Radiation_Anterior_L'
            'Thalamic_Radiation_Anterior_R'
            'Thalamic_Radiation_Posterior_L'
            'Thalamic_Radiation_Posterior_R'
            'Thalamic_Radiation_Superior_L'
            'Thalamic_Radiation_Superior_R'
            'Uncinate_Fasciculus_L'
            'Uncinate_Fasciculus_R'
            'Vermis'
            'Vertical_Occipital_Fasciculus_L'
            'Vertical_Occipital_Fasciculus_R'
            };
    tract_keywords = {
            'Cingulum'
            'Cingulum_Parahippocampal'
            'Corpus_Callosum'
            'Fornix'
            'Frontal_Aslant_Tract'
            'Inferior_Fronto_Occipital_Fasciculus'
            'Inferior_Longitudinal_Fasciculus'
            'Uncinate_Fasciculus'
            };
        
%     tract_keywords = {
%             'Cingulum'
%             'Cingulum_Parahippocampal'
%             'Cingulum_Parahippocampal_L'
%             'Cingulum_Parahippocampal_R'
%             'Corpus_Callosum'
%             'Fornix'
%             'Fornix_L'
%             'Fornix_R'
%             'Frontal_Aslant_Tract'
%             'Frontal_Aslant_Tract_L'
%             'Frontal_Aslant_Tract_R'
%             'Inferior_Fronto_Occipital_Fasciculus'
%             'Inferior_Fronto_Occipital_Fasciculus_L'
%             'Inferior_Fronto_Occipital_Fasciculus_R'
%             'Inferior_Longitudinal_Fasciculus'
%             'Inferior_Longitudinal_Fasciculus_L'
%             'Inferior_Longitudinal_Fasciculus_R'
%             'Uncinate_Fasciculus'
%             'Uncinate_Fasciculus_L'
%             'Uncinate_Fasciculus_R'
%             };
        
%     tract_keywords = {
%             'Anterior_Commissure'
%             'Arcuate_Fasciculus'
%             'Cerebellum'
%             'Cerebellar_Peduncle'
%             'Inferior_Cerebellar_Peduncle'
%             'Middle_Cerebellar_Peduncle'
%             'Superior_Cerebellar_Peduncle'
%             'Cingulum'
%             'Cingulum_Frontal_Parahippocampal'
%             'Cingulum_Frontal_Parietal'
%             'Cingulum_Parahippocampal'
%             'Cingulum_Parahippocampal_Parietal'
%             'Cingulum_Parolfactory'
%             'Corpus_Callosum'
%             'Corpus_Callosum_Body'
%             'Corpus_Callosum_Forceps_Major'
%             'Corpus_Callosum_Forceps_Minor'
%             'Corticobulbar_Tract'
%             'Corticospinal_Tract'
%             'Corticostriatal_Tract'
%             'Dentatorubrothalamic_Tract'
%             'Extreme_Capsule'
%             'Fornix'
%             'Frontal_Aslant_Tract'
%             'Inferior_Fronto_Occipital_Fasciculus'
%             'Inferior_Longitudinal_Fasciculus'
%             'Medial_Lemniscus'
%             'Middle_Longitudinal_Fasciculus'
%             'Optic_Radiation'
%             'Parietal_Aslant_Tract'
%             'Reticular_Tract'
%             'Superior_Longitudinal_Fasciculus'
%             'Superior_Longitudinal_Fasciculus1'
%             'Superior_Longitudinal_Fasciculus2'
%             'Superior_Longitudinal_Fasciculus3'
%             'Thalamic_Radiation'
%             'Thalamic_Radiation_Anterior'
%             'Thalamic_Radiation_Posterior'
%             'Thalamic_Radiation_Superior'
%             'Uncinate_Fasciculus'
%             'Vermis'
%             'Vertical_Occipital_Fasciculus'
%             };
        
    %% Extract tractography measurements
    for trid = 1:size(tract_list,1)
            adai_tract(trid,1) = build_tractography_measurements(table_folder,{'dmri'},tract_list{trid,1},{'ADNI3'},tract_voxel_ratio);
            adni_tract(trid,1) = build_tractography_measurements(table_folder2,{'dmri'},tract_list{trid,1},{'ADNI3'},tract_voxel_ratio);
    end
    tract = concatenate_tract_results(adai_tract,adni_tract);
    for trid = 1:size(tract_keywords,1)
            [tractometry(trid,1), tract_data(:,trid,:), tract_data_name] = merge_tractography_measurements(tract,tract_keywords{trid,1});
            [adai_tractometry(trid,1), adai_tract_data(:,trid,:), adai_tract_data_name] = merge_tractography_measurements(adai_tract,tract_keywords{trid,1});
            [adni_tractometry(trid,1), adni_tract_data(:,trid,:), adni_tract_data_name] = merge_tractography_measurements(adni_tract,tract_keywords{trid,1});
    end
    % tract_data dimensions: dimension 1 = number of total tractometry variables
    %                        dimension 2 = number of tracts of interest listed in tract_keywords
    %                        dimension 3 = number of subjects/sessions/etc.
    %                        dimension 4 (if available) = number of dMRI protocols of preprocessing strategies
    tmp = zeros(size(tract_data,1), size(tract_data,2), size(subsess,1));
    for ind = 1:size(subsess,1)
        tmp(:,:,ind) = tract_data(:,:,strcmp(tractometry(1,1).SUBID,subsess{ind,1}));
    end
    tract_data = tmp;
    clear tmp
    tract_data_name_dsi = tract_data_name;
    tract_data_name = correct_tract_data_name(tract_data_name);
    
    tmp = zeros(size(tract_data,1), size(tract_data,2), size(adai_subsess,1));
    for ind = 1:size(adai_subsess,1)
        tmp(:,:,ind) = adai_tract_data(:,:,strcmp(adai_tractometry(1,1).SUBID,adai_subsess{ind,1}));
    end
    adai_tract_data = tmp;
    clear tmp
    
    tmp = zeros(size(tract_data,1), size(tract_data,2), size(adni_subsess,1));
    for ind = 1:size(adni_subsess,1)
        tmp(:,:,ind) = adni_tract_data(:,:,strcmp(adni_tractometry(1,1).SUBID,adni_subsess{ind,1}));
    end
    adni_tract_data = tmp;
    clear tmp
    % Exclude outlier in 2shell-online CSt tractography measurement (Streamlines for both sides appers fine but branch volume measure is 9400 for left side, i.e. some fail in DSI Studio value estimate)
    % out_pos = squeeze(tract_data(strcmp(tract_data_name_dsi,'branch_volume_mm3'),strcmp(tract_tractorder,'cst'),strcmp(protocol_name,'2shell-online'),:))>10000;
    % tract_data(strcmp(tract_data_name_dsi,'branch_volume_mm3'),strcmp(tract_tractorder,'cst'),strcmp(protocol_name,'2shell-online'),out_pos) = NaN;

    save(extract_data_file)
end

%% Eastimate stats and visualize figures
if estimate_stats == 1
    
   
   T = [
       0 0 0 0 0 0
       0 1 0 0 0 0
       0 0 1 0 0 0
       0 0 0 1 0 0
       0 0 0 0 1 0
       0 0 0 0 0 1
       0 1 0 0 0 1
       ]; 
   mdl1 = cell(0,0);
   mdl2 = cell(0,0);
   ci1 = cell(0,0);
   ci2 = cell(0,0);
   data = struct([]);
   fig_id = 1;
   for trct = 1:size(tract_data,2)
       for metr = 1:size(tract_data,1)
           vec = squeeze(tract_data(metr,trct,selection2==1));
           
           tbl = table(vec,apoe4_bin==1,sex,age/10,hypertension==1,race_cat,'VariableNames',{'y','APOE4','Sex','Age','Hypertension','Race'});
           tbl2 = table(vec,apoe4_bin==1,sex,age/10,hypertension==1,race==1,'VariableNames',{'y','APOE4','Sex','Age','Hypertension','Race'});
           mdl1{trct,metr} = fitlm(tbl,T);
           mdl2{trct,metr} = fitlm(tbl2,T);
           ci1{trct,metr} = coefCI(mdl1{trct,metr});
           ci2{trct,metr} = coefCI(mdl2{trct,metr});
           p_mdl1_apoe4Xrace(trct,metr) = cell2mat(table2cell(mdl1{trct,metr}.Coefficients('APOE4_1:Race_White','pValue')));
           p_mdl1_apoe4AmongNatAm(trct,metr) = cell2mat(table2cell(mdl1{trct,metr}.Coefficients('APOE4_1','pValue')));
           p_mdl1_apoe4AmongWhiteNonHisp(trct,metr) = cell2mat(table2cell(mdl2{trct,metr}.Coefficients('APOE4_1','pValue')));
           
           adai_vec = squeeze(adai_tract_data(metr,trct,adai_selection==1));
           adni_vec = squeeze(adni_tract_data(metr,trct,adni_selection==1));
            
           apoe4_noncarrier = vec(apoe4==0);
           apoe4_carrier = vec(apoe4>0);
           
           adai_apoe4_noncarrier = adai_vec(adai_apoe4==0);
           adai_apoe4_carrier = adai_vec(adai_apoe4>0);
           
           adni_apoe4_noncarrier = adni_vec(adni_apoe4==0);
           adni_apoe4_carrier = adni_vec(adni_apoe4>0);
            
           pW_apoe4(trct,metr) = ranksum(apoe4_noncarrier,apoe4_carrier);
           [~, pT_apoe4(trct,metr)] = ttest2(apoe4_noncarrier,apoe4_carrier);
           
           adai_pW_apoe4(trct,metr) = ranksum(adai_apoe4_noncarrier,adai_apoe4_carrier);
           [~, adai_pT_apoe4(trct,metr)] = ttest2(adai_apoe4_noncarrier,adai_apoe4_carrier);
           
           adni_pW_apoe4(trct,metr) = ranksum(adni_apoe4_noncarrier,adni_apoe4_carrier);
           [~, adni_pT_apoe4(trct,metr)] = ttest2(adni_apoe4_noncarrier,adni_apoe4_carrier);
            
           [p_effect(trct,metr,:), tbl_effect{trct,metr}] = anovan(vec,{apoe4_bin, female, age, hypertension, race },'Continuous',3,'varnames',{'APOE4', 'Sex','Age', 'Hypertension', 'Race'},'display','off'); % ,'model','interaction'
           [p_int(trct,metr,:), tbl_int{trct,metr}] = anovan(vec,{apoe4_bin, female, age, hypertension, race },'Continuous',3,'varnames',{'APOE4', 'Sex','Age', 'Hypertension', 'Race'},'model','interaction','display','off'); % 
           
           [adai_p_effect(trct,metr,:), adai_tbl_effect{trct,metr}] = anovan(adai_vec,{adai_apoe4_bin, adai_female, adai_age, adai_hypertension},'Continuous',3,'varnames',{'APOE4', 'Sex','Age', 'Hypertension'},'display','off'); % ,'model','interaction'
           [adai_p_int(trct,metr,:), adai_tbl_int{trct,metr}] = anovan(adai_vec,{adai_apoe4_bin, adai_female, adai_age, adai_hypertension},'Continuous',3,'varnames',{'APOE4', 'Sex','Age', 'Hypertension'},'model','interaction','display','off');
           
           [adni_p_effect(trct,metr,:), adni_tbl_effect{trct,metr}] = anovan(adni_vec,{adni_apoe4_bin, adni_female, adni_age, adni_hypertension},'Continuous',3,'varnames',{'APOE4', 'Sex','Age', 'Hypertension'},'display','off'); % ,'model','interaction'
           [adni_p_int(trct,metr,:), adni_tbl_int{trct,metr}] = anovan(adni_vec,{adni_apoe4_bin, adni_female, adni_age, adni_hypertension},'Continuous',3,'varnames',{'APOE4', 'Sex','Age', 'Hypertension'},'model','interaction','display','off');
           
           tract_data_apoe4_noncarrier_mean(trct,metr) = mean(apoe4_noncarrier,'omitnan');
           tract_data_apoe4_carrier_mean(trct,metr) = mean(apoe4_carrier,'omitnan');
           tract_data_apoe4_noncarrier_std(trct,metr) = std(apoe4_noncarrier,'omitnan');
           tract_data_apoe4_carrier_std(trct,metr) = std(apoe4_carrier,'omitnan');
           tract_data_apoe4_noncarrier_iqr(trct,metr,:) = quantile(apoe4_noncarrier,[0.15 0.5 0.85]);
           tract_data_apoe4_carrier_iqr(trct,metr,:) = quantile(apoe4_carrier,[0.15 0.5 0.85]);
       end
   end
end

%% Select variables of interest
tract_data_name_dsi_select_pos = [1 3 4 5 6 7 8 9 10 21 23 24 25 28 30];

select_tract_data_name_dsi = tract_data_name_dsi(1,tract_data_name_dsi_select_pos);
select_adai_tract_data = adai_tract_data(tract_data_name_dsi_select_pos,:,:);
select_adni_tract_data = adni_tract_data(tract_data_name_dsi_select_pos,:,:);
select_tract_data = tract_data(tract_data_name_dsi_select_pos,:,:);
%% ADAI+ADNI stats together
select_pT_apoe4 = pT_apoe4(:,tract_data_name_dsi_select_pos);
select_p_effect = p_effect(:,tract_data_name_dsi_select_pos,:);
select_tbl_effect = tbl_effect(:,tract_data_name_dsi_select_pos);
select_p_int = p_int(:,tract_data_name_dsi_select_pos,:);
select_tbl_int = tbl_int(:,tract_data_name_dsi_select_pos);

% select_p_effect_apoe4 = squeeze(select_p_effect(:,:,1));
% select_p_effect_race = squeeze(select_p_effect(:,:,2));
% select_p_effect_sex = squeeze(select_p_effect(:,:,3));
% select_p_effect_age = squeeze(select_p_effect(:,:,4));
% select_p_effect_weight = squeeze(select_p_effect(:,:,5));
% select_p_effect_education = squeeze(select_p_effect(:,:,6));
% select_p_effect_hypertension = squeeze(select_p_effect(:,:,7));
% 
% select_p_int_apoe4 = squeeze(select_p_int(:,:,1));
% select_p_int_race = squeeze(select_p_int(:,:,2));
% select_p_int_sex = squeeze(select_p_int(:,:,3));
% select_p_int_age = squeeze(select_p_int(:,:,4));
% select_p_int_weight = squeeze(select_p_int(:,:,5));
% select_p_int_apoe4Xrace = squeeze(select_p_int(:,:,6));
% select_p_int_apoe4Xsex = squeeze(select_p_int(:,:,7));
% select_p_int_apoe4Xage = squeeze(select_p_int(:,:,8));
% select_p_int_apoe4Xweight = squeeze(select_p_int(:,:,9));
% select_p_int_raceXsex = squeeze(select_p_int(:,:,10));
% select_p_int_raceXage = squeeze(select_p_int(:,:,11));
% select_p_int_raceXweight = squeeze(select_p_int(:,:,12));
% select_p_int_sexXage = squeeze(select_p_int(:,:,13));

%% ADAI stats
select_adai_pT_apoe4 = adai_pT_apoe4(:,tract_data_name_dsi_select_pos);
select_adai_p_effect = adai_p_effect(:,tract_data_name_dsi_select_pos,:);
select_adai_tbl_effect = adai_tbl_effect(:,tract_data_name_dsi_select_pos);
select_adai_p_int = adai_p_int(:,tract_data_name_dsi_select_pos,:);
select_adai_tbl_int = adai_tbl_int(:,tract_data_name_dsi_select_pos);

%% ADNI stats
select_adni_pT_apoe4 = adni_pT_apoe4(:,tract_data_name_dsi_select_pos);
select_adni_p_effect = adni_p_effect(:,tract_data_name_dsi_select_pos,:);
select_adni_tbl_effect = adni_tbl_effect(:,tract_data_name_dsi_select_pos);
select_adni_p_int = adni_p_int(:,tract_data_name_dsi_select_pos,:);
select_adni_tbl_int = adni_tbl_int(:,tract_data_name_dsi_select_pos);

%% Merge ADAI and ADNI separate analysis results
select_adaiadni_pT_apoe4 = [select_adai_pT_apoe4; select_adni_pT_apoe4; pT_apoe4(:,tract_data_name_dsi_select_pos)];

select_adaiadni_p_effect_apoe4 = [ squeeze(select_adai_p_effect(:,:,1)); squeeze(select_adni_p_effect(:,:,1)); squeeze(select_p_effect(:,:,1))];
select_adaiadni_p_effect_sex = [ squeeze(select_adai_p_effect(:,:,2)); squeeze(select_adni_p_effect(:,:,2)); squeeze(select_p_effect(:,:,2))];
select_adaiadni_p_effect_age = [ squeeze(select_adai_p_effect(:,:,3)); squeeze(select_adni_p_effect(:,:,3)); squeeze(select_p_effect(:,:,3))];
select_adaiadni_p_effect_hypertension = [ squeeze(select_adai_p_effect(:,:,4)); squeeze(select_adni_p_effect(:,:,4)); squeeze(select_p_effect(:,:,4))];

select_adaiadni_p_int_apoe4 = [ squeeze(select_adai_p_int(:,:,1)); squeeze(select_adni_p_int(:,:,1)); squeeze(select_p_int(:,:,1))];
select_adaiadni_p_int_sex = [ squeeze(select_adai_p_int(:,:,2)); squeeze(select_adni_p_int(:,:,2)); squeeze(select_p_int(:,:,2))];
select_adaiadni_p_int_age = [ squeeze(select_adai_p_int(:,:,3)); squeeze(select_adni_p_int(:,:,3)); squeeze(select_p_int(:,:,3))];
select_adaiadni_p_int_hypertension = [ squeeze(select_adai_p_int(:,:,4)); squeeze(select_adni_p_int(:,:,4)); squeeze(select_p_int(:,:,4))];

select_adaiadni_p_int_apoe4Xsex = [ squeeze(select_adai_p_int(:,:,5)); squeeze(select_adni_p_int(:,:,5)); squeeze(select_p_int(:,:,6))];


select_adaiadni_p_int_race = squeeze(select_p_int(:,:,5));
select_adaiadni_p_int_apoe4Xrace = squeeze(select_p_int(:,:,9));


select_p_mdl1_apoe4Xrace = p_mdl1_apoe4Xrace(:,tract_data_name_dsi_select_pos);
select_p_mdl1_apoe4AmongNatAm = p_mdl1_apoe4AmongNatAm(:,tract_data_name_dsi_select_pos);
select_p_mdl1_apoe4AmongWhiteNonHisp = p_mdl1_apoe4AmongWhiteNonHisp(:,tract_data_name_dsi_select_pos);

%% Extract dMRI results and correct for multiple comparisons errors
dmri_pos = tract_data_name_dsi_select_pos(end-5:end);
[~, ~, ~, select_pBH_mdl1_apoe4Xrace_dmri ] = fdr_bh(p_mdl1_apoe4Xrace(:,dmri_pos));
[~, ~, ~, select_pBH_mdl1_apoe4AmongNatAm_dmri ] = fdr_bh(p_mdl1_apoe4AmongNatAm(:,dmri_pos));
[~, ~, ~, select_pBH_mdl1_apoe4AmongWhiteNonHisp_dmri ] = fdr_bh(p_mdl1_apoe4AmongWhiteNonHisp(:,dmri_pos));
% for vr = 1:size(dmri_pos,2)
%     [~, ~, ~, select_p_mdl1_apoe4Xrace_dmri(:,vr) ] = fdr_bh(p_mdl1_apoe4Xrace(:,dmri_pos(1,vr)));
%     [~, ~, ~, select_p_mdl1_apoe4AmongNatAm_dmri(:,vr) ] = fdr_bh(p_mdl1_apoe4AmongNatAm(:,dmri_pos(1,vr)));
%     [~, ~, ~, select_p_mdl1_apoe4AmongWhiteNonHisp_dmri(:,vr) ] = fdr_bh(p_mdl1_apoe4AmongWhiteNonHisp(:,dmri_pos(1,vr)));
% end

%% Visualize forest graphs for APOE4
% clr_wh = [0 0 1];
% clr_na = [1 0 0];
% clr_ar = [0 0.8 0];
% 
% fig_id = 1;
% ymax = size(mdl1,1);
% tract_labels = flip(strrep(tract_keywords,'_',' '),1);
% 
% for vr = 1:size(dmri_pos,2)
%     h(vr).fig = figure(vr);
%     set(h(vr).fig,'Position',[1400 50 900 800])
%     plot([0 0],[-100 100],'k','LineWidth',2)
%     hold on
%     cii = [];
%     for trct = 1:size(mdl1,1)
%         wh_es_apoe4 = cell2mat(table2cell(mdl2{trct,dmri_pos(1,vr)}.Coefficients('APOE4_1','Estimate')));
%         na_es_apoe4 = cell2mat(table2cell(mdl1{trct,dmri_pos(1,vr)}.Coefficients('APOE4_1','Estimate')));
%         wh_ci_apoe4 = ci2{trct,dmri_pos(1,vr)}(strcmp(mdl2{trct,dmri_pos(1,vr)}.CoefficientNames,'APOE4_1'),:);
%         na_ci_apoe4 = ci1{trct,dmri_pos(1,vr)}(strcmp(mdl1{trct,dmri_pos(1,vr)}.CoefficientNames,'APOE4_1'),:);
% %         es_apoe4Xrace = cell2mat(table2cell(mdl1{trct,dmri_pos(1,vr)}.Coefficients('APOE4_1:Race_White','Estimate')));
% %         ci_apoe4Xrace = ci1{trct,dmri_pos(1,vr)}(strcmp(mdl1{trct,dmri_pos(1,vr)}.CoefficientNames,'APOE4_1:Race_White'),:);
%         
%         cii = [cii; wh_ci_apoe4; na_ci_apoe4];
% 
%         y = ymax - trct + 1;
%         plot(wh_ci_apoe4,[y y],'-','LineWidth',4,'Color',clr_wh)
% %         if trct == 1
% %             hold on
% %         end
%         plot(na_ci_apoe4,[y-0.3 y-0.3],'-','LineWidth',4,'Color',clr_na)
% %         plot(ci_apoe4Xrace,[y-0.4 y-0.4],'-','LineWidth',4,'Color',clr_ar)
%         H1 = plot(wh_es_apoe4,y,'d','MarkerSize',10,'LineWidth',6,'Color',clr_wh,'markerfacecolor',clr_wh);
%         H2 = plot(na_es_apoe4,[y-0.3 y-0.3],'x','MarkerSize',14,'LineWidth',6,'Color',clr_na,'markerfacecolor',clr_na);
% %         H3 = plot(es_apoe4Xrace,[y-0.4 y-0.4],'d','MarkerSize',10,'LineWidth',6,'Color',clr_ar,'markerfacecolor',clr_ar);
% 
%         
%         
%     end
% %     if contains(tract_data_name{1,dmri_pos(1,vr)},'dispersion')
% %         legend([H1 H2(1,1)],{'White non-Hispanic','American Indian'},'location','northwest')
% %     else
% %         legend([H1 H2(1,1)],{'White non-Hispanic','American Indian'})
% %     end
%     hold off
%     grid on
%     ylim([0 8.6])
%     xlim(1.05*[-max(abs(cii(:))) max(abs(cii(:)))])
%     xlabel({['Differences in ' tract_data_name{1,dmri_pos(1,vr)}];
%         'between APOE4 carriers vs. non-carriers'})
% %     ylabel('Region of interest')
% %     if contains(tract_data_name{1,dmri_pos(1,vr)},' [')
% %         title(extractBefore(tract_data_name{1,dmri_pos(1,vr)},' ['))
% %     else
% %         title(tract_data_name{1,dmri_pos(1,vr)})
% %     end
%     set(gca,'Linewidth',2,'FontSize',14,'YTick',1:ymax,'YTickLabel',tract_labels)
%     ytickangle(45)
%     
%     print(fullfile(save_path,['graph' num2str(vr) '-forest-plot']),'-dpng','-r300')
%     pause(0.15)
%     close(h(vr).fig)
%     pause(0.1)
%     disp(num2str(vr))
% end

%% Visualize forest graphs
draw_forest_plot(mdl1,mdl2,ci1,ci2,'APOE4_1','apoe4',tract_keywords,tract_data_name,dmri_pos,save_path,'between APOE4 carriers vs. non-carriers')
draw_forest_plot(mdl1,mdl2,ci1,ci2,'Age','age',tract_keywords,tract_data_name,dmri_pos,save_path,'Age')
draw_forest_plot(mdl1,mdl2,ci1,ci2,'Hypertension_1','hypertension',tract_keywords,tract_data_name,dmri_pos,save_path,'Hypertension')
draw_forest_plot(mdl1,mdl2,ci1,ci2,'Sex_M','sex',tract_keywords,tract_data_name,dmri_pos,save_path,'Male sex')


%% ADAI, ADNI variable mean and STD stats
for vrid = 1:size(select_adai_tract_data,1)
    for trid = 1:size(select_adai_tract_data,2)
        vec = squeeze(select_adai_tract_data(vrid,trid,:));
        stats_adai_imaging(trid,4*(vrid-1)+1) = mean(vec(adai_apoe4_bin==0),'omitnan');
        stats_adai_imaging(trid,4*(vrid-1)+2) = std(vec(adai_apoe4_bin==0),'omitnan');
        stats_adai_imaging(trid,4*(vrid-1)+3) = mean(vec(adai_apoe4_bin==1),'omitnan');
        stats_adai_imaging(trid,4*(vrid-1)+4) = std(vec(adai_apoe4_bin==1),'omitnan');
        
        vec = squeeze(select_adni_tract_data(vrid,trid,:));
        stats_adni_imaging(trid,4*(vrid-1)+1) = mean(vec(adni_apoe4_bin==0),'omitnan');
        stats_adni_imaging(trid,4*(vrid-1)+2) = std(vec(adni_apoe4_bin==0),'omitnan');
        stats_adni_imaging(trid,4*(vrid-1)+3) = mean(vec(adni_apoe4_bin==1),'omitnan');
        stats_adni_imaging(trid,4*(vrid-1)+4) = std(vec(adni_apoe4_bin==1),'omitnan');
        
        vec = squeeze(select_tract_data(vrid,trid,:));
        stats_imaging(trid,4*(vrid-1)+1) = mean(vec(apoe4_bin==0),'omitnan');
        stats_imaging(trid,4*(vrid-1)+2) = std(vec(apoe4_bin==0),'omitnan');
        stats_imaging(trid,4*(vrid-1)+3) = mean(vec(apoe4_bin==1),'omitnan');
        stats_imaging(trid,4*(vrid-1)+4) = std(vec(apoe4_bin==1),'omitnan');
    end
end

stats_imaging_merge = [stats_adai_imaging; stats_adni_imaging; stats_imaging];

%% Functions

function draw_forest_plot(mdl1,mdl2,ci1,ci2,coefficient_name,basename,tract_keywords,tract_data_name,dmri_pos,save_path,xlbl)
    clr_wh = [0 0 1];
    clr_na = [1 0 0];
    clr_ar = [0 0.8 0];
    if ~strcmp(basename,'apoe4')
        clr_wh = [0 0 0];
    end

    ymax = size(mdl1,1);
    tract_labels = flip(strrep(tract_keywords,'_',' '),1);

    for vr = 1:size(dmri_pos,2)
        h(vr).fig = figure(vr);
        set(h(vr).fig,'Position',[1400 50 900 800])
        plot([0 0],[-100 100],'k','LineWidth',2)
        hold on
        cii = [];
        for trct = 1:size(mdl1,1)
            wh_es_apoe4 = cell2mat(table2cell(mdl2{trct,dmri_pos(1,vr)}.Coefficients(coefficient_name,'Estimate')));
            na_es_apoe4 = cell2mat(table2cell(mdl1{trct,dmri_pos(1,vr)}.Coefficients(coefficient_name,'Estimate')));
            wh_ci_apoe4 = ci2{trct,dmri_pos(1,vr)}(strcmp(mdl2{trct,dmri_pos(1,vr)}.CoefficientNames,coefficient_name),:);
            na_ci_apoe4 = ci1{trct,dmri_pos(1,vr)}(strcmp(mdl1{trct,dmri_pos(1,vr)}.CoefficientNames,coefficient_name),:);
    %         es_apoe4Xrace = cell2mat(table2cell(mdl1{trct,dmri_pos(1,vr)}.Coefficients('APOE4_1:Race_White','Estimate')));
    %         ci_apoe4Xrace = ci1{trct,dmri_pos(1,vr)}(strcmp(mdl1{trct,dmri_pos(1,vr)}.CoefficientNames,'APOE4_1:Race_White'),:);

            cii = [cii; wh_ci_apoe4; na_ci_apoe4];

            y = ymax - trct + 1;
            plot(wh_ci_apoe4,[y y],'-','LineWidth',4,'Color',clr_wh)
    %         if trct == 1
    %             hold on
    %         end
            if strcmp(basename,'apoe4')
                plot(na_ci_apoe4,[y-0.3 y-0.3],'-','LineWidth',4,'Color',clr_na)
        %         plot(ci_apoe4Xrace,[y-0.4 y-0.4],'-','LineWidth',4,'Color',clr_ar)
                H2 = plot(na_es_apoe4,[y-0.3 y-0.3],'x','MarkerSize',14,'LineWidth',6,'Color',clr_na,'markerfacecolor',clr_na);
            end
            H1 = plot(wh_es_apoe4,y,'d','MarkerSize',10,'LineWidth',6,'Color',clr_wh,'markerfacecolor',clr_wh);
    %         H3 = plot(es_apoe4Xrace,[y-0.4 y-0.4],'d','MarkerSize',10,'LineWidth',6,'Color',clr_ar,'markerfacecolor',clr_ar);



        end
    %     if contains(tract_data_name{1,dmri_pos(1,vr)},'dispersion')
    %         legend([H1 H2(1,1)],{'White non-Hispanic','American Indian'},'location','northwest')
    %     else
    %         legend([H1 H2(1,1)],{'White non-Hispanic','American Indian'})
    %     end
        hold off
        grid on
        ylim([0 8.6])
        xlim(1.05*[-max(abs(cii(:))) max(abs(cii(:)))])
        if strcmp(basename,'apoe4')
            xlabel({['Differences in ' tract_data_name{1,dmri_pos(1,vr)}];
                xlbl})
        elseif strcmp(basename,'ageXXX')
            xlabel( { ' ' ; [xlbl ' effects in ' tract_data_name{1,dmri_pos(1,vr)}] } )
        else
            xlabel( [xlbl ' effects in ' tract_data_name{1,dmri_pos(1,vr)}] )
        end
    %     ylabel('Region of interest')
    %     if contains(tract_data_name{1,dmri_pos(1,vr)},' [')
    %         title(extractBefore(tract_data_name{1,dmri_pos(1,vr)},' ['))
    %     else
    %         title(tract_data_name{1,dmri_pos(1,vr)})
    %     end
        set(gca,'Linewidth',2,'FontSize',14,'YTick',1:ymax,'YTickLabel',tract_labels)
        ytickangle(45)

        print(fullfile(save_path,[basename num2str(vr) '-forest-plot']),'-dpng','-r300')
        pause(0.15)
        close(h(vr).fig)
        pause(0.1)
        disp(num2str(vr))
    end
end


function tract = build_tractography_measurements(table_folder,basename,tract_name,protocol,tract_voxel_ratio)
        tract.name = tract_name;
        if tract_voxel_ratio == 4
                dsi_basename = 'dsistudio';
        else
                dsi_basename = ['dsistudio-tract_voxel_ratio-' num2str(tract_voxel_ratio)];
        end
        for ind = 1:size(basename,1)
                t = tdfread(fullfile(table_folder,[basename{ind,1} '_' dsi_basename '_' tract_name '.tsv']));
                tract.SUBID(:,ind) = cellstr(t.SUBID);
                tract.number_of_tracts(:,ind) = t.number_of_tracts;
                tract.mean_length_mm(:,ind) = t.mean_length_mm;
                tract.span_mm(:,ind) = t.span_mm;
                tract.curl(:,ind) = t.curl;
                tract.elongation(:,ind) = t.elongation;
                tract.diameter_mm(:,ind) = t.diameter_mm;
                tract.volume_mm3(:,ind) = t.volume_mm3;
                tract.trunk_volume_mm3(:,ind) = t.trunk_volume_mm3;
                tract.branch_volume_mm3(:,ind) = t.branch_volume_mm3;
                tract.total_surface_area_mm2(:,ind) = t.total_surface_area_mm2;
                tract.total_radius_of_end_regions_mm(:,ind) = t.total_radius_of_end_regions_mm;
                tract.total_area_of_end_regions_mm2(:,ind) = t.total_area_of_end_regions_mm2;
                tract.irregularity(:,ind) = t.irregularity;
                tract.area_of_end_region_1_mm2(:,ind) = t.area_of_end_region_1_mm2;
                tract.radius_of_end_region_1_mm(:,ind) = t.radius_of_end_region_1_mm;
                tract.irregularity_of_end_region_1(:,ind) = t.irregularity_of_end_region_1;
                tract.area_of_end_region_2_mm2(:,ind) = t.area_of_end_region_2_mm2;
                tract.radius_of_end_region_2_mm(:,ind) = t.radius_of_end_region_2_mm;
                tract.irregularity_of_end_region_2(:,ind) = t.irregularity_of_end_region_2;
                tract.qa(:,ind) = t.qa;
                tract.FA(:,ind) = t.FA;
                tract.fsum(:,ind) = t.fsum;
                tract.AD(:,ind) = t.AD*1000;
                tract.MD(:,ind) = t.MD*1000;
                tract.RD(:,ind) = t.RD*1000;
                tract.d(:,ind) = t.d*1000;
                tract.kappa(:,ind) = t.kappa;
                tract.ficvf(:,ind) = t.ficvf;
                tract.fiso(:,ind) = t.fiso;
                tract.odi(:,ind) = t.odi;
        end
        tract.protocol = protocol';
end

function [tractometry, data, data_name] = merge_tractography_measurements(tract,keyword)
        tractometry.name = keyword;
        pos = contains({tract.name}',keyword);
        pos_1st = find(pos==1,1);
        subid = tract(pos_1st,1).SUBID; tractometry.SUBID = subid;
        
        x = size(subid,1); y = size(subid,2); z = sum(pos);
        
        vol = [tract(pos,1).volume_mm3];vol = reshape(vol,x,y,z);
        tractometry.volume_mm3 = sum(vol,3);
        data(1,1,:,:) = tractometry.volume_mm3';
        
        tractometry.number_of_tracts = merge_tract_values([tract(pos,1).number_of_tracts],x,y,z,vol,tractometry.volume_mm3,'sum'); data(2,1,:,:) = tractometry.number_of_tracts';
        tractometry.mean_length_mm = merge_tract_values([tract(pos,1).mean_length_mm],x,y,z,vol,tractometry.volume_mm3,'weighted-average'); data(3,1,:,:) = tractometry.mean_length_mm';
        tractometry.span_mm = merge_tract_values([tract(pos,1).span_mm],x,y,z,vol,tractometry.volume_mm3,'weighted-average'); data(4,1,:,:) = tractometry.span_mm';
        tractometry.curl = merge_tract_values([tract(pos,1).curl],x,y,z,vol,tractometry.volume_mm3,'weighted-average'); data(5,1,:,:) = tractometry.curl';
        tractometry.elongation = merge_tract_values([tract(pos,1).elongation],x,y,z,vol,tractometry.volume_mm3,'weighted-average'); data(6,1,:,:) = tractometry.elongation';
        tractometry.diameter_mm = merge_tract_values([tract(pos,1).diameter_mm],x,y,z,vol,tractometry.volume_mm3,'weighted-average'); data(7,1,:,:) = tractometry.diameter_mm';
        tractometry.trunk_volume_mm3 = merge_tract_values([tract(pos,1).trunk_volume_mm3],x,y,z,vol,tractometry.volume_mm3,'sum'); data(8,1,:,:) = tractometry.trunk_volume_mm3';
        tractometry.branch_volume_mm3 = merge_tract_values([tract(pos,1).branch_volume_mm3],x,y,z,vol,tractometry.volume_mm3,'sum'); data(9,1,:,:) = tractometry.branch_volume_mm3';
        tractometry.total_surface_area_mm2 = merge_tract_values([tract(pos,1).total_surface_area_mm2],x,y,z,vol,tractometry.volume_mm3,'sum'); data(10,1,:,:) = tractometry.total_surface_area_mm2';
        tractometry.total_radius_of_end_regions_mm = merge_tract_values([tract(pos,1).total_radius_of_end_regions_mm],x,y,z,vol,tractometry.volume_mm3,'weighted-average'); data(11,1,:,:) = tractometry.total_radius_of_end_regions_mm';
        tractometry.total_area_of_end_regions_mm2 = merge_tract_values([tract(pos,1).total_area_of_end_regions_mm2],x,y,z,vol,tractometry.volume_mm3,'sum'); data(12,1,:,:) = tractometry.total_area_of_end_regions_mm2';
        tractometry.irregularity = merge_tract_values([tract(pos,1).irregularity],x,y,z,vol,tractometry.volume_mm3,'weighted-average'); data(13,1,:,:) = tractometry.irregularity';
        tractometry.area_of_end_region_1_mm2 = merge_tract_values([tract(pos,1).area_of_end_region_1_mm2],x,y,z,vol,tractometry.volume_mm3,'sum'); data(14,1,:,:) = tractometry.area_of_end_region_1_mm2';
        tractometry.radius_of_end_region_1_mm = merge_tract_values([tract(pos,1).radius_of_end_region_1_mm],x,y,z,vol,tractometry.volume_mm3,'weighted-average'); data(15,1,:,:) = tractometry.radius_of_end_region_1_mm';
        tractometry.irregularity_of_end_region_1 = merge_tract_values([tract(pos,1).irregularity_of_end_region_1],x,y,z,vol,tractometry.volume_mm3,'weighted-average'); data(16,1,:,:) = tractometry.irregularity_of_end_region_1';
        tractometry.area_of_end_region_2_mm2 = merge_tract_values([tract(pos,1).area_of_end_region_2_mm2],x,y,z,vol,tractometry.volume_mm3,'sum'); data(17,1,:,:) = tractometry.area_of_end_region_2_mm2';
        tractometry.radius_of_end_region_2_mm = merge_tract_values([tract(pos,1).radius_of_end_region_2_mm],x,y,z,vol,tractometry.volume_mm3,'weighted-average'); data(18,1,:,:) = tractometry.radius_of_end_region_2_mm';
        tractometry.irregularity_of_end_region_2 = merge_tract_values([tract(pos,1).irregularity_of_end_region_2],x,y,z,vol,tractometry.volume_mm3,'weighted-average'); data(19,1,:,:) = tractometry.irregularity_of_end_region_2';
        tractometry.qa = merge_tract_values([tract(pos,1).qa],x,y,z,vol,tractometry.volume_mm3,'weighted-average'); data(20,1,:,:) = tractometry.qa';
        tractometry.FA = merge_tract_values([tract(pos,1).FA],x,y,z,vol,tractometry.volume_mm3,'weighted-average'); data(21,1,:,:) = tractometry.FA';
        tractometry.fsum = merge_tract_values([tract(pos,1).fsum],x,y,z,vol,tractometry.volume_mm3,'weighted-average'); data(22,1,:,:) = tractometry.fsum';
        tractometry.AD = merge_tract_values([tract(pos,1).AD],x,y,z,vol,tractometry.volume_mm3,'weighted-average'); data(23,1,:,:) = tractometry.AD';
        tractometry.MD = merge_tract_values([tract(pos,1).MD],x,y,z,vol,tractometry.volume_mm3,'weighted-average'); data(24,1,:,:) = tractometry.MD';
        tractometry.RD = merge_tract_values([tract(pos,1).RD],x,y,z,vol,tractometry.volume_mm3,'weighted-average'); data(25,1,:,:) = tractometry.RD';
        tractometry.d = merge_tract_values([tract(pos,1).d],x,y,z,vol,tractometry.volume_mm3,'weighted-average'); data(26,1,:,:) = tractometry.d';
        tractometry.kappa = merge_tract_values([tract(pos,1).kappa],x,y,z,vol,tractometry.volume_mm3,'weighted-average'); data(27,1,:,:) = tractometry.kappa';
        tractometry.ficvf = merge_tract_values([tract(pos,1).ficvf],x,y,z,vol,tractometry.volume_mm3,'weighted-average'); data(28,1,:,:) = tractometry.ficvf';
        tractometry.fiso = merge_tract_values([tract(pos,1).fiso],x,y,z,vol,tractometry.volume_mm3,'weighted-average'); data(29,1,:,:) = tractometry.fiso';
        tractometry.odi = merge_tract_values([tract(pos,1).odi],x,y,z,vol,tractometry.volume_mm3,'weighted-average'); data(30,1,:,:) = tractometry.odi';
%         tractometry.fulldataFA = merge_tract_values([tract(pos,1).fulldataFA],x,y,z,vol,tractometry.volume_mm3,'weighted-average'); data(31,1,:,:) = tractometry.fulldataFA';
%         tractometry.fulldataAD = merge_tract_values([tract(pos,1).fulldataAD],x,y,z,vol,tractometry.volume_mm3,'weighted-average'); data(32,1,:,:) = tractometry.fulldataAD';
%         tractometry.fulldataMD = merge_tract_values([tract(pos,1).fulldataMD],x,y,z,vol,tractometry.volume_mm3,'weighted-average'); data(33,1,:,:) = tractometry.fulldataMD';
%         tractometry.fulldataRD = merge_tract_values([tract(pos,1).fulldataRD],x,y,z,vol,tractometry.volume_mm3,'weighted-average'); data(34,1,:,:) = tractometry.fulldataRD';
        
        data_name = fieldnames(tractometry)';
        data_name = data_name(1,3:end);
        
        tractometry.protocol = tract(pos_1st,1).protocol;
end

function measurement = merge_tract_values(tract_values,x,y,z,weight,weight_sum,how_merge)
        tract_values = reshape(tract_values,x,y,z);
        if strcmp(how_merge,'weighted-average')
                tract_values = weight .* tract_values ./ repmat(weight_sum,1,1,z);
        end
        measurement = sum(tract_values,3);
end

function tract_data_name = correct_tract_data_name(tract_data_name)
        for ind = 1:size(tract_data_name,2)
                if strcmp(tract_data_name{1,ind},'number_of_tracts')
                        tract_data_name{1,ind} = 'Number of streamlines';
                end
                if length(tract_data_name{1,ind})>2
                        if strcmp(tract_data_name{1,ind}(end-2:end),'mm3')
                                tract_data_name{1,ind}(end-2:end+3) = '[mm^3]';
                        elseif strcmp(tract_data_name{1,ind}(end-2:end),'mm2')
                                tract_data_name{1,ind}(end-2:end+3) = '[mm^2]';
                        elseif strcmp(tract_data_name{1,ind}(end-1:end),'mm')
                                        tract_data_name{1,ind}(end-1:end+2) = '[mm]';
                        end
                elseif length(tract_data_name{1,ind})>1 
                        if strcmp(tract_data_name{1,ind}(end-1:end),'mm')
                                        tract_data_name{1,ind}(end-1:end+2) = '[mm]';
                        end           
                end
                if ~strcmp(tract_data_name{1,ind},'fsum') && ~strcmp(tract_data_name{1,ind},'ficvf') && ~strcmp(tract_data_name{1,ind},'fiso') && ~strcmp(tract_data_name{1,ind},'odi') && ~strcmp(tract_data_name{1,ind},'kappa') && ~strcmp(tract_data_name{1,ind},'d') && ~strcmp(tract_data_name{1,ind},'qa')
                                tract_data_name{1,ind}(1) = upper(tract_data_name{1,ind}(1));
                end
                if strcmp(tract_data_name{1,ind},'ficvf')
                        tract_data_name{1,ind} = 'Neurite density index';
                elseif strcmp(tract_data_name{1,ind},'odi')
                        tract_data_name{1,ind} = 'Orientation dispersion index';
                elseif strcmp(tract_data_name{1,ind},'kappa')
                        tract_data_name{1,ind} = 'NODDI kappa';
                elseif strcmp(tract_data_name{1,ind},'d')
                        tract_data_name{1,ind} = [tract_data_name{1,ind} ' [*10^{-9}m^2/s]'];
                elseif strcmp(tract_data_name{1,ind},'AD')
                        tract_data_name{1,ind} = 'Axial diffusivity [*10^{-9}m^2/s]';
                elseif strcmp(tract_data_name{1,ind},'MD')
                        tract_data_name{1,ind} = 'Mean diffusivity [*10^{-9}m^2/s]';
                elseif strcmp(tract_data_name{1,ind},'RD')
                        tract_data_name{1,ind} = 'Radial diffusivity [*10^{-9}m^2/s]';
                elseif strcmp(tract_data_name{1,ind},'FA')
                        tract_data_name{1,ind} = 'Fractional anisotropy';
                end
                tract_data_name{1,ind}(tract_data_name{1,ind}=='_') = ' ';    
        end
end

function tract = concatenate_tract_results(tract,tract2)
    for trid = 1:size(tract,1)
            tract(trid,1).SUBID = [tract(trid,1).SUBID; tract2(trid,1).SUBID];
            tract(trid,1).number_of_tracts = [tract(trid,1).number_of_tracts; tract2(trid,1).number_of_tracts];
            tract(trid,1).mean_length_mm = [tract(trid,1).mean_length_mm; tract2(trid,1).mean_length_mm];
            tract(trid,1).span_mm = [tract(trid,1).span_mm; tract2(trid,1).span_mm];
            tract(trid,1).curl = [tract(trid,1).curl; tract2(trid,1).curl];
            tract(trid,1).elongation = [tract(trid,1).elongation; tract2(trid,1).elongation];
            tract(trid,1).diameter_mm = [tract(trid,1).diameter_mm; tract2(trid,1).diameter_mm];
            tract(trid,1).volume_mm3 = [tract(trid,1).volume_mm3; tract2(trid,1).volume_mm3];
            tract(trid,1).trunk_volume_mm3 = [tract(trid,1).trunk_volume_mm3; tract2(trid,1).trunk_volume_mm3];
            tract(trid,1).branch_volume_mm3 = [tract(trid,1).branch_volume_mm3; tract2(trid,1).branch_volume_mm3];
            tract(trid,1).total_surface_area_mm2 = [tract(trid,1).total_surface_area_mm2; tract2(trid,1).total_surface_area_mm2];
            tract(trid,1).total_radius_of_end_regions_mm = [tract(trid,1).total_radius_of_end_regions_mm; tract2(trid,1).total_radius_of_end_regions_mm];
            tract(trid,1).total_area_of_end_regions_mm2 = [tract(trid,1).total_area_of_end_regions_mm2; tract2(trid,1).total_area_of_end_regions_mm2];
            tract(trid,1).irregularity = [tract(trid,1).irregularity; tract2(trid,1).irregularity];
            tract(trid,1).area_of_end_region_1_mm2 = [tract(trid,1).area_of_end_region_1_mm2; tract2(trid,1).area_of_end_region_1_mm2];
            tract(trid,1).radius_of_end_region_1_mm = [tract(trid,1).radius_of_end_region_1_mm; tract2(trid,1).radius_of_end_region_1_mm];
            tract(trid,1).irregularity_of_end_region_1 = [tract(trid,1).irregularity_of_end_region_1; tract2(trid,1).irregularity_of_end_region_1];
            tract(trid,1).area_of_end_region_2_mm2 = [tract(trid,1).area_of_end_region_2_mm2; tract2(trid,1).area_of_end_region_2_mm2];
            tract(trid,1).radius_of_end_region_2_mm = [tract(trid,1).radius_of_end_region_2_mm; tract2(trid,1).radius_of_end_region_2_mm];
            tract(trid,1).irregularity_of_end_region_2 = [tract(trid,1).irregularity_of_end_region_2; tract2(trid,1).irregularity_of_end_region_2];
            tract(trid,1).qa = [tract(trid,1).qa; tract2(trid,1).qa];
            tract(trid,1).FA = [tract(trid,1).FA; tract2(trid,1).FA];
            tract(trid,1).fsum = [tract(trid,1).fsum; tract2(trid,1).fsum];
            tract(trid,1).AD = [tract(trid,1).AD; tract2(trid,1).AD];
            tract(trid,1).MD = [tract(trid,1).MD; tract2(trid,1).MD];
            tract(trid,1).RD = [tract(trid,1).RD; tract2(trid,1).RD];
            tract(trid,1).d = [tract(trid,1).d; tract2(trid,1).d];
            tract(trid,1).kappa = [tract(trid,1).kappa; tract2(trid,1).kappa];
            tract(trid,1).ficvf = [tract(trid,1).ficvf; tract2(trid,1).ficvf];
            tract(trid,1).fiso = [tract(trid,1).fiso; tract2(trid,1).fiso];
            tract(trid,1).odi = [tract(trid,1).odi; tract2(trid,1).odi];
    end
end