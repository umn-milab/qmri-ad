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
xls_file = fullfile(project_folder,'HeartDataset','MasterDataset_01-13.xlsx');
 
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
for ind = 2:size(raw,1)
    if ~isnan(raw{ind,strcmp(raw(1,:),'On Statin')})
        adai_statin{ind,1} = raw{ind,strcmp(raw(1,:),'On Statin')};
        if strcmp(adai_statin{ind,1},'yes')
            adai_statin{ind,1} = 'Yes';
        elseif strcmp(adai_statin{ind,1},'no')
            adai_statin{ind,1} = 'No';
        end
    else
        adai_statin{ind,1} = '';
    end
end
adai_statin = adai_statin(2:end,1);

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

data_names = {'pTau217', 'Age', 'Sex', 'APOE4', 'Abeta42', 'Abeta40',...
    'Height', 'Weight', 'BMI', 'HbA1C', 'HDL', 'LDL', 'Triglycerides', 'AST', 'ALT', 'HeadTrauma', 'HTN', 'HLD', 'IHD', 'Non-IHD', 'Stroke', 'CKD', 'GFR', ...
    'pTau181', 'GFAP', 'NfL', 'MMSE', 'Ancestry', 'Homeless', 'Education',...
    'YKL-40', 'APOE2', 'APOE3', 'APOEprotein', 'Statin', 'Tobacco', 'Alcohol', 'Albumin', 'Epworth', 'Stop-Bang', ...
    'SedPsychSubsMed', 'SedatingMed', 'Anxiety', 'OSA', 'Insomnia', ...
    'Impairment'};

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
    adai_tobacco, ...
    adai_alcohol, ...
    raw(2:end,strcmp(raw(1,:),'Albumin')), ...
    raw(2:end,strcmp(raw(1,:),'Epworth')), ...
    raw(2:end,strcmp(raw(1,:),'Stop-Bang')), ...
    adai_SedPsychSubsMed, ...
    adai_sedatingmed, ...
    adai_osa, ...
    adai_anxiety, ...
    adai_insomnia, ...
    adai_impairment ...
    ];


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
pos_ptau217 = ~isnan(cell2mat(adai(:,strcmp(data_names,'pTau217'))));
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

T_abeta4240_carrier = eye(size(tbl_abeta4240_carrier,2));
T_abeta4240_carrier(1,1) = 0;

mdl_abeta4240 = fitglm(tbl_abeta4240,T_abeta4240);
mdl_abeta42 = fitglm(tbl_abeta42,T_abeta4240);
mdl_abeta40 = fitglm(tbl_abeta40,T_abeta4240);
mdl_ykl40 = fitglm(tbl_ykl40,T_ykl40);
mdl_apoeprotein = fitglm(tbl_apoeprotein,T_apoeprotein);
mdl_ptau217_carrier = fitglm(tbl_ptau217_carrier,T_ptau217_carrier);
mdl_ptau217_allele = fitglm(tbl_ptau217_allele,T_ptau217_carrier);
mdl_gfap_carrier = fitglm(tbl_gfap_carrier,T_ptau217_carrier);
mdl_gfap_allele = fitglm(tbl_gfap_allele,T_ptau217_carrier);
mdl_abeta4240_carrier = fitglm(tbl_abeta4240_carrier,T_abeta4240_carrier);
mdl_abeta4240_allele = fitglm(tbl_abeta4240_allele,T_abeta4240_carrier);


ci_abeta4240 = exp(coefCI(mdl_abeta4240));
ci_abeta42 = exp(coefCI(mdl_abeta42));
ci_abeta40 = exp(coefCI(mdl_abeta40));
ci_ykl40 = exp(coefCI(mdl_ykl40));
ci_apoeprotein = exp(coefCI(mdl_apoeprotein));
ci_ptau217_carrier = exp(coefCI(mdl_ptau217_carrier));
ci_ptau217_allele = exp(coefCI(mdl_ptau217_allele));
ci_gfap_carrier = exp(coefCI(mdl_gfap_carrier));
ci_gfap_allele = exp(coefCI(mdl_gfap_allele));
ci_abeta4240_carrier = exp(coefCI(mdl_abeta4240_carrier));
ci_abeta4240_allele = exp(coefCI(mdl_abeta4240_allele));

%% Loop of linear mixture models
X_list = { 'BMI', 'SedatingMed', 'HeadTrauma', 'HTN', 'HLD', 'IHD', 'Tobacco', 'Epworth', 'Stop-Bang', 'Anxiety', ...
    'HbA1C', 'CKD', 'LDL', 'Triglycerides', 'YKL-40', 'HDL', 'AST', 'ALT', 'Insomnia' };



ptau217 = struct([]);
gfap = struct([]);
ptau217_abeta4240 = struct([]);

for ind = 1:size(X_list,2)
    X_name = X_list{1,ind};
    
    if strcmp(X_name,'YKL-40')
        X = log(cell2mat(adai(:,strcmp(data_names,X_name))));
    elseif strcmp(X_name,'BMI') || strcmp(X_name,'Epworth') || strcmp(X_name,'Stop-Bang') || strcmp(X_name,'HbA1C') || ...
            strcmp(X_name,'GFR') || strcmp(X_name,'LDL') || strcmp(X_name,'Triglycerides') || strcmp(X_name,'HDL') || ...
            strcmp(X_name,'AST') || strcmp(X_name,'ALT')
        X = cell2mat(adai(:,strcmp(data_names,X_name)));
    else
        X = adai(:,strcmp(data_names,X_name));
    end
    
    if ~strcmp(X_name,'CKD')
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
    tbl_ptau217.CKD = categorical(tbl_ptau217.CKD);
    tbl_ptau217.APOE4 = categorical(tbl_ptau217.APOE4);
    
    tbl_gfap.Sex = categorical(tbl_gfap.Sex);
    tbl_gfap.CKD = categorical(tbl_gfap.CKD);
    tbl_gfap.APOE4 = categorical(tbl_gfap.APOE4);
    
    tbl_ptau217_abeta4240.Sex = categorical(tbl_ptau217.Sex);
    tbl_ptau217_abeta4240.CKD = categorical(tbl_ptau217.CKD);
    
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

for ind = 1:size(X_list,2)
%     disp(ptau217(ind,1).mdl)
%     disp(gfap(ind,1).mdl)
    disp(ptau217_abeta4240(ind,1).mdl)
    disp(' ')
    disp('_______________________________________________________________________________________________')
    disp(' ')
end