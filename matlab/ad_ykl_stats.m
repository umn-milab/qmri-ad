%% Initiate
clear all;
clc;
close all;

% Outcome variables: amyloid-beta 42/40; amyloid-beta 40; amyloid-beta 42
% Independent variables: YKL-40, age, sex
% 
% Hypothesis: YKL-40, a marker of systemic inflammation, will cause lower amyloid beta 42/40, lower amyloid beta 42 and higher amyloid-beta 40.
% 
% Could you also run an analysis with the following:
% Outcome variable: YKL-40
% Independent variables: Age, sex, education, homelessness, HbA1c, chronic kidney disease (yes/no), ischemic heart disease, stroke?
% 
% Hypothesis: Homelessness will be the #1 factor in raising systemic inflammation, as measured by YKL-40.

data_folder='/home/range1-raid1/labounek/data-on-porto';
project_folder=fullfile(data_folder,'ADAI');
table_folder=fullfile(project_folder,'tables');

include_bmi = 1; % values: 0 1 2

% xls_file = fullfile(project_folder,'HeartDataset','MasterDataset_May12-Rene-version.xlsx');
% xls_file = fullfile(project_folder,'HeartDataset','MasterDataset_June14.xlsx');
% xls_file = fullfile(project_folder,'HeartDataset','MasterDataset_September11.xlsx');
% xls_file = fullfile(project_folder,'HeartDataset','MasterDataset_Oct21.xlsx');
% xls_file = fullfile(project_folder,'HeartDataset','MasterDataset_Oct23.xlsx');
% xls_file = fullfile(project_folder,'HeartDataset','MasterDataset_December3.xlsx'); % Last used for the YKL analysis
% xls_file = fullfile(project_folder,'HeartDataset','MasterDataset_01-13.xlsx');
xls_file = fullfile(project_folder,'HeartDataset','MasterDataset_03-30.xlsx');
 
[~, ~, raw] = xlsread(xls_file);
raw(strcmp(raw,'Male ')) = {'Male'};
raw(strcmp(raw,'Female ')) = {'Female'};
% raw{1,strcmp(raw(1,:),'Please describe alcohol habits (what kind, how much, how often).')} = 'Alcohol habits';
[a,b]=find(strcmp(raw,'NA')==1);
for ind = 1:size(a,1)
    raw{a(ind,1),b(ind,1)} = NaN;
end

adai_gfr = zeros(size(raw,1)-1,1);
for ind = 2:size(raw,1)
    tmp = raw{ind,strcmp(raw(1,:),'GFR')};
    if strcmp(tmp,'>90')
        adai_gfr(ind-1,1) = 95;
    else
        adai_gfr(ind-1,1) = tmp;
    end
end

adai_ckd = cell(0,0);
for ind = 1:size(adai_gfr,1)
    if adai_gfr(ind,1) < 60
        adai_ckd{ind,1} = 'Yes';
    elseif adai_gfr(ind,1) >= 60
        adai_ckd{ind,1} = 'No';
    else
        adai_ckd{ind,1} = '';
    end
end

adai_ancestry = cell(size(raw,1),1);
for ind = 2:size(raw,1)
    tmp = raw{ind,strcmp(raw(1,:),'Ancestry (% Native)')};
    if strcmp(tmp,'>25')
        adai_ancestry{ind,1} = 37.5;
    elseif strcmp(tmp,'>50')
        adai_ancestry{ind,1} = 62.5;
    elseif strcmp(tmp,'>75')
        adai_ancestry{ind,1} = 87.5;
    elseif strcmp(tmp,'>90')
        adai_ancestry{ind,1} = 95;
    else
        adai_ancestry{ind,1} = tmp;
    end
end
adai_ancestry=adai_ancestry(2:end,1);

adai_homeless = cell(0,0);
for ind = 2:size(raw,1)
    if ~isnan(raw{ind,strcmp(raw(1,:),'Homeless')})
        adai_homeless{ind,1} = raw{ind,strcmp(raw(1,:),'Homeless')};
    else
        adai_homeless{ind,1} = '';
    end
end
adai_homeless = adai_homeless(2:end,1);


adai_statin = cell(0,0);
adai_statin_type = cell(0,0);
adai_statin_type2 = cell(0,0);
adai_statin_type3 = cell(0,0);
for ind = 2:size(raw,1)
    if ~isnan(raw{ind,strcmp(raw(1,:),'On Statin')})
        adai_statin{ind,1} = raw{ind,strcmp(raw(1,:),'On Statin')};
        if strcmp(adai_statin{ind,1},'yes')
            adai_statin{ind,1} = 'Yes';
        elseif strcmp(adai_statin{ind,1},'no')
            adai_statin{ind,1} = 'No';
        end
        if strcmp(adai_statin{ind,1},'Yes')
            adai_statin_type{ind,1} = raw{ind,strcmp(raw(1,:),'Statin Category (Lipophilic, hydrophilic, unknown)')};
            adai_statin_type2{ind,1} = raw{ind,strcmp(raw(1,:),'Statin Category (Lipophilic, hydrophilic, unknown)')};
        elseif strcmp(adai_statin{ind,1},'No')
            adai_statin_type{ind,1} = 'No';
            adai_statin_type2{ind,1} = 'No';
            adai_statin_type3{ind,1} = 0;
        end
        if strcmp(adai_statin_type2{ind,1},'Unknown') || strcmp(adai_statin_type2{ind,1},'Hydrophilic')
            adai_statin_type2{ind,1} = 'Non-Lipophilic';
            adai_statin_type3{ind,1} = 1;
        elseif strcmp(adai_statin_type2{ind,1},'Lipophilic')
            adai_statin_type3{ind,1} = 2;
        end
    else
        adai_statin{ind,1} = '';
        adai_statin_type{ind,1} = '';
        adai_statin_type2{ind,1} = '';
    end
end
adai_statin = adai_statin(2:end,1);
adai_statin_type = adai_statin_type(2:end,1);
adai_statin_type2 = adai_statin_type2(2:end,1);
adai_statin_type3 = adai_statin_type3(2:end,1);

adai_statin_type3 = categorical(cell2mat(adai_statin_type3));

adai_tobacco = cell(0,0);
for ind = 2:size(raw,1)
    if ~isnan(raw{ind,strcmp(raw(1,:),'Tobacco use ')})
        adai_tobacco{ind,1} = raw{ind,strcmp(raw(1,:),'Tobacco use ')};
        if strcmp(adai_tobacco{ind,1},'yes')
            adai_tobacco{ind,1} = 'Yes';
        elseif strcmp(adai_tobacco{ind,1},'no')
            adai_tobacco{ind,1} = 'No';
        end
    else
        adai_tobacco{ind,1} = '';
    end
end
adai_tobacco = adai_tobacco(2:end,1);

adai_alcohol = cell(0,0);
for ind = 2:size(raw,1)
    if ~isnan(raw{ind,strcmp(raw(1,:),'EtOH use')})
        adai_alcohol{ind,1} = raw{ind,strcmp(raw(1,:),'EtOH use')};
        if strcmp(adai_alcohol{ind,1},'yes')
            adai_alcohol{ind,1} = 'Yes';
        elseif strcmp(adai_alcohol{ind,1},'no')
            adai_alcohol{ind,1} = 'No';
        end
    else
        adai_alcohol{ind,1} = '';
    end
end
adai_alcohol = adai_alcohol(2:end,1);

adai_headtrauma = cell(0,0);
for ind = 2:size(raw,1)
    if ~isnan(raw{ind,strcmp(raw(1,:),'Head Trauma')})
        adai_headtrauma{ind,1} = raw{ind,strcmp(raw(1,:),'Head Trauma')};
        if strcmp(adai_headtrauma{ind,1},'yes')
            adai_headtrauma{ind,1} = 'Yes';
        elseif strcmp(adai_headtrauma{ind,1},'no')
            adai_headtrauma{ind,1} = 'No';
        end
    else
        adai_headtrauma{ind,1} = '';
    end
end
adai_headtrauma = adai_headtrauma(2:end,1);

adai_sedatingmed = cell(0,0);
for ind = 2:size(raw,1)
    if ~isnan(raw{ind,strcmp(raw(1,:),'Sedating medication use?')})
        adai_sedatingmed{ind,1} = raw{ind,strcmp(raw(1,:),'Sedating medication use?')};
        if strcmp(adai_sedatingmed{ind,1},'yes')
            adai_sedatingmed{ind,1} = 'Yes';
        elseif strcmp(adai_sedatingmed{ind,1},'no')
            adai_sedatingmed{ind,1} = 'No';
        end
    else
        adai_sedatingmed{ind,1} = '';
    end
end
adai_sedatingmed = adai_sedatingmed(2:end,1);

adai_psychotropicmed = cell(0,0);
for ind = 2:size(raw,1)
    if ~isnan(raw{ind,strcmp(raw(1,:),'Psychotropic medication use? ')})
        adai_psychotropicmed{ind,1} = raw{ind,strcmp(raw(1,:),'Psychotropic medication use? ')};
        if strcmp(adai_psychotropicmed{ind,1},'yes')
            adai_psychotropicmed{ind,1} = 'Yes';
        elseif strcmp(adai_psychotropicmed{ind,1},'no')
            adai_psychotropicmed{ind,1} = 'No';
        end
    else
        adai_psychotropicmed{ind,1} = '';
    end
end
adai_psychotropicmed = adai_psychotropicmed(2:end,1);

adai_SedPsychSubsMed = cell(0,0); % Missing Substance use
for ind = 1:size(adai_sedatingmed,1)   
    if strcmp(adai_sedatingmed{ind,1},'Yes') || strcmp(adai_psychotropicmed{ind,1},'Yes')
        adai_SedPsychSubsMed{ind,1} = 'Yes';
    elseif strcmp(adai_sedatingmed{ind,1},'No') && strcmp(adai_psychotropicmed{ind,1},'No')
        adai_SedPsychSubsMed{ind,1} = 'No';
    else
        adai_SedPsychSubsMed{ind,1} = '';
    end        
end

adai_osa = cell(0,0);
for ind = 2:size(raw,1)
    if ~isnan(raw{ind,strcmp(raw(1,:),'Diagnosis of OSA? ')})
        adai_osa{ind,1} = raw{ind,strcmp(raw(1,:),'Diagnosis of OSA? ')};
        if strcmp(adai_osa{ind,1},'yes')
            adai_osa{ind,1} = 'Yes';
        elseif strcmp(adai_osa{ind,1},'no')
            adai_osa{ind,1} = 'No';
        end
    else
        adai_osa{ind,1} = '';
    end
end
adai_osa = adai_osa(2:end,1);

adai_anxiety = cell(0,0);
for ind = 2:size(raw,1)
    if ~isnan(raw{ind,strcmp(raw(1,:),'Self-reported mood changes (increased depression or anxiety)')})
        adai_anxiety{ind,1} = raw{ind,strcmp(raw(1,:),'Self-reported mood changes (increased depression or anxiety)')};
        if strcmp(adai_anxiety{ind,1},'yes')
            adai_anxiety{ind,1} = 'Yes';
        elseif strcmp(adai_anxiety{ind,1},'no')
            adai_anxiety{ind,1} = 'No';
        end
    else
        adai_anxiety{ind,1} = '';
    end
end
adai_anxiety = adai_anxiety(2:end,1);

adai_impairment = cell(0,0);
for ind = 2:size(raw,1)
    if ~isnan(raw{ind,strcmp(raw(1,:),'Level of impairment')})
        adai_impairment{ind,1} = raw{ind,strcmp(raw(1,:),'Level of impairment')};
    else
        adai_impairment{ind,1} = '';
    end
end
adai_impairment = adai_impairment(2:end,1);

adai_noimpairment = cell(size(adai_impairment));
adai_smci = cell(size(adai_impairment));
adai_ad = cell(size(adai_impairment));

for ind = 1:size(adai_impairment,1)
    if strcmp(adai_impairment{ind,1},'No impairment')
        adai_noimpairment{ind,1} = 'Yes';
        adai_smci{ind,1} = 'No';
        adai_ad{ind,1} = 'No';
    elseif strcmp(adai_impairment{ind,1},'Mild Cognitive Impairment') || strcmp(adai_impairment{ind,1},'Subjective Cognitive Impairment')
        adai_noimpairment{ind,1} = 'No';
        adai_smci{ind,1} = 'Yes';
        adai_ad{ind,1} = 'No';
    elseif strcmp(adai_impairment{ind,1},'Dementia')
        adai_noimpairment{ind,1} = 'No';
        adai_smci{ind,1} = 'No';
        adai_ad{ind,1} = 'Yes';
    end
end

adai_insomnia = cell(0,0);
for ind = 2:size(raw,1)
    if ~isnan(raw{ind,strcmp(raw(1,:),'Insomnia? ')})
        adai_insomnia{ind,1} = raw{ind,strcmp(raw(1,:),'Insomnia? ')};
    else
        adai_insomnia{ind,1} = '';
    end
end
adai_insomnia = adai_insomnia(2:end,1);


adai_ihd = strcmp(raw(2:end,strcmp(raw(1,:),'Heart Issues')),'Yes') &  ( strcmp(raw(2:end,strcmp(raw(1,:),'Ischemic vs non-ischemic heart disease ')),'Ischemic ') | strcmp(raw(2:end,strcmp(raw(1,:),'Ischemic vs non-ischemic heart disease ')),'Ischemic') );
adai_ihd_class = cell(size(adai_ihd));
for ind = 1:size(adai_ihd,1)
    if adai_ihd(ind,1) == 1
        adai_ihd_class{ind,1} = 'Yes';
    else
        adai_ihd_class{ind,1} = 'No';
    end
end

adai_nonihd = strcmp(raw(2:end,strcmp(raw(1,:),'Heart Issues')),'Yes') &  ( strcmp(raw(2:end,strcmp(raw(1,:),'Ischemic vs non-ischemic heart disease ')),'Non-ischemic') | strcmp(raw(2:end,strcmp(raw(1,:),'Ischemic vs non-ischemic heart disease ')),'NOS') );
adai_nonihd_class = cell(size(adai_nonihd));
for ind = 1:size(adai_nonihd,1)
    if adai_nonihd(ind,1) == 1
        adai_nonihd_class{ind,1} = 'Yes';
    else
        adai_nonihd_class{ind,1} = 'No';
    end
end


adai_ldl = raw(2:end,strcmp(raw(1,:),'LDL'));
for ind = 1:size(adai_ldl,1)
    if strcmp(adai_ldl{ind,1},'< 1')
        adai_ldl{ind,1} = 0.99;
    end
end

adai_apoeprotein = zeros(size(raw,1)-1,1);
for ind = 2:size(raw,1)
    tmp = raw{ind,strcmp(raw(1,:),'ApoE Results (Pg/mL)')};
    if strcmp(tmp,'>31476')
        adai_apoeprotein(ind-1,1) = 31500;
    else
        adai_apoeprotein(ind-1,1) = tmp;
    end
end

adai_epworth = NaN*ones(size(raw,1)-1,1);
for ind = 2:size(raw,1)
    tmp = raw{ind,strcmp(raw(1,:),'Epworth')};
    if strcmp(tmp,'#REF!')
        adai_apoeprotein(ind-1,1) = NaN;
    else
        adai_apoeprotein(ind-1,1) = tmp;
    end
end

data_names = {'pTau217', 'Age', 'Sex', 'APOE4', 'Abeta42', 'Abeta40',...
    'Height', 'Weight', 'BMI', 'HbA1C', 'HDL', 'LDL', 'Triglycerides', 'AST', 'ALT', 'HeadTrauma', 'HTN', 'HLD', 'IHD', 'Non-IHD', 'Stroke', 'CKD', 'GFR', ...
    'pTau181', 'GFAP', 'NfL', 'MMSE', 'Ancestry', 'Homeless', 'Education',...
    'YKL-40', 'APOE2', 'APOE3', 'APOEprotein', 'Statin', 'Statin-type', 'Tobacco', 'Alcohol', 'Albumin', 'Epworth', 'Stop-Bang', ...
    'SedPsychSubsMed', 'SedatingMed', 'Anxiety', 'OSA', 'Insomnia', ...
    'Impairment'};

adai_sub = raw(2:end,strcmp(raw(1,:),'PIDN'));
adai = [
    raw(2:end,strcmp(raw(1,:),'pTau 217')), ...
    raw(2:end,strcmp(raw(1,:),'Age ')), ...
    raw(2:end,strcmp(raw(1,:),'Sex')), ...
    raw(2:end,strcmp(raw(1,:),'APOE e4 mutations')), ...
    raw(2:end,strcmp(raw(1,:),'Abeta 42')), ...
    raw(2:end,strcmp(raw(1,:),'Abeta 40')), ...
    raw(2:end,strcmp(raw(1,:),'Participant height (cm)')), ...
    raw(2:end,strcmp(raw(1,:),'Participant weight (kg) ')), ...
    raw(2:end,strcmp(raw(1,:),'BMI')), ...
    raw(2:end,strcmp(raw(1,:),'HbA1C')), ...
    raw(2:end,strcmp(raw(1,:),'HDL')), ...
    adai_ldl, ...
    raw(2:end,strcmp(raw(1,:),'Triglycerides')), ...
    raw(2:end,strcmp(raw(1,:),'AST')), ...
    raw(2:end,strcmp(raw(1,:),'ALT')), ...
    adai_headtrauma, ...
    raw(2:end,strcmp(raw(1,:),'HTN ')), ...
    raw(2:end,strcmp(raw(1,:),'HLD')), ...
    adai_ihd_class, ...
    adai_nonihd_class, ...
    raw(2:end,strcmp(raw(1,:),'Stroke Hx')), ...
    adai_ckd, ...
    num2cell(adai_gfr), ...
    raw(2:end,strcmp(raw(1,:),'pTau 181')), ...
    raw(2:end,strcmp(raw(1,:),'GFAP')), ...
    raw(2:end,strcmp(raw(1,:),'NF-light')), ...
    raw(2:end,strcmp(raw(1,:),'MMSE')), ...
    adai_ancestry, ...
    adai_homeless, ...
    raw(2:end,strcmp(raw(1,:),'Years of formal schooling')), ...
    raw(2:end,strcmp(raw(1,:),'CHI3L1 Results')), ...
    raw(2:end,strcmp(raw(1,:),'APOE e2 mutations')), ...
    raw(2:end,strcmp(raw(1,:),'APOE e3 mutations')), ...
    num2cell(adai_apoeprotein), ...
    adai_statin, ...
    adai_statin_type, ...
    adai_tobacco, ...
    adai_alcohol, ...
    raw(2:end,strcmp(raw(1,:),'Albumin')), ...
    num2cell(adai_epworth), ...
    raw(2:end,strcmp(raw(1,:),'Stop-Bang')), ...
    adai_SedPsychSubsMed, ...
    adai_sedatingmed, ...
    adai_osa, ...
    adai_anxiety, ...
    adai_insomnia, ...
    adai_impairment ...
    ];

%% Fix dataset typos
for ind = find(strcmp(adai(:,strcmp(data_names,'HTN')),'No ')==1)
    adai{ind,strcmp(data_names,'HTN')} = 'No';
end

for ind = find(strcmp(adai(:,strcmp(data_names,'Alcohol')),'Yes ')==1)
    adai{ind,strcmp(data_names,'Alcohol')} = 'Yes';
end
%% Estimate Abeta_42/40
adai_abeta4240ratio = cell2mat(adai(:,strcmp(data_names,'Abeta42'))) ./ cell2mat(adai(:,strcmp(data_names,'Abeta40')));

%% Define APOE genotype
adai_apoe_genotype = NaN*ones(size(adai,1),1);
adai_apoe_genotype(cell2mat(adai(:,strcmp(data_names,'APOE2')))==2,1) = 1;
adai_apoe_genotype( cell2mat(adai(:,strcmp(data_names,'APOE2')))==1 & cell2mat(adai(:,strcmp(data_names,'APOE3')))==1 ,1) = 2;
adai_apoe_genotype( cell2mat(adai(:,strcmp(data_names,'APOE2')))==1 & cell2mat(adai(:,strcmp(data_names,'APOE4')))==1 ,1) = 3;
adai_apoe_genotype(cell2mat(adai(:,strcmp(data_names,'APOE3')))==2,1) = 4;
adai_apoe_genotype( cell2mat(adai(:,strcmp(data_names,'APOE3')))==1 & cell2mat(adai(:,strcmp(data_names,'APOE4')))==1 ,1) = 5;
adai_apoe_genotype(cell2mat(adai(:,strcmp(data_names,'APOE4')))==2,1) = 6;
%% Define APOE4 carrier
adai_apoe4_carrier = NaN*ones(size(adai,1),1);
adai_apoe4_carrier( cell2mat(adai(:,strcmp(data_names,'APOE4')))==0 , 1) = 0;
adai_apoe4_carrier( cell2mat(adai(:,strcmp(data_names,'APOE4')))>=1 , 1) = 1;
%% Linear mixture models

pos_data = ~isnan(adai_abeta4240ratio);
pos_apoeprotein = ~isnan(adai_apoeprotein);
pos_ptau217 = ~isnan(cell2mat(adai(:,strcmp(data_names,'pTau217')))) & cell2mat(adai(:,strcmp(data_names,'Triglycerides')))<400 & ~isnan(cell2mat(adai(:,strcmp(data_names,'APOE4')))) & ~isnan(cell2mat(adai(:,strcmp(data_names,'GFR')))) & ~isnan(cell2mat(adai(:,strcmp(data_names,'HbA1C')))) & ~isnan(cell2mat(adai(:,strcmp(data_names,'YKL-40')))) & ~cellfun(@isempty,adai(:,strcmp(data_names,'Alcohol')));
pos_gfap = ~isnan(cell2mat(adai(:,strcmp(data_names,'GFAP'))));
pos_abeta4240 = pos_data;

tbl_abeta4240 = table( log(adai_abeta4240ratio(pos_data,1)), ...
    log(cell2mat(adai(pos_data,strcmp(data_names,'YKL-40')))), ...
    cell2mat(adai(pos_data,strcmp(data_names,'Age')))/10, ...
    adai(pos_data,strcmp(data_names,'Sex')) , ...
    'VariableNames', {'Abeta42/40','YKL-40','Age','Sex'} );
tbl_abeta4240.Sex = categorical(tbl_abeta4240.Sex);

tbl_abeta42 = table( log(cell2mat(adai(pos_data,strcmp(data_names,'Abeta42')))), ...
    log(cell2mat(adai(pos_data,strcmp(data_names,'YKL-40')))), ...
    cell2mat(adai(pos_data,strcmp(data_names,'Age')))/10, ...
    adai(pos_data,strcmp(data_names,'Sex')) , ...
    'VariableNames', {'Abeta42','YKL-40','Age','Sex'} );
tbl_abeta42.Sex = categorical(tbl_abeta42.Sex);

tbl_abeta40 = table( log(cell2mat(adai(pos_data,strcmp(data_names,'Abeta40')))), ...
    log(cell2mat(adai(pos_data,strcmp(data_names,'YKL-40')))), ...
    cell2mat(adai(pos_data,strcmp(data_names,'Age')))/10, ...
    adai(pos_data,strcmp(data_names,'Sex')) , ...
    'VariableNames', {'Abeta40','YKL-40','Age','Sex'} );
tbl_abeta40.Sex = categorical(tbl_abeta40.Sex);

tbl_ykl40 = table( log(cell2mat(adai(pos_data,strcmp(data_names,'YKL-40')))), ...
    cell2mat(adai(pos_data,strcmp(data_names,'Age')))/10, ...
    adai(pos_data,strcmp(data_names,'Sex')), ...
    cell2mat(adai(pos_data,strcmp(data_names,'Education'))), ...
    adai(pos_data,strcmp(data_names,'Homeless')), ...
    cell2mat(adai(pos_data,strcmp(data_names,'HbA1C'))), ...
    adai(pos_data,strcmp(data_names,'CKD')), ...
    adai(pos_data,strcmp(data_names,'IHD')), ...
    adai(pos_data,strcmp(data_names,'Stroke')), ...
    'VariableNames', {'YKL-40','Age','Sex','Education','Homeless','HbA1C','CKD','IHD','Stroke'} );
tbl_ykl40.Sex = categorical(tbl_ykl40.Sex);
tbl_ykl40.Homeless = categorical(tbl_ykl40.Homeless);
tbl_ykl40.CKD = categorical(tbl_ykl40.CKD);
tbl_ykl40.IHD = categorical(tbl_ykl40.IHD);
tbl_ykl40.Stroke = categorical(tbl_ykl40.Stroke);

tbl_apoeprotein = table( log(cell2mat(adai(pos_apoeprotein,strcmp(data_names,'APOEprotein')))), ...
    adai_apoe_genotype(pos_apoeprotein,1), ...
    cell2mat(adai(pos_apoeprotein,strcmp(data_names,'Age')))/10, ...
    adai(pos_apoeprotein,strcmp(data_names,'Sex')), ...
    adai(pos_apoeprotein,strcmp(data_names,'Statin')), ...
    cell2mat(adai(pos_apoeprotein,strcmp(data_names,'HbA1C'))), ...
    adai(pos_apoeprotein,strcmp(data_names,'CKD')), ...
    adai(pos_apoeprotein,strcmp(data_names,'Tobacco')), ...
    adai(pos_apoeprotein,strcmp(data_names,'Alcohol')), ...
    'VariableNames', {'APOEprotein','APOEgenotype','Age','Sex','Statin','HbA1C','CKD','Tobacco','Alcohol'} );
tbl_apoeprotein.Sex = categorical(tbl_apoeprotein.Sex);
tbl_apoeprotein.Statin = categorical(tbl_apoeprotein.Statin);
tbl_apoeprotein.CKD = categorical(tbl_apoeprotein.CKD);
tbl_apoeprotein.Tobacco = categorical(tbl_apoeprotein.Tobacco);
tbl_apoeprotein.Alcohol = categorical(tbl_apoeprotein.Alcohol);

tbl_ptau217_carrier = table( log(cell2mat(adai(pos_ptau217,strcmp(data_names,'pTau217')))), ...
    cell2mat(adai(pos_ptau217,strcmp(data_names,'Age')))/10, ...
    adai(pos_ptau217,strcmp(data_names,'Sex')), ...
    adai_apoe4_carrier(pos_ptau217,1), ...
    log2(adai_abeta4240ratio(pos_ptau217,1)), ...
    adai(pos_ptau217,strcmp(data_names,'CKD')), ...
    cell2mat(adai(pos_ptau217,strcmp(data_names,'HbA1C'))), ...
    adai(pos_ptau217,strcmp(data_names,'IHD')), ...
    adai(pos_ptau217,strcmp(data_names,'Stroke')), ...
    log2(cell2mat(adai(pos_ptau217,strcmp(data_names,'Triglycerides')))), ...
    log2(cell2mat(adai(pos_ptau217,strcmp(data_names,'HDL')))), ...
    log2(cell2mat(adai(pos_ptau217,strcmp(data_names,'LDL')))), ...
    'VariableNames', {'pTau217','Age','Sex','APOE4','Abeta4240','CKD','HbA1C','IHD','Stroke','Triglycerides','HDL','LDL'} );
tbl_ptau217_carrier.Sex = categorical(tbl_ptau217_carrier.Sex);
tbl_ptau217_carrier.APOE4 = categorical(tbl_ptau217_carrier.APOE4);
tbl_ptau217_carrier.CKD = categorical(tbl_ptau217_carrier.CKD);
tbl_ptau217_carrier.IHD = categorical(tbl_ptau217_carrier.IHD);
tbl_ptau217_carrier.Stroke = categorical(tbl_ptau217_carrier.Stroke);

tbl_ptau217_allele = table( log(cell2mat(adai(pos_ptau217,strcmp(data_names,'pTau217')))), ...
    cell2mat(adai(pos_ptau217,strcmp(data_names,'Age')))/10, ...
    adai(pos_ptau217,strcmp(data_names,'Sex')), ...
    cell2mat(adai(pos_ptau217,strcmp(data_names,'APOE4'))), ...
    log2(adai_abeta4240ratio(pos_ptau217,1)), ...
    adai(pos_ptau217,strcmp(data_names,'CKD')), ...
    cell2mat(adai(pos_ptau217,strcmp(data_names,'HbA1C'))), ...
    adai(pos_ptau217,strcmp(data_names,'IHD')), ...
    adai(pos_ptau217,strcmp(data_names,'Stroke')), ...
    log2(cell2mat(adai(pos_ptau217,strcmp(data_names,'Triglycerides')))), ...
    log2(cell2mat(adai(pos_ptau217,strcmp(data_names,'HDL')))), ...
    log2(cell2mat(adai(pos_ptau217,strcmp(data_names,'LDL')))), ...
    'VariableNames', {'pTau217','Age','Sex','APOE4','Abeta4240','CKD','HbA1C','IHD','Stroke','Triglycerides','HDL','LDL'} );
tbl_ptau217_allele.Sex = categorical(tbl_ptau217_allele.Sex);
tbl_ptau217_allele.APOE4 = categorical(tbl_ptau217_allele.APOE4);
tbl_ptau217_allele.CKD = categorical(tbl_ptau217_allele.CKD);
tbl_ptau217_allele.IHD = categorical(tbl_ptau217_allele.IHD);
tbl_ptau217_allele.Stroke = categorical(tbl_ptau217_allele.Stroke);

tbl_ptau217_carrier_gfr = table( log(cell2mat(adai(pos_ptau217,strcmp(data_names,'pTau217')))), ...
    cell2mat(adai(pos_ptau217,strcmp(data_names,'Age')))/10, ...
    adai(pos_ptau217,strcmp(data_names,'Sex')), ...
    adai_apoe4_carrier(pos_ptau217,1), ...
    cell2mat(adai(pos_ptau217,strcmp(data_names,'GFR')))/10, ...
    adai(pos_ptau217,strcmp(data_names,'IHD')), ...
    log2(cell2mat(adai(pos_ptau217,strcmp(data_names,'Triglycerides')))), ...
    adai(pos_ptau217,strcmp(data_names,'HLD')), ...
    adai(pos_ptau217,strcmp(data_names,'Statin')), ...
    adai_epworth(pos_ptau217,1)/10, ...
    adai(pos_ptau217,strcmp(data_names,'Tobacco')), ...
    adai(pos_ptau217,strcmp(data_names,'SedatingMed')), ...
    'VariableNames', {'pTau217','Age','Sex','APOE4','GFR','IHD','Triglycerides','HLD','Statin','Epworth','Tobacco','SedatingMed'} );
tbl_ptau217_carrier_gfr.Sex = categorical(tbl_ptau217_carrier_gfr.Sex);
tbl_ptau217_carrier_gfr.APOE4 = categorical(tbl_ptau217_carrier_gfr.APOE4);
tbl_ptau217_carrier_gfr.IHD = categorical(tbl_ptau217_carrier_gfr.IHD);
tbl_ptau217_carrier_gfr.HLD = categorical(tbl_ptau217_carrier_gfr.HLD);
tbl_ptau217_carrier_gfr.Statin = categorical(tbl_ptau217_carrier_gfr.Statin);
tbl_ptau217_carrier_gfr.Tobacco = categorical(tbl_ptau217_carrier_gfr.Tobacco);
tbl_ptau217_carrier_gfr.SedatingMed = categorical(tbl_ptau217_carrier_gfr.SedatingMed);

%% Model ptau217 manusciprt
tbl_ptau217_carrier_gfr_manuscript = table( log(cell2mat(adai(pos_ptau217,strcmp(data_names,'pTau217')))), ...
    cell2mat(adai(pos_ptau217,strcmp(data_names,'Age')))/10, ...
    adai(pos_ptau217,strcmp(data_names,'Sex')), ...
    adai_apoe4_carrier(pos_ptau217,1), ...
    cell2mat(adai(pos_ptau217,strcmp(data_names,'GFR')))/10, ...
    log2(cell2mat(adai(pos_ptau217,strcmp(data_names,'HbA1C')))), ...
    log2(cell2mat(adai(pos_ptau217,strcmp(data_names,'YKL-40')))), ...
    adai(pos_ptau217,strcmp(data_names,'Statin')), ...
    adai(pos_ptau217,strcmp(data_names,'Tobacco')), ...
    adai(pos_ptau217,strcmp(data_names,'Alcohol')), ...
    log2(cell2mat(adai(pos_ptau217,strcmp(data_names,'Triglycerides')))), ...
    'VariableNames', {'pTau217','Age','Sex','APOE4','GFR','HbA1C','YKL-40','Statin','Tobacco','Alcohol','Triglycerides'} );
tbl_ptau217_carrier_gfr_manuscript.Sex = categorical(tbl_ptau217_carrier_gfr_manuscript.Sex);
tbl_ptau217_carrier_gfr_manuscript.APOE4 = categorical(tbl_ptau217_carrier_gfr_manuscript.APOE4);
tbl_ptau217_carrier_gfr_manuscript.Statin = categorical(tbl_ptau217_carrier_gfr_manuscript.Statin);
tbl_ptau217_carrier_gfr_manuscript.Tobacco = categorical(tbl_ptau217_carrier_gfr_manuscript.Tobacco);
tbl_ptau217_carrier_gfr_manuscript.Alcohol = categorical(tbl_ptau217_carrier_gfr_manuscript.Alcohol);

tbl_ptau217_carrier_gfr_manuscript_bmi = [ tbl_ptau217_carrier_gfr_manuscript table(cell2mat(adai(pos_ptau217,strcmp(data_names,'BMI'))),'VariableNames',{'BMI'}) ];

tbl_ptau217_carrier_gfr_manuscript_hdl = [ tbl_ptau217_carrier_gfr_manuscript table(log2(cell2mat(adai(pos_ptau217,strcmp(data_names,'HDL')))),'VariableNames',{'HDL'}) ];
tbl_ptau217_carrier_gfr_manuscript_hdl = tbl_ptau217_carrier_gfr_manuscript_hdl(:,~strcmp(tbl_ptau217_carrier_gfr_manuscript_hdl.Properties.VariableNames,'Triglycerides'));

tbl_ptau217_carrier_gfr_manuscript_ldl = [ tbl_ptau217_carrier_gfr_manuscript table(log2(cell2mat(adai(pos_ptau217,strcmp(data_names,'LDL')))),'VariableNames',{'LDL'}) ];
tbl_ptau217_carrier_gfr_manuscript_ldl = tbl_ptau217_carrier_gfr_manuscript_ldl(:,~strcmp(tbl_ptau217_carrier_gfr_manuscript_ldl.Properties.VariableNames,'Triglycerides'));

tbl_ptau217_carrier_gfr_manuscript_cholesterol = [ tbl_ptau217_carrier_gfr_manuscript table(log2(cell2mat(adai(pos_ptau217,strcmp(data_names,'HDL')))+cell2mat(adai(pos_ptau217,strcmp(data_names,'LDL')))+0.2*cell2mat(adai(pos_ptau217,strcmp(data_names,'Triglycerides')))),'VariableNames',{'TotalCholesterol'}) ];
tbl_ptau217_carrier_gfr_manuscript_cholesterol = tbl_ptau217_carrier_gfr_manuscript_cholesterol(:,~strcmp(tbl_ptau217_carrier_gfr_manuscript_cholesterol.Properties.VariableNames,'Triglycerides'));

tbl_ptau217_carrier_gfr_manuscript_noimpairment = tbl_ptau217_carrier_gfr_manuscript(strcmp(adai_impairment(pos_ptau217,1),'No impairment'),:);
tbl_ptau217_carrier_gfr_manuscript_impairment = tbl_ptau217_carrier_gfr_manuscript(~strcmp(adai_impairment(pos_ptau217,1),'No impairment'),:);

tbl_ptau217_carrier_gfr_manuscript_statintype = [ tbl_ptau217_carrier_gfr_manuscript table(adai_statin_type3(pos_ptau217,1),'VariableNames',{'StatinType'}) ];
tbl_ptau217_carrier_gfr_manuscript_statintype = tbl_ptau217_carrier_gfr_manuscript_statintype(:,~strcmp(tbl_ptau217_carrier_gfr_manuscript_statintype.Properties.VariableNames,'Statin'));
% tbl_ptau217_carrier_gfr_manuscript_statintype.StatinType = categorical(tbl_ptau217_carrier_gfr_manuscript_statintype.StatinType);
%%

tbl_ptau217_gfap = table( log(cell2mat(adai(pos_ptau217,strcmp(data_names,'pTau217')))), ...
    cell2mat(adai(pos_ptau217,strcmp(data_names,'Age')))/10, ...
    adai(pos_ptau217,strcmp(data_names,'Sex')), ...
    log2(cell2mat(adai(pos_ptau217,strcmp(data_names,'GFAP')))), ...
    log2(cell2mat(adai(pos_ptau217,strcmp(data_names,'GFR')))), ...
    'VariableNames', {'pTau217','Age','Sex','GFAP','GFR'} );
tbl_ptau217_gfap.Sex = categorical(tbl_ptau217_gfap.Sex);

tbl_gfap_carrier = table( log(cell2mat(adai(pos_gfap,strcmp(data_names,'GFAP')))), ...
    cell2mat(adai(pos_gfap,strcmp(data_names,'Age')))/10, ...
    adai(pos_gfap,strcmp(data_names,'Sex')), ...
    adai_apoe4_carrier(pos_gfap,1), ...
    log2(adai_abeta4240ratio(pos_gfap,1)), ...
    adai(pos_gfap,strcmp(data_names,'CKD')), ...
    cell2mat(adai(pos_gfap,strcmp(data_names,'HbA1C'))), ...
    adai(pos_gfap,strcmp(data_names,'IHD')), ...
    adai(pos_gfap,strcmp(data_names,'Stroke')), ...
    log2(cell2mat(adai(pos_gfap,strcmp(data_names,'Triglycerides')))), ...
    log2(cell2mat(adai(pos_gfap,strcmp(data_names,'HDL')))), ...
    log2(cell2mat(adai(pos_gfap,strcmp(data_names,'LDL')))), ...
    'VariableNames', {'pTau217','Age','Sex','APOE4','Abeta4240','CKD','HbA1C','IHD','Stroke','Triglycerides','HDL','LDL'} );
tbl_gfap_carrier.Sex = categorical(tbl_gfap_carrier.Sex);
tbl_gfap_carrier.APOE4 = categorical(tbl_gfap_carrier.APOE4);
tbl_gfap_carrier.CKD = categorical(tbl_gfap_carrier.CKD);
tbl_gfap_carrier.IHD = categorical(tbl_gfap_carrier.IHD);
tbl_gfap_carrier.Stroke = categorical(tbl_gfap_carrier.Stroke);

tbl_gfap_allele = table( log(cell2mat(adai(pos_gfap,strcmp(data_names,'GFAP')))), ...
    cell2mat(adai(pos_gfap,strcmp(data_names,'Age')))/10, ...
    adai(pos_gfap,strcmp(data_names,'Sex')), ...
    cell2mat(adai(pos_gfap,strcmp(data_names,'APOE4'))), ...
    log2(adai_abeta4240ratio(pos_gfap,1)), ...
    adai(pos_gfap,strcmp(data_names,'CKD')), ...
    cell2mat(adai(pos_gfap,strcmp(data_names,'HbA1C'))), ...
    adai(pos_gfap,strcmp(data_names,'IHD')), ...
    adai(pos_gfap,strcmp(data_names,'Stroke')), ...
    log2(cell2mat(adai(pos_gfap,strcmp(data_names,'Triglycerides')))), ...
    log2(cell2mat(adai(pos_gfap,strcmp(data_names,'HDL')))), ...
    log2(cell2mat(adai(pos_gfap,strcmp(data_names,'LDL')))), ...
    'VariableNames', {'pTau217','Age','Sex','APOE4','Abeta4240','CKD','HbA1C','IHD','Stroke','Triglycerides','HDL','LDL'} );
tbl_gfap_allele.Sex = categorical(tbl_gfap_allele.Sex);
tbl_gfap_allele.APOE4 = categorical(tbl_gfap_allele.APOE4);
tbl_gfap_allele.CKD = categorical(tbl_gfap_allele.CKD);
tbl_gfap_allele.IHD = categorical(tbl_gfap_allele.IHD);
tbl_gfap_allele.Stroke = categorical(tbl_gfap_allele.Stroke);

tbl_gfap_carrier_gfr = table( log(cell2mat(adai(pos_gfap,strcmp(data_names,'GFAP')))), ...
    cell2mat(adai(pos_gfap,strcmp(data_names,'Age')))/10, ...
    adai(pos_gfap,strcmp(data_names,'Sex')), ...
    adai_apoe4_carrier(pos_gfap,1), ...
    cell2mat(adai(pos_gfap,strcmp(data_names,'GFR')))/10, ...
    adai(pos_gfap,strcmp(data_names,'IHD')), ...
    log2(cell2mat(adai(pos_gfap,strcmp(data_names,'Triglycerides')))), ...
    adai(pos_gfap,strcmp(data_names,'HLD')), ...
    adai(pos_gfap,strcmp(data_names,'Statin')), ...
    adai_epworth(pos_gfap,1)/10, ...
    adai(pos_gfap,strcmp(data_names,'Tobacco')), ...
    adai(pos_gfap,strcmp(data_names,'SedatingMed')), ...
    'VariableNames', {'GFAP','Age','Sex','APOE4','GFR','IHD','Triglycerides','HLD','Statin','Epworth','Tobacco','SedatingMed'} );
tbl_gfap_carrier_gfr.Sex = categorical(tbl_gfap_carrier_gfr.Sex);
tbl_gfap_carrier_gfr.APOE4 = categorical(tbl_gfap_carrier_gfr.APOE4);
tbl_gfap_carrier_gfr.IHD = categorical(tbl_gfap_carrier_gfr.IHD);
tbl_gfap_carrier_gfr.HLD = categorical(tbl_gfap_carrier_gfr.HLD);
tbl_gfap_carrier_gfr.Statin = categorical(tbl_gfap_carrier_gfr.Statin);
tbl_gfap_carrier_gfr.Tobacco = categorical(tbl_gfap_carrier_gfr.Tobacco);
tbl_gfap_carrier_gfr.SedatingMed = categorical(tbl_gfap_carrier_gfr.SedatingMed);

tbl_abeta4240_carrier = table( log(adai_abeta4240ratio(pos_abeta4240,1)), ...
    cell2mat(adai(pos_abeta4240,strcmp(data_names,'Age')))/10, ...
    adai(pos_abeta4240,strcmp(data_names,'Sex')), ...
    adai_apoe4_carrier(pos_abeta4240,1), ...
    adai(pos_abeta4240,strcmp(data_names,'CKD')), ...
    cell2mat(adai(pos_abeta4240,strcmp(data_names,'HbA1C'))), ...
    adai(pos_abeta4240,strcmp(data_names,'IHD')), ...
    adai(pos_abeta4240,strcmp(data_names,'Stroke')), ...
    log2(cell2mat(adai(pos_abeta4240,strcmp(data_names,'Triglycerides')))), ...
    log2(cell2mat(adai(pos_abeta4240,strcmp(data_names,'HDL')))), ...
    log2(cell2mat(adai(pos_abeta4240,strcmp(data_names,'LDL')))), ...
    'VariableNames', {'Abeta4240','Age','Sex','APOE4','CKD','HbA1C','IHD','Stroke','Triglycerides','HDL','LDL'} );
tbl_abeta4240_carrier.Sex = categorical(tbl_abeta4240_carrier.Sex);
tbl_abeta4240_carrier.APOE4 = categorical(tbl_abeta4240_carrier.APOE4);
tbl_abeta4240_carrier.CKD = categorical(tbl_abeta4240_carrier.CKD);
tbl_abeta4240_carrier.IHD = categorical(tbl_abeta4240_carrier.IHD);
tbl_abeta4240_carrier.Stroke = categorical(tbl_abeta4240_carrier.Stroke);

tbl_abeta4240_allele = table( log(adai_abeta4240ratio(pos_abeta4240,1)), ...
    cell2mat(adai(pos_abeta4240,strcmp(data_names,'Age')))/10, ...
    adai(pos_abeta4240,strcmp(data_names,'Sex')), ...
    cell2mat(adai(pos_abeta4240,strcmp(data_names,'APOE4'))), ...
    adai(pos_abeta4240,strcmp(data_names,'CKD')), ...
    cell2mat(adai(pos_abeta4240,strcmp(data_names,'HbA1C'))), ...
    adai(pos_abeta4240,strcmp(data_names,'IHD')), ...
    adai(pos_abeta4240,strcmp(data_names,'Stroke')), ...
    log2(cell2mat(adai(pos_abeta4240,strcmp(data_names,'Triglycerides')))), ...
    log2(cell2mat(adai(pos_abeta4240,strcmp(data_names,'HDL')))), ...
    log2(cell2mat(adai(pos_abeta4240,strcmp(data_names,'LDL')))), ...
    'VariableNames', {'Abeta4240','Age','Sex','APOE4','CKD','HbA1C','IHD','Stroke','Triglycerides','HDL','LDL'} );
tbl_abeta4240_allele.Sex = categorical(tbl_abeta4240_allele.Sex);
tbl_abeta4240_allele.APOE4 = categorical(tbl_abeta4240_allele.APOE4);
tbl_abeta4240_allele.CKD = categorical(tbl_abeta4240_allele.CKD);
tbl_abeta4240_allele.IHD = categorical(tbl_abeta4240_allele.IHD);
tbl_abeta4240_allele.Stroke = categorical(tbl_abeta4240_allele.Stroke);

T_abeta4240 = eye(size(tbl_abeta4240,2));
T_abeta4240(1,1) = 0;

T_ykl40 = eye(size(tbl_ykl40,2));
T_ykl40(1,1) = 0;

T_apoeprotein = eye(size(tbl_apoeprotein,2));
T_apoeprotein(1,1) = 0;

T_ptau217_carrier = eye(size(tbl_ptau217_carrier,2));
T_ptau217_carrier(1,1) = 0;

T_ptau217_gfap = eye(size(tbl_ptau217_gfap,2));
T_ptau217_gfap(1,1) = 0;

T_abeta4240_carrier = eye(size(tbl_abeta4240_carrier,2));
T_abeta4240_carrier(1,1) = 0;

T_ptau217_carrier_gfr = eye(size(tbl_ptau217_carrier_gfr,2));
T_ptau217_carrier_gfr(1,1) = 0;
T_ptau217_carrier_gfr(end+1,1:6) = [0 0 0 1 0 1];

T_ptau217_carrier_gfr_baseline = eye(5);
T_ptau217_carrier_gfr_baseline(1,1) = 0;

T_ptau217_carrier_gfr_manuscript = eye(size(tbl_ptau217_carrier_gfr_manuscript,2));
T_ptau217_carrier_gfr_manuscript(1,1) = 0;

T_ptau217_carrier_gfr_manuscript_interaction = T_ptau217_carrier_gfr_manuscript;
T_ptau217_carrier_gfr_manuscript_interaction(end+1,:) = [0 0 0 0 0 0 0 1 0 0 1];

T_ptau217_carrier_gfr_manuscript_bmi = eye(size(tbl_ptau217_carrier_gfr_manuscript_bmi,2));
T_ptau217_carrier_gfr_manuscript_bmi(1,1) = 0;


mdl_abeta4240 = fitglm(tbl_abeta4240,T_abeta4240);
mdl_abeta42 = fitglm(tbl_abeta42,T_abeta4240);
mdl_abeta40 = fitglm(tbl_abeta40,T_abeta4240);
mdl_ykl40 = fitglm(tbl_ykl40,T_ykl40);
mdl_apoeprotein = fitglm(tbl_apoeprotein,T_apoeprotein);
mdl_ptau217_carrier = fitglm(tbl_ptau217_carrier,T_ptau217_carrier);
mdl_ptau217_allele = fitglm(tbl_ptau217_allele,T_ptau217_carrier);
mdl_ptau217_gfap = fitglm(tbl_ptau217_gfap,T_ptau217_gfap);
mdl_gfap_carrier = fitglm(tbl_gfap_carrier,T_ptau217_carrier);
mdl_gfap_allele = fitglm(tbl_gfap_allele,T_ptau217_carrier);
mdl_abeta4240_carrier = fitglm(tbl_abeta4240_carrier,T_abeta4240_carrier);
mdl_abeta4240_allele = fitglm(tbl_abeta4240_allele,T_abeta4240_carrier);

mdl_ptau217_carrier_gfr_baseline = fitglm(tbl_ptau217_carrier_gfr(:,{'pTau217','Age','Sex','APOE4','GFR'}),T_ptau217_carrier_gfr_baseline);
mdl_ptau217_carrier_gfr = fitglm(tbl_ptau217_carrier_gfr,T_ptau217_carrier_gfr);
mdl_ptau217_carrier_gfr_noHLD = fitglm(tbl_ptau217_carrier_gfr(:,~strcmp(tbl_ptau217_carrier_gfr.Properties.VariableNames,'HLD')),T_ptau217_carrier_gfr([1:end-2 end],1:end-1));


mdl_gfap_carrier_gfr_baseline = fitglm(tbl_gfap_carrier_gfr(:,{'GFAP','Age','Sex','APOE4','GFR'}),T_ptau217_carrier_gfr_baseline);
mdl_gfap_carrier_gfr = fitglm(tbl_gfap_carrier_gfr,T_ptau217_carrier_gfr);
mdl_gfap_carrier_gfr_noHLD = fitglm(tbl_gfap_carrier_gfr(:,~strcmp(tbl_gfap_carrier_gfr.Properties.VariableNames,'HLD')),T_ptau217_carrier_gfr([1:end-2 end],1:end-1));

mdl_ptau217_carrier_gfr_manuscript = fitglm(tbl_ptau217_carrier_gfr_manuscript,T_ptau217_carrier_gfr_manuscript);
mdl_ptau217_carrier_gfr_manuscript_bmi = fitglm(tbl_ptau217_carrier_gfr_manuscript_bmi,T_ptau217_carrier_gfr_manuscript_bmi);
mdl_ptau217_carrier_gfr_manuscript_hdl = fitglm(tbl_ptau217_carrier_gfr_manuscript_hdl,T_ptau217_carrier_gfr_manuscript);
mdl_ptau217_carrier_gfr_manuscript_ldl = fitglm(tbl_ptau217_carrier_gfr_manuscript_ldl,T_ptau217_carrier_gfr_manuscript);
mdl_ptau217_carrier_gfr_manuscript_cholesterol = fitglm(tbl_ptau217_carrier_gfr_manuscript_cholesterol,T_ptau217_carrier_gfr_manuscript);
mdl_ptau217_carrier_gfr_manuscript_interaction = fitglm(tbl_ptau217_carrier_gfr_manuscript,T_ptau217_carrier_gfr_manuscript_interaction);
mdl_ptau217_carrier_gfr_manuscript_noimpairment = fitglm(tbl_ptau217_carrier_gfr_manuscript_noimpairment,T_ptau217_carrier_gfr_manuscript);
mdl_ptau217_carrier_gfr_manuscript_impairment = fitglm(tbl_ptau217_carrier_gfr_manuscript_impairment,T_ptau217_carrier_gfr_manuscript);
mdl_ptau217_carrier_gfr_manuscript_statintype = fitglm(tbl_ptau217_carrier_gfr_manuscript_statintype,T_ptau217_carrier_gfr_manuscript);


ci_abeta4240 = exp(coefCI(mdl_abeta4240));
ci_abeta42 = exp(coefCI(mdl_abeta42));
ci_abeta40 = exp(coefCI(mdl_abeta40));
ci_ykl40 = exp(coefCI(mdl_ykl40));
ci_apoeprotein = exp(coefCI(mdl_apoeprotein));
ci_ptau217_carrier = exp(coefCI(mdl_ptau217_carrier));
ci_ptau217_allele = exp(coefCI(mdl_ptau217_allele));
ci_ptau217_gfap = exp(coefCI(mdl_ptau217_gfap));
ci_gfap_carrier = exp(coefCI(mdl_gfap_carrier));
ci_gfap_allele = exp(coefCI(mdl_gfap_allele));
ci_abeta4240_carrier = exp(coefCI(mdl_abeta4240_carrier));
ci_abeta4240_allele = exp(coefCI(mdl_abeta4240_allele));


ci_ptau217_carrier_gfr_baseline = exp(coefCI(mdl_ptau217_carrier_gfr_baseline));
ci_ptau217_carrier_gfr = exp(coefCI(mdl_ptau217_carrier_gfr));
ci_ptau217_carrier_gfr_noHLD = exp(coefCI(mdl_ptau217_carrier_gfr_noHLD));

ci_gfap_carrier_gfr_baseline = exp(coefCI(mdl_gfap_carrier_gfr_baseline));
ci_gfap_carrier_gfr = exp(coefCI(mdl_gfap_carrier_gfr));
ci_gfap_carrier_gfr_noHLD = exp(coefCI(mdl_gfap_carrier_gfr_noHLD));

ci_ptau217_carrier_gfr_manuscript = exp(coefCI(mdl_ptau217_carrier_gfr_manuscript));
ci_ptau217_carrier_gfr_manuscript_bmi = exp(coefCI(mdl_ptau217_carrier_gfr_manuscript_bmi));
ci_ptau217_carrier_gfr_manuscript_hdl = exp(coefCI(mdl_ptau217_carrier_gfr_manuscript_hdl));
ci_ptau217_carrier_gfr_manuscript_ldl = exp(coefCI(mdl_ptau217_carrier_gfr_manuscript_ldl));
ci_ptau217_carrier_gfr_manuscript_cholesterol = exp(coefCI(mdl_ptau217_carrier_gfr_manuscript_cholesterol));
ci_ptau217_carrier_gfr_manuscript_interaction = exp(coefCI(mdl_ptau217_carrier_gfr_manuscript_interaction));
ci_ptau217_carrier_gfr_manuscript_noimpairment = exp(coefCI(mdl_ptau217_carrier_gfr_manuscript_noimpairment));
ci_ptau217_carrier_gfr_manuscript_impairment = exp(coefCI(mdl_ptau217_carrier_gfr_manuscript_impairment));
ci_ptau217_carrier_gfr_manuscript_statintype = exp(coefCI(mdl_ptau217_carrier_gfr_manuscript_statintype));
%% Loop of linear mixture models
X_list = { 'BMI', 'SedatingMed', 'HeadTrauma', 'HTN', 'HLD', 'IHD', 'Tobacco', 'Epworth', 'Stop-Bang', 'Anxiety', ...
    'HbA1C', 'CKD', 'LDL', 'Triglycerides', 'YKL-40', 'HDL', 'AST', 'ALT', 'Insomnia', 'Albumin', 'GFR', 'Education' };



ptau217 = struct([]);
gfap = struct([]);
ptau217_abeta4240 = struct([]);

for ind = 1:size(X_list,2)
    X_name = X_list{1,ind};
    
    if strcmp(X_name,'YKL-40')
        X = log(cell2mat(adai(:,strcmp(data_names,X_name))));
    elseif strcmp(X_name,'BMI') || strcmp(X_name,'Epworth') || strcmp(X_name,'Stop-Bang') || strcmp(X_name,'HbA1C') || ...
            strcmp(X_name,'LDL') || strcmp(X_name,'Triglycerides') || strcmp(X_name,'HDL') || ...
            strcmp(X_name,'AST') || strcmp(X_name,'ALT') || strcmp(X_name,'Albumin') || ...
            strcmp(X_name,'Education')
        X = cell2mat(adai(:,strcmp(data_names,X_name)));
    elseif strcmp(X_name,'GFR')
        X = cell2mat(adai(:,strcmp(data_names,X_name)))/10;
    else
        X = adai(:,strcmp(data_names,X_name));
    end
    
    if ~strcmp(X_name,'CKD') && ~strcmp(X_name,'GFR')
        T_ptau217 = eye(6);
        T_ptau217(1,1) = 0;
        T_ptau217(end+1,:) = [0 0 0 0 1 1];
        
        tbl_ptau217 = table( log(cell2mat(adai(:,strcmp(data_names,'pTau217')))), ...
            cell2mat(adai(:,strcmp(data_names,'Age')))/10, ...
            adai(:,strcmp(data_names,'Sex')) , ...
            adai(:,strcmp(data_names,'CKD')) , ...
            adai_apoe4_carrier, ...
            X,...
            'VariableNames', {'pTau217','Age','Sex','CKD','APOE4',X_name} );        

        tbl_gfap = table( log(cell2mat(adai(:,strcmp(data_names,'GFAP')))), ...
            cell2mat(adai(:,strcmp(data_names,'Age')))/10, ...
            adai(:,strcmp(data_names,'Sex')) , ...
            adai(:,strcmp(data_names,'CKD')) , ...
            adai_apoe4_carrier, ...
            X,...
            'VariableNames', {'GFAP','Age','Sex','CKD','APOE4',X_name} );
        
        tbl_ptau217_abeta4240 = table( log(cell2mat(adai(:,strcmp(data_names,'pTau217')))), ...
            cell2mat(adai(:,strcmp(data_names,'Age')))/10, ...
            adai(:,strcmp(data_names,'Sex')) , ...
            adai(:,strcmp(data_names,'CKD')) , ...
            log2(adai_abeta4240ratio), ...
            X,...
            'VariableNames', {'pTau217','Age','Sex','CKD','Abeta4240',X_name} );
    else
        T_ptau217 = eye(5);
        T_ptau217(1,1) = 0;
        T_ptau217(end+1,:) = [0 0 0 1 1];
        
        tbl_ptau217 = table( log(cell2mat(adai(:,strcmp(data_names,'pTau217')))), ...
            cell2mat(adai(:,strcmp(data_names,'Age')))/10, ...
            adai(:,strcmp(data_names,'Sex')) , ...
            adai_apoe4_carrier, ...
            X,...
            'VariableNames', {'pTau217','Age','Sex','APOE4',X_name} );

        tbl_gfap = table( log(cell2mat(adai(:,strcmp(data_names,'GFAP')))), ...
            cell2mat(adai(:,strcmp(data_names,'Age')))/10, ...
            adai(:,strcmp(data_names,'Sex')) , ...
            adai_apoe4_carrier, ...
            X,...
            'VariableNames', {'GFAP','Age','Sex','APOE4',X_name} );
        
        tbl_ptau217_abeta4240 = table( log(cell2mat(adai(:,strcmp(data_names,'pTau217')))), ...
            cell2mat(adai(:,strcmp(data_names,'Age')))/10, ...
            adai(:,strcmp(data_names,'Sex')) , ...
            log2(adai_abeta4240ratio), ...
            X,...
            'VariableNames', {'pTau217','Age','Sex','Abeta4240',X_name} );
    end
    tbl_ptau217.Sex = categorical(tbl_ptau217.Sex);
    tbl_ptau217.APOE4 = categorical(tbl_ptau217.APOE4);
    
    tbl_gfap.Sex = categorical(tbl_gfap.Sex);
    tbl_gfap.APOE4 = categorical(tbl_gfap.APOE4);
    
    tbl_ptau217_abeta4240.Sex = categorical(tbl_ptau217.Sex);
    
    if ~strcmp(X_name,'GFR')
        tbl_ptau217.CKD = categorical(tbl_ptau217.CKD);
        tbl_gfap.CKD = categorical(tbl_gfap.CKD);
        tbl_ptau217_abeta4240.CKD = categorical(tbl_ptau217.CKD);
    end
    
    if strcmp(X_name,'SedatingMed')
        tbl_ptau217.SedatingMed = categorical(tbl_ptau217.SedatingMed);
        tbl_gfap.SedatingMed = categorical(tbl_gfap.SedatingMed);
        tbl_ptau217_abeta4240.SedatingMed = categorical(tbl_ptau217_abeta4240.SedatingMed);
    elseif strcmp(X_name,'HeadTrauma')
        tbl_ptau217.HeadTrauma = categorical(tbl_ptau217.HeadTrauma);
        tbl_gfap.HeadTrauma = categorical(tbl_gfap.HeadTrauma);
        tbl_ptau217_abeta4240.HeadTrauma = categorical(tbl_ptau217_abeta4240.HeadTrauma);
    elseif strcmp(X_name,'HTN')
        tbl_ptau217.HTN = categorical(tbl_ptau217.HTN);
        tbl_gfap.HTN = categorical(tbl_gfap.HTN);
        tbl_ptau217_abeta4240.HTN = categorical(tbl_ptau217_abeta4240.HTN);
    elseif strcmp(X_name,'HLD')
        tbl_ptau217.HLD = categorical(tbl_ptau217.HLD);
        tbl_gfap.HLD = categorical(tbl_gfap.HLD);
        tbl_ptau217_abeta4240.HLD = categorical(tbl_ptau217_abeta4240.HLD);
    elseif strcmp(X_name,'IHD')
        tbl_ptau217.IHD = categorical(tbl_ptau217.IHD);
        tbl_gfap.IHD = categorical(tbl_gfap.IHD);
        tbl_ptau217_abeta4240.IHD = categorical(tbl_ptau217_abeta4240.IHD);
    elseif strcmp(X_name,'Tobacco')
        tbl_ptau217.Tobacco = categorical(tbl_ptau217.Tobacco);
        tbl_gfap.Tobacco = categorical(tbl_gfap.Tobacco);
        tbl_ptau217_abeta4240.Tobacco = categorical(tbl_ptau217_abeta4240.Tobacco);
    elseif strcmp(X_name,'Anxiety')
        tbl_ptau217.Anxiety = categorical(tbl_ptau217.Anxiety);
        tbl_gfap.Anxiety = categorical(tbl_gfap.Anxiety);
        tbl_ptau217_abeta4240.Anxiety = categorical(tbl_ptau217_abeta4240.Anxiety);
    elseif strcmp(X_name,'Insomnia')
        tbl_ptau217.Insomnia = categorical(tbl_ptau217.Insomnia);
        tbl_gfap.Insomnia = categorical(tbl_gfap.Insomnia);
        tbl_ptau217_abeta4240.Insomnia = categorical(tbl_ptau217_abeta4240.Insomnia);
    end
    
    ptau217(ind,1).X_name = X_name;
    ptau217(ind,1).tbl = tbl_ptau217;
    ptau217(ind,1).T = T_ptau217;
    ptau217(ind,1).mdl = fitglm(tbl_ptau217,T_ptau217);
    ptau217(ind,1).ci = exp(coefCI(ptau217(ind,1).mdl));
    
    gfap(ind,1).X_name = X_name;
    gfap(ind,1).tbl = tbl_gfap;
    gfap(ind,1).T = T_ptau217;
    gfap(ind,1).mdl = fitglm(tbl_gfap,T_ptau217);
    gfap(ind,1).ci = exp(coefCI(gfap(ind,1).mdl));
    
    ptau217_abeta4240(ind,1).X_name = X_name;
    ptau217_abeta4240(ind,1).tbl = tbl_ptau217_abeta4240;
    ptau217_abeta4240(ind,1).T = T_ptau217;
    ptau217_abeta4240(ind,1).mdl = fitglm(tbl_ptau217_abeta4240,T_ptau217);
    ptau217_abeta4240(ind,1).ci = exp(coefCI(ptau217_abeta4240(ind,1).mdl));
end

%% DISP regression model' results
% for ind = 1:size(X_list,2)
% %     disp(ptau217(ind,1).mdl)
% %     disp(gfap(ind,1).mdl)
%     disp(ptau217_abeta4240(ind,1).mdl)
%     disp(' ')
%     disp('_______________________________________________________________________________________________')
%     disp(' ')
% end

%% Estimate demography stats

%% Stats demography APOE4 genotypes and GFR available (Included subjects only, i.e., existing GFR records)
adai_hc_pos = strcmp(adai(:,strcmp(data_names,'Impairment')),'No impairment');
% adai_mci_pos = strcmp(adai(:,strcmp(data_names,'Impairment')),'Mild Cognitive Impairment') | strcmp(adai(:,strcmp(data_names,'Impairment')),'Subjective Cognitive Impairment');
adai_mci_pos = strcmp(adai(:,strcmp(data_names,'Impairment')),'Mild Cognitive Impairment') | strcmp(adai(:,strcmp(data_names,'Impairment')),'Subjective Cognitive Impairment') | strcmp(adai(:,strcmp(data_names,'Impairment')),'Dementia');
adai_ad_pos = strcmp(adai(:,strcmp(data_names,'Impairment')),'Dementia');
adai_all_pos = adai_hc_pos | adai_mci_pos | adai_ad_pos;
adai_nsubjets = sum(adai_all_pos);

stats_demography{1,2} = ['N=' num2str(adai_nsubjets) ];
stats_demography{1,3} = ['N=' num2str( sum(adai_hc_pos) ) ' (' num2str(100*sum(adai_hc_pos)/adai_nsubjets,'%.0f') '%)' ];
stats_demography{1,4} = 'No impairment';
stats_demography{1,5} = ['N=' num2str( sum(adai_mci_pos) ) ' (' num2str(100*sum(adai_mci_pos)/adai_nsubjets,'%.0f') '%)' ];
stats_demography{1,6} = 'SCI+MCI';
stats_demography{1,7} = ['N=' num2str( sum(adai_ad_pos) ) ' (' num2str(100*sum(adai_ad_pos)/adai_nsubjets,'%.1f') '%)' ];
stats_demography{1,8} = 'AD';
stats_demography{1,9} = 'p_HCvsMCI';
stats_demography{1,10} = 'p_HCvsAD';
stats_demography{1,11} = 'p_MCIvsAD';

stats_demography(2,:) = estimate_continuous_stats('Age [y.o.]','Age',0,adai,data_names,adai_all_pos,adai_hc_pos,adai_mci_pos,adai_ad_pos);
stats_demography(3,:) = estimate_binary_stats('Females','Sex','Male','Female',0,adai,data_names,adai_all_pos,adai_hc_pos,adai_mci_pos,adai_ad_pos);
stats_demography(4,:) = estimate_continuous_stats('Education [y]','Education',0,adai,data_names,adai_all_pos,adai_hc_pos,adai_mci_pos,adai_ad_pos);
stats_demography(5,:) = estimate_continuous_stats('MMSE','MMSE',0,adai,data_names,adai_all_pos,adai_hc_pos,adai_mci_pos,adai_ad_pos);
stats_demography(6,:) = estimate_binary_stats('APOE4 carrier','APOE4','No','Yes',0,adai_apoe4_carrier,{'APOE4'},adai_all_pos,adai_hc_pos,adai_mci_pos,adai_ad_pos);
stats_demography(7,:) = estimate_binary_stats('Homeless','Homeless','No','Yes',0,adai,data_names,adai_all_pos,adai_hc_pos,adai_mci_pos,adai_ad_pos);
stats_demography(8,:) = estimate_binary_stats('Hypertension','HTN','No','Yes',0,adai,data_names,adai_all_pos,adai_hc_pos,adai_mci_pos,adai_ad_pos);
stats_demography(9,:) = estimate_binary_stats('Hyperlipidemia','HLD','No','Yes',0,adai,data_names,adai_all_pos,adai_hc_pos,adai_mci_pos,adai_ad_pos);
stats_demography(10,:) = estimate_binary_stats('Tobacco','Tobacco','No','Yes',0,adai,data_names,adai_all_pos,adai_hc_pos,adai_mci_pos,adai_ad_pos);
stats_demography(11,:) = estimate_binary_stats('Alcohol','Alcohol','No','Yes',0,adai,data_names,adai_all_pos,adai_hc_pos,adai_mci_pos,adai_ad_pos);
stats_demography(12,:) = estimate_continuous_stats('Height [cm]','Height',0,adai,data_names,adai_all_pos,adai_hc_pos,adai_mci_pos,adai_ad_pos);
stats_demography(13,:) = estimate_continuous_stats('Weight [kg]','Weight',0,adai,data_names,adai_all_pos,adai_hc_pos,adai_mci_pos,adai_ad_pos);
stats_demography(14,:) = estimate_continuous_stats('BMI [kg/m^2]','BMI',0,adai,data_names,adai_all_pos,adai_hc_pos,adai_mci_pos,adai_ad_pos);
stats_demography(15,:) = estimate_continuous_stats('LDL','LDL',0,adai,data_names,adai_all_pos,adai_hc_pos,adai_mci_pos,adai_ad_pos);
stats_demography(16,:) = estimate_continuous_stats('HDL','HDL',0,adai,data_names,adai_all_pos,adai_hc_pos,adai_mci_pos,adai_ad_pos);
stats_demography(17,:) = estimate_continuous_stats('HbA1C','HbA1C',1,adai,data_names,adai_all_pos,adai_hc_pos,adai_mci_pos,adai_ad_pos);
stats_demography(18,:) = estimate_binary_stats('Head trauma','HeadTrauma','No','Yes',0,adai,data_names,adai_all_pos,adai_hc_pos,adai_mci_pos,adai_ad_pos);
stats_demography(19,:) = estimate_binary_stats('IHD','IHD','No','Yes',0,adai,data_names,adai_all_pos,adai_hc_pos,adai_mci_pos,adai_ad_pos);
stats_demography(20,:) = estimate_binary_stats('Non-IHD','Non-IHD','No','Yes',0,adai,data_names,adai_all_pos,adai_hc_pos,adai_mci_pos,adai_ad_pos);
stats_demography(21,:) = estimate_binary_stats('Stroke','Stroke','No','Yes',0,adai,data_names,adai_all_pos,adai_hc_pos,adai_mci_pos,adai_ad_pos);
stats_demography(22,:) = estimate_binary_stats('CKD','CKD','No','Yes',0,adai,data_names,adai_all_pos,adai_hc_pos,adai_mci_pos,adai_ad_pos);
stats_demography(23,:) = estimate_continuous_stats('eGFR','GFR',0,adai,data_names,adai_all_pos,adai_hc_pos,adai_mci_pos,adai_ad_pos);
stats_demography(24,:) = estimate_continuous_stats('Albumin','Albumin',1,adai,data_names,adai_all_pos,adai_hc_pos,adai_mci_pos,adai_ad_pos);
stats_demography(25,:) = estimate_continuous_stats('AST','AST',0,adai,data_names,adai_all_pos,adai_hc_pos,adai_mci_pos,adai_ad_pos);
stats_demography(26,:) = estimate_continuous_stats('ALT','ALT',0,adai,data_names,adai_all_pos,adai_hc_pos,adai_mci_pos,adai_ad_pos);
stats_demography(27,:) = estimate_continuous_stats('Abeta42','Abeta42',1,adai,data_names,adai_all_pos,adai_hc_pos,adai_mci_pos,adai_ad_pos);
stats_demography(28,:) = estimate_continuous_stats('Abeta40','Abeta40',0,adai,data_names,adai_all_pos,adai_hc_pos,adai_mci_pos,adai_ad_pos);
stats_demography(29,:) = estimate_continuous_stats('Abeta42/40','Abeta42/40',3,num2cell(adai_abeta4240ratio),{'Abeta42/40'},adai_all_pos,adai_hc_pos,adai_mci_pos,adai_ad_pos);
stats_demography(30,:) = estimate_continuous_stats('pTau181','pTau181',0,adai,data_names,adai_all_pos,adai_hc_pos,adai_mci_pos,adai_ad_pos);
stats_demography(31,:) = estimate_continuous_stats('pTau217','pTau217',2,adai,data_names,adai_all_pos,adai_hc_pos,adai_mci_pos,adai_ad_pos);
stats_demography(32,:) = estimate_continuous_stats('GFAP','GFAP',0,adai,data_names,adai_all_pos,adai_hc_pos,adai_mci_pos,adai_ad_pos);
stats_demography(33,:) = estimate_continuous_stats('YKL-40','YKL-40',0,adai,data_names,adai_all_pos,adai_hc_pos,adai_mci_pos,adai_ad_pos);

% stats_demography

% data_names = {'pTau217', 'Age', 'Sex', 'APOE4', 'Abeta42', 'Abeta40',...
%     'Height', 'Weight', 'BMI', 'HbA1C', 'HDL', 'LDL', 'Triglycerides', 'AST', 'ALT', 'HeadTrauma', 'HTN', 'HLD', 'IHD', 'Non-IHD', 'Stroke', 'CKD', 'GFR', ...
%     'pTau181', 'GFAP', 'NfL', 'MMSE', 'Ancestry', 'Homeless', 'Education',...
%     'YKL-40', 'APOE2', 'APOE3', 'APOEprotein', 'Statin', 'Tobacco', 'Alcohol', 'Albumin', 'Epworth', 'Stop-Bang', ...
%     'SedPsychSubsMed', 'SedatingMed', 'Anxiety', 'OSA', 'Insomnia', ...
%     'Impairment'};

% stats_demography{2,1} = 'Females';
% stats_demography{3,1} = 'Age [y.o.]';
% stats_demography{4,1} = 'Height [cm]';
% stats_demography{5,1} = 'Weight [kg]';
% stats_demography{6,1} = 'BMI [kg/m^2]';
% stats_demography{7,1} = 'pTau217';
% stats_demography{8,1} = 'GFAP';
% stats_demography{9,1} = 'NfL';
% stats_demography{10,1} = 'Abeta42';
% stats_demography{11,1} = 'Abeta40';
% stats_demography{12,1} = 'Abeta 42/40';
% stats_demography{13,1} = 'HbA1C';
% stats_demography{14,1} = 'LDL';
% stats_demography{15,1} = 'eGFR';
% stats_demography{16,1} = 'CKD';
% stats_demography{17,1} = 'Hypertension';
% stats_demography{18,1} = 'IHD';
% stats_demography{19,1} = 'Stroke';
% stats_demography{20,1} = 'MMSE';
% stats_demography{21,1} = 'Ancestry';
% stats_demography{22,1} = 'Homeless';
% stats_demography{23,1} = 'Education [y]';

% stats_demography{1,9} = ['N=' num2str(sum(~isnan(adni_all_apoe4_gfr)))];
% stats_demography{1,10} = 'All participants';
% stats_demography{1,11} = ['N=' num2str(sum(cell2mat(adni_all_apoe4(~isnan(adni_all_apoe4_gfr),strcmp(data_names,'APOE4')))==0)) ' (' num2str(100*sum(cell2mat(adni_all_apoe4(~isnan(adni_all_apoe4_gfr),strcmp(data_names,'APOE4')))==0)/sum(~isnan(adni_all_apoe4_gfr)),'%.0f') '%)'];
% stats_demography{1,12} = 'APOE4 non-carriers';
% stats_demography{1,13} = ['N=' num2str(sum(cell2mat(adni_all_apoe4(~isnan(adni_all_apoe4_gfr),strcmp(data_names,'APOE4')))>=1)) ' (' num2str(100*sum(cell2mat(adni_all_apoe4(~isnan(adni_all_apoe4_gfr),strcmp(data_names,'APOE4')))>=1)/sum(~isnan(adni_all_apoe4_gfr)),'%.0f') '%)'];
% stats_demography{1,14} = 'APOE4 carriers';
% stats_demography{1,15} = 'p';
% stats_demography{1,16} = 'p_All';
% stats_demography{1,17} = ['N=' num2str(sum(isnan(adni_all_apoe4_gfr)))];
% stats_demography{1,18} = 'ADNI excluded';
% stats_demography{1,19} = 'p';
% stats_demography{1,20} = ['N=' num2str(size(adai_excluded,1))];
% stats_demography{1,21} = 'ADAI excluded';
% stats_demography{1,22} = 'p';


%% Stats demography ptau217 available (Included subjects only, i.e., existing ptau217 records)

pos_included = pos_ptau217;
pos_all = pos_ptau217 | ~pos_included;
pos_excluded = ~pos_included;

stats_demography_ptau217{1,2} = ['N=' num2str(adai_nsubjets) ];
stats_demography_ptau217{1,3} = ['N=' num2str( sum(pos_included) ) ' (' num2str(100*sum(pos_included)/adai_nsubjets,'%.0f') '%)' ];
stats_demography_ptau217{1,4} = 'Included';
stats_demography_ptau217{1,5} = ['N=' num2str( sum(pos_excluded) ) ' (' num2str(100*sum(pos_excluded)/adai_nsubjets,'%.0f') '%)' ];
stats_demography_ptau217{1,6} = 'Excluded';
stats_demography_ptau217{1,7} = 'p';

stats_demography_ptau217(2,:) = estimate_continuous_stats_included('Age [y.o.]','Age',0,adai,data_names,pos_all,pos_included,pos_excluded);
stats_demography_ptau217(3,:) = estimate_binary_stats_included('Females','Sex','Male','Female',0,adai,data_names,pos_all,pos_included,pos_excluded);
stats_demography_ptau217(4,:) = estimate_continuous_stats_included('Education [y]','Education',0,adai,data_names,pos_all,pos_included,pos_excluded);
stats_demography_ptau217(5,:) = estimate_continuous_stats_included('MMSE','MMSE',0,adai,data_names,pos_all,pos_included,pos_excluded);
stats_demography_ptau217(6,:) = estimate_binary_stats_included('APOE4 carrier','APOE4','No','Yes',0,adai_apoe4_carrier,{'APOE4'},pos_all,pos_included,pos_excluded);
stats_demography_ptau217(7,:) = estimate_binary_stats_included('Homeless','Homeless','No','Yes',0,adai,data_names,pos_all,pos_included,pos_excluded);
stats_demography_ptau217(8,:) = estimate_binary_stats_included('Hypertension','HTN','No','Yes',0,adai,data_names,pos_all,pos_included,pos_excluded);
stats_demography_ptau217(9,:) = estimate_binary_stats_included('Hyperlipidemia','HLD','No','Yes',0,adai,data_names,pos_all,pos_included,pos_excluded);
stats_demography_ptau217(10,:) = estimate_binary_stats_included('Tobacco','Tobacco','No','Yes',0,adai,data_names,pos_all,pos_included,pos_excluded);
stats_demography_ptau217(11,:) = estimate_binary_stats_included('Alcohol','Alcohol','No','Yes',0,adai,data_names,pos_all,pos_included,pos_excluded);
stats_demography_ptau217(12,:) = estimate_continuous_stats_included('Height [cm]','Height',0,adai,data_names,pos_all,pos_included,pos_excluded);
stats_demography_ptau217(13,:) = estimate_continuous_stats_included('Weight [kg]','Weight',0,adai,data_names,pos_all,pos_included,pos_excluded);
stats_demography_ptau217(14,:) = estimate_continuous_stats_included('BMI [kg/m^2]','BMI',0,adai,data_names,pos_all,pos_included,pos_excluded);
stats_demography_ptau217(15,:) = estimate_continuous_stats_included('LDL','LDL',0,adai,data_names,pos_all,pos_included,pos_excluded);
stats_demography_ptau217(16,:) = estimate_continuous_stats_included('HDL','HDL',0,adai,data_names,pos_all,pos_included,pos_excluded);
stats_demography_ptau217(17,:) = estimate_continuous_stats_included('HbA1C','HbA1C',1,adai,data_names,pos_all,pos_included,pos_excluded);
stats_demography_ptau217(18,:) = estimate_binary_stats_included('Head trauma','HeadTrauma','No','Yes',0,adai,data_names,pos_all,pos_included,pos_excluded);
stats_demography_ptau217(19,:) = estimate_binary_stats_included('IHD','IHD','No','Yes',0,adai,data_names,pos_all,pos_included,pos_excluded);
stats_demography_ptau217(20,:) = estimate_binary_stats_included('Non-IHD','Non-IHD','No','Yes',0,adai,data_names,pos_all,pos_included,pos_excluded);
stats_demography_ptau217(21,:) = estimate_binary_stats_included('Stroke','Stroke','No','Yes',0,adai,data_names,pos_all,pos_included,pos_excluded);
stats_demography_ptau217(22,:) = estimate_binary_stats_included('CKD','CKD','No','Yes',0,adai,data_names,pos_all,pos_included,pos_excluded);
stats_demography_ptau217(23,:) = estimate_continuous_stats_included('eGFR','GFR',0,adai,data_names,pos_all,pos_included,pos_excluded);
stats_demography_ptau217(24,:) = estimate_continuous_stats_included('Albumin','Albumin',1,adai,data_names,pos_all,pos_included,pos_excluded);
stats_demography_ptau217(25,:) = estimate_continuous_stats_included('AST','AST',0,adai,data_names,pos_all,pos_included,pos_excluded);
stats_demography_ptau217(26,:) = estimate_continuous_stats_included('ALT','ALT',0,adai,data_names,pos_all,pos_included,pos_excluded);
stats_demography_ptau217(27,:) = estimate_continuous_stats_included('Abeta42','Abeta42',1,adai,data_names,pos_all,pos_included,pos_excluded);
stats_demography_ptau217(28,:) = estimate_continuous_stats_included('Abeta40','Abeta40',0,adai,data_names,pos_all,pos_included,pos_excluded);
stats_demography_ptau217(29,:) = estimate_continuous_stats_included('Abeta42/40','Abeta42/40',3,num2cell(adai_abeta4240ratio),{'Abeta42/40'},pos_all,pos_included,pos_excluded);
stats_demography_ptau217(30,:) = estimate_continuous_stats_included('pTau181','pTau181',0,adai,data_names,pos_all,pos_included,pos_excluded);
stats_demography_ptau217(31,:) = estimate_continuous_stats_included('pTau217','pTau217',2,adai,data_names,pos_all,pos_included,pos_excluded);
stats_demography_ptau217(32,:) = estimate_continuous_stats_included('GFAP','GFAP',0,adai,data_names,pos_all,pos_included,pos_excluded);
stats_demography_ptau217(33,:) = estimate_continuous_stats_included('YKL-40','YKL-40',0,adai,data_names,pos_all,pos_included,pos_excluded);
stats_demography_ptau217(34,:) = estimate_binary_stats_included('No Impairment','No Impairment','No','Yes',0,adai_noimpairment,{'No Impairment'},pos_all,pos_included,pos_excluded);
stats_demography_ptau217(35,:) = estimate_binary_stats_included('SCI+MCI','SCI+MCI','No','Yes',0,adai_smci,{'SCI+MCI'},pos_all,pos_included,pos_excluded);
stats_demography_ptau217(36,:) = estimate_binary_stats_included('Dementia','Dementia','No','Yes',0,adai_ad,{'Dementia'},pos_all,pos_included,pos_excluded);
%% Build table with regression results

stats_regression_ptau217{1,2} = 'Baseline';
stats_regression_ptau217{1,3} = 'LDL';
stats_regression_ptau217{1,4} = 'HDL';
stats_regression_ptau217{1,5} = 'Total cholesterol';
stats_regression_ptau217{1,6} = 'Statin*Triglycerides';
stats_regression_ptau217{1,7} = 'Statin Type';
stats_regression_ptau217{1,8} = 'BMI';
stats_regression_ptau217{1,9} = 'No Impairment';
stats_regression_ptau217{1,10} = 'Impairment';

stats_regression_ptau217{2,1} = 'N';
stats_regression_ptau217{3,1} = 'log2(HbA1C)';
stats_regression_ptau217{4,1} = 'Sex: Male';
stats_regression_ptau217{5,1} = 'APOE4';
stats_regression_ptau217{6,1} = 'Age/10';
stats_regression_ptau217{7,1} = 'log2(YKL-40)';
stats_regression_ptau217{8,1} = 'Tobacco';
stats_regression_ptau217{9,1} = 'Alcohol';
stats_regression_ptau217{10,1} = 'eGFR/10';
stats_regression_ptau217{11,1} = 'Statin';
stats_regression_ptau217{12,1} = 'log2(Triglycerides)';
stats_regression_ptau217{13,1} = 'log2(LDL)';
stats_regression_ptau217{14,1} = 'log2(HDL)';
stats_regression_ptau217{15,1} = 'log2(Total Cholesterol)';
stats_regression_ptau217{16,1} = 'Statin*log2(Triglycerides)';
stats_regression_ptau217{17,1} = 'Statin: Non-Lipophilic';
stats_regression_ptau217{18,1} = 'Statin: Lipophilic';
stats_regression_ptau217{19,1} = 'BMI';

stats_regression_ptau217 = assemble_regression_result_table(2,stats_regression_ptau217,mdl_ptau217_carrier_gfr_manuscript,ci_ptau217_carrier_gfr_manuscript);
stats_regression_ptau217 = assemble_regression_result_table(3,stats_regression_ptau217,mdl_ptau217_carrier_gfr_manuscript_ldl,ci_ptau217_carrier_gfr_manuscript_ldl);
stats_regression_ptau217 = assemble_regression_result_table(4,stats_regression_ptau217,mdl_ptau217_carrier_gfr_manuscript_hdl,ci_ptau217_carrier_gfr_manuscript_hdl);
stats_regression_ptau217 = assemble_regression_result_table(5,stats_regression_ptau217,mdl_ptau217_carrier_gfr_manuscript_cholesterol,ci_ptau217_carrier_gfr_manuscript_cholesterol);
stats_regression_ptau217 = assemble_regression_result_table(6,stats_regression_ptau217,mdl_ptau217_carrier_gfr_manuscript_interaction,ci_ptau217_carrier_gfr_manuscript_interaction);
stats_regression_ptau217 = assemble_regression_result_table(7,stats_regression_ptau217,mdl_ptau217_carrier_gfr_manuscript_statintype,ci_ptau217_carrier_gfr_manuscript_statintype);
stats_regression_ptau217 = assemble_regression_result_table(8,stats_regression_ptau217,mdl_ptau217_carrier_gfr_manuscript_bmi,ci_ptau217_carrier_gfr_manuscript_bmi);
stats_regression_ptau217 = assemble_regression_result_table(9,stats_regression_ptau217,mdl_ptau217_carrier_gfr_manuscript_noimpairment,ci_ptau217_carrier_gfr_manuscript_noimpairment);
stats_regression_ptau217 = assemble_regression_result_table(10,stats_regression_ptau217,mdl_ptau217_carrier_gfr_manuscript_impairment,ci_ptau217_carrier_gfr_manuscript_impairment);

%% FUNCTIONS

function stats = assemble_regression_result_table(col,stats,mdl,ci)
    stats{2,col} = mdl.NumObservations;
    stats{3,col} = make_regression_string(mdl,ci,'HbA1C');
    stats{4,col} = make_regression_string(mdl,ci,'Sex_Male');
    stats{5,col} = make_regression_string(mdl,ci,'APOE4_1');
    stats{6,col} = make_regression_string(mdl,ci,'Age');
    stats{7,col} = make_regression_string(mdl,ci,'YKL-40');
    stats{8,col} = make_regression_string(mdl,ci,'Tobacco_Yes');
    stats{9,col} = make_regression_string(mdl,ci,'Alcohol_Yes');
    stats{10,col} = make_regression_string(mdl,ci,'GFR');
    if sum(strcmp(mdl.CoefficientNames,'Statin_Yes')) == 1
        stats{11,col} = make_regression_string(mdl,ci,'Statin_Yes');
    end
    if sum(strcmp(mdl.CoefficientNames,'Triglycerides')) == 1
        stats{12,col} = make_regression_string(mdl,ci,'Triglycerides');
    end
    if sum(strcmp(mdl.CoefficientNames,'LDL')) == 1
        stats{13,col} = make_regression_string(mdl,ci,'LDL');
    end
    if sum(strcmp(mdl.CoefficientNames,'HDL')) == 1
        stats{14,col} = make_regression_string(mdl,ci,'HDL');
    end
    if sum(strcmp(mdl.CoefficientNames,'TotalCholesterol')) == 1
        stats{15,col} = make_regression_string(mdl,ci,'TotalCholesterol');
    end
    if sum(strcmp(mdl.CoefficientNames,'Statin_Yes:Triglycerides')) == 1
        stats{16,col} = make_regression_string(mdl,ci,'Statin_Yes:Triglycerides');
    end
    if sum(strcmp(mdl.CoefficientNames,'StatinType_1')) == 1
        stats{17,col} = make_regression_string(mdl,ci,'StatinType_1');
    end
    if sum(strcmp(mdl.CoefficientNames,'StatinType_2')) == 1
        stats{18,col} = make_regression_string(mdl,ci,'StatinType_2');
    end
    if sum(strcmp(mdl.CoefficientNames,'BMI')) == 1
        stats{19,col} = make_regression_string(mdl,ci,'BMI');
    end
end

function str = make_regression_string(mdl,ci,varname)
    est = exp(cell2mat(table2cell(mdl.Coefficients(varname,'Estimate'))));
    str = [ num2str(est,'%.2f') ' (' num2str(ci(strcmp(mdl.CoefficientNames,varname),1),'%.2f') '; ' num2str(ci(strcmp(mdl.CoefficientNames,varname),2),'%.2f') ')' ];
    if cell2mat(table2cell(mdl.Coefficients(varname,'pValue'))) < 0.05
        str(end+1) = '*';
    end
end

function stats = estimate_continuous_stats(tbl_var_name,var_name,precision,data,data_names,all_pos,hc_pos,mci_pos,ad_pos)

    stats{1,1} = tbl_var_name;
    
    precision_string = ['%.' num2str(precision) 'f'];
    
    all_data = cell2mat(data(all_pos,strcmp(data_names,var_name)));
    hc_data = cell2mat(data(hc_pos,strcmp(data_names,var_name)));
    mci_data = cell2mat(data(mci_pos,strcmp(data_names,var_name)));
    ad_data = cell2mat(data(ad_pos,strcmp(data_names,var_name)));
    

    stats{1,2} = sum( ~isnan(all_data) ) ;

    stats{1,3} = sum( ~isnan(hc_data) ) ;
    stats{1,4} = [ num2str(quantile(hc_data,0.5),precision_string) ' (' ...
        num2str(quantile(hc_data,0.25),precision_string) '; ' ...
        num2str(quantile(hc_data,0.75),precision_string) ')' ];
    

    stats{1,5} = sum( ~isnan(mci_data) ) ;
    stats{1,6} = [ num2str(quantile(mci_data,0.5),precision_string) ' (' ...
        num2str(quantile(mci_data,0.25),precision_string) '; ' ...
        num2str(quantile(mci_data,0.75),precision_string) ')' ];

    stats{1,7} = sum( ~isnan(ad_data) ) ;
    stats{1,8} = [ num2str(quantile(ad_data,0.5),precision_string) ' (' ...
        num2str(quantile(ad_data,0.25),precision_string) '; ' ...
        num2str(quantile(ad_data,0.75),precision_string) ')' ];

    stats{1,9} = ranksum( hc_data , mci_data );
    stats{1,10} = ranksum( hc_data , ad_data );
    stats{1,11} = ranksum( mci_data , ad_data );
end


function stats = estimate_binary_stats(tbl_var_name,var_name,var_val0,var_val1,precision,data,data_names,all_pos,hc_pos,mci_pos,ad_pos)

    stats{1,1} = tbl_var_name;
    
    precision_string = ['%.' num2str(precision) 'f'];
    
    if ~iscell(data)
        x = data;
        data = cell(0,0);
        for ind = 1:size(x,1)
            if x(ind,1) == 0
                data{ind,1} = 'No';
            elseif x(ind,1) == 1
                data{ind,1} = 'Yes';
            else
                data{ind,1} = '';
            end
        end
    end

    stats{1,2} = sum(strcmp(data(all_pos,strcmp(data_names,var_name)),var_val0) | ...
        strcmp(data(all_pos,strcmp(data_names,var_name)),var_val1)) ;

    stats{1,3} = sum(strcmp(data(hc_pos,strcmp(data_names,var_name)),var_val0) | ...
        strcmp(data(hc_pos,strcmp(data_names,var_name)),var_val1)) ;
    stats{1,4} = [ num2str(sum(strcmp(data(hc_pos,strcmp(data_names,var_name)),var_val1))) ' (' ...
        num2str(100*sum(strcmp(data(hc_pos,strcmp(data_names,var_name)),var_val1))/stats{1,3},precision_string) '%)' ];

    stats{1,5} = sum(strcmp(data(mci_pos,strcmp(data_names,var_name)),var_val0) | ...
        strcmp(data(mci_pos,strcmp(data_names,var_name)),var_val1)) ;
    stats{1,6} = [ num2str(sum(strcmp(data(mci_pos,strcmp(data_names,var_name)),var_val1))) ' (' ...
        num2str(100*sum(strcmp(data(mci_pos,strcmp(data_names,var_name)),var_val1))/stats{1,5},precision_string) '%)' ];

    stats{1,7} = sum(strcmp(data(ad_pos,strcmp(data_names,var_name)),var_val0) | ...
        strcmp(data(ad_pos,strcmp(data_names,var_name)),var_val1)) ;
    stats{1,8} = [ num2str(sum(strcmp(data(ad_pos,strcmp(data_names,var_name)),var_val1))) ' (' ...
        num2str(100*sum(strcmp(data(ad_pos,strcmp(data_names,var_name)),var_val1))/stats{1,7},precision_string) '%)' ];


    x1_1 = [ ones(stats{1,3},1); 2*ones(stats{1,5},1) ];
    x1_2 = [ ones(stats{1,3},1); 2*ones(stats{1,7},1) ];
    x1_3 = [ ones(stats{1,5},1); 2*ones(stats{1,7},1) ];

    x2_1 = NaN*ones(stats{1,3},1);
    x2_1(strcmp( data( hc_pos & ~cellfun(@isempty,data(:,strcmp(data_names,var_name))) , strcmp(data_names,var_name)) , var_val0 ) , 1 ) = 0;
    x2_1(strcmp( data( hc_pos & ~cellfun(@isempty,data(:,strcmp(data_names,var_name))) , strcmp(data_names,var_name)) , var_val1 ) , 1 ) = 1;

    x2_2 = NaN*ones(stats{1,5},1);
    x2_2(strcmp( data( mci_pos & ~cellfun(@isempty,data(:,strcmp(data_names,var_name))) , strcmp(data_names,var_name)) , var_val0 ) , 1 ) = 0;
    x2_2(strcmp( data( mci_pos & ~cellfun(@isempty,data(:,strcmp(data_names,var_name))) , strcmp(data_names,var_name)) , var_val1 ) , 1 ) = 1;

    x2_3 = NaN*ones(stats{1,7},1);
    x2_3(strcmp( data( ad_pos & ~cellfun(@isempty,data(:,strcmp(data_names,var_name))) , strcmp(data_names,var_name)) , var_val0 ) , 1 ) = 0;
    x2_3(strcmp( data( ad_pos & ~cellfun(@isempty,data(:,strcmp(data_names,var_name))) , strcmp(data_names,var_name)) , var_val1 ) , 1 ) = 1;
%     x2_3(strcmp(data(ad_pos,strcmp(data_names,var_name)),var_val0),1) = 0;
%     x2_3(strcmp(data(ad_pos,strcmp(data_names,var_name)),var_val1),1) = 1;

    [~,~,stats{1,9}] = crosstab(x1_1,[x2_1; x2_2]);
    [~,~,stats{1,10}] = crosstab(x1_2,[x2_1; x2_3]);
    [~,~,stats{1,11}] = crosstab(x1_3,[x2_2; x2_3]);
end


function stats = estimate_continuous_stats_included(tbl_var_name,var_name,precision,data,data_names,all_pos,included_pos,excluded_pos)

    stats{1,1} = tbl_var_name;
    
    precision_string = ['%.' num2str(precision) 'f'];
    
    all_data = cell2mat(data(all_pos,strcmp(data_names,var_name)));
    included_data = cell2mat(data(included_pos,strcmp(data_names,var_name)));
    excluded_data = cell2mat(data(excluded_pos,strcmp(data_names,var_name)));
    excluded_data(isnan(excluded_data)) = [];
    

    stats{1,2} = sum( ~isnan(all_data) ) ;

    stats{1,3} = sum( ~isnan(included_data) ) ;
    stats{1,4} = [ num2str(quantile(included_data,0.5),precision_string) ' (' ...
        num2str(quantile(included_data,0.25),precision_string) '; ' ...
        num2str(quantile(included_data,0.75),precision_string) ')' ];

    if ~isempty(excluded_data)
        stats{1,5} = sum( ~isnan(excluded_data) ) ;
        stats{1,6} = [ num2str(quantile(excluded_data,0.5),precision_string) ' (' ...
            num2str(quantile(excluded_data,0.25),precision_string) '; ' ...
            num2str(quantile(excluded_data,0.75),precision_string) ')' ];
    
        stats{1,7} = ranksum( included_data , excluded_data );
    else
        stats{1,5} = [];
        stats{1,6} = [];
        stats{1,7} = [];
    end
end


function stats = estimate_binary_stats_included(tbl_var_name,var_name,var_val0,var_val1,precision,data,data_names,all_pos,included_pos,excluded_pos)

    stats{1,1} = tbl_var_name;
    
    precision_string = ['%.' num2str(precision) 'f'];
    
    if ~iscell(data)
        x = data;
        data = cell(0,0);
        for ind = 1:size(x,1)
            if x(ind,1) == 0
                data{ind,1} = 'No';
            elseif x(ind,1) == 1
                data{ind,1} = 'Yes';
            else
                data{ind,1} = '';
            end
        end
    end

    stats{1,2} = sum(strcmp(data(all_pos,strcmp(data_names,var_name)),var_val0) | ...
        strcmp(data(all_pos,strcmp(data_names,var_name)),var_val1)) ;

    stats{1,3} = sum(strcmp(data(included_pos,strcmp(data_names,var_name)),var_val0) | ...
        strcmp(data(included_pos,strcmp(data_names,var_name)),var_val1)) ;
    stats{1,4} = [ num2str(sum(strcmp(data(included_pos,strcmp(data_names,var_name)),var_val1))) ' (' ...
        num2str(100*sum(strcmp(data(included_pos,strcmp(data_names,var_name)),var_val1))/stats{1,3},precision_string) '%)' ];

    stats{1,5} = sum(strcmp(data(excluded_pos,strcmp(data_names,var_name)),var_val0) | ...
        strcmp(data(excluded_pos,strcmp(data_names,var_name)),var_val1)) ;
    stats{1,6} = [ num2str(sum(strcmp(data(excluded_pos,strcmp(data_names,var_name)),var_val1))) ' (' ...
        num2str(100*sum(strcmp(data(excluded_pos,strcmp(data_names,var_name)),var_val1))/stats{1,5},precision_string) '%)' ];


    x1_1 = [ ones(stats{1,3},1); 2*ones(stats{1,5},1) ];

    x2_1 = NaN*ones(stats{1,3},1);
    x2_1(strcmp( data( included_pos & ~cellfun(@isempty,data(:,strcmp(data_names,var_name))) , strcmp(data_names,var_name)) , var_val0 ) , 1 ) = 0;
    x2_1(strcmp( data( included_pos & ~cellfun(@isempty,data(:,strcmp(data_names,var_name))) , strcmp(data_names,var_name)) , var_val1 ) , 1 ) = 1;

    x2_2 = NaN*ones(stats{1,5},1);
    x2_2(strcmp( data( excluded_pos & ~cellfun(@isempty,data(:,strcmp(data_names,var_name))) , strcmp(data_names,var_name)) , var_val0 ) , 1 ) = 0;
    x2_2(strcmp( data( excluded_pos & ~cellfun(@isempty,data(:,strcmp(data_names,var_name))) , strcmp(data_names,var_name)) , var_val1 ) , 1 ) = 1;

    [~,~,stats{1,7}] = crosstab(x1_1,[x2_1; x2_2]);
end


