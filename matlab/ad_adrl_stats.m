%% Initiate
clear all;
clc;
close all;

% addpath('/home/range1-raid1/labounek/git/corrplotg');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Rene -- can you integrate the p-Tau 181, p-Tau 217, GFAP, amyloid beta 42/40 ratio (use the ratio, not the individual values, so you'll need to combine these) and NfL into the Master Spreadsheet? 
% 
% Matti can you make sure that Rene has the most updated Master Spreadsheet possible prior to sending.
% 
% Adam H: where are we with the IRB approval of running the additional APOE testing? We want to get this done ASAP so we can increase our N as much as possible.
% 
% Rene, can you find matched ADNI controls (try to 1:1 match based on age, education, sex, MMSE score, BMI and # of APOE4 alleles).
% 
% Rene, can you also in the Master Spreadsheet flag participants that have an eGFR < 60? These patients may need to be excluded.
% 
% Rene, Once you have this all setup, let me know. We should have all this setup at the latest by Tuesday prior to our 11am meeting.
% 
% Rene -- prior to matching, you'll want to make sure that the ADNI participants have available p-Tau 181 or p-Tau 217 to compare to. They also need amyloid-beta 42/40 ratios, too.  It would be nice, but not required, to have GFAP and NfL. 
% 
% Could you add in the lab data from ARDL for all the labs they sent, and make a new entry for the ratio of amyloid-beta 42/40? Please see my prior email for other items to do. 

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% 20250513
% Hypertension, Ischemic Heart Disease, Hemoglobin A1c, Stroke, Head Trauma, LDL, CKD (GFR>60)
%
% Model 1: Age, Sex, # APOE4 alleles
% 
% Model 2: Age, Sex, # APOE4 alleles, Hypertension, Ischemic Heart Disease, Hemoglobin A1c, Stroke, Head Trauma, LDL, CKD (GFR>60)
% 
% Model 1 and Model 2 with and without amyloid-beta 42/40 (so a total of 4 models).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% 20250610
%
% p-tau 217 = age + sex + APOE4 (# of alleles)  [excluding GFR < 60]
% p-tau 217 = age + sex + APOE4 (# of alleles) + amyloid beta 42/40 + CKD (binary where GFR < 60 = 1; GFR greater than or equal to 60 = 0) + HbA1c + BMI + IHD + stroke
% p-tau 217 = age + sex + APOE4 (carrier = 1; non-carrier = 0)  [excluding GFR < 60]
% p-tau 217 = age + sex + APOE4 (carrier =1; non-carrier = 0) + amyloid beta 42/40 + CKD (binary where GFR < 60 = 1; GFR greater than or equal to 60 = 0) + HbA1c + BMI + IHD + stroke
% 
% GFAP = age + sex + APOE4 (# of alleles)  [excluding GFR < 60]
% GFAP = age + sex + APOE4 (# of alleles) + amyloid beta 42/40 + CKD (binary where GFR < 60 = 1; GFR greater than or equal to 60 = 0) + HbA1c + BMI + IHD + stroke
% GFAP = age + sex + APOE4 (carrier = 1; non-carrier = 0)  [excluding GFR < 60]
% GFAP = age + sex + APOE4 (carrier =1; non-carrier = 0) + amyloid beta 42/40 + CKD (binary where GFR < 60 = 1; GFR greater than or equal to 60 = 0) + HbA1c + BMI + IHD + stroke
% 
% 
% NfL = age + sex + APOE4 (# of alleles)  [excluding GFR < 60]
% NfL = age + sex + APOE4 (# of alleles) + amyloid beta 42/40 + CKD (binary where GFR < 60 = 1; GFR greater than or equal to 60 = 0) + HbA1c + BMI + IHD + stroke
% NfL = age + sex + APOE4 (carrier = 1; non-carrier = 0)  [excluding GFR < 60]
% NfL = age + sex + APOE4 (carrier =1; non-carrier = 0) + amyloid beta 42/40 + CKD (binary where GFR < 60 = 1; GFR greater than or equal to 60 = 0) + HbA1c + BMI + IHD + stroke
% 
% Amyloid-beta 42/40 = age + sex + APOE4 (# of alleles) [do not exclude anyone based on GFR]
% Amyloid-beta 42/40 = age + sex + APOE4 (carrier = 1; non-carrier = 0) [do not exclude anyone based on GFR]
% Amyloid-beta 42/40 = age + sex + APOE4 (carrier =1; non-carrier = 0) + CKD (binary where GFR < 60 = 1; GFR greater than or equal to 60 = 0) + HbA1c + BMI + IHD + stroke
%

data_folder='/home/range1-raid1/labounek/data-on-porto';
project_folder=fullfile(data_folder,'ADAI');
table_folder=fullfile(project_folder,'tables');

include_bmi = 2;

% xls_file = fullfile(project_folder,'HeartDataset','MasterDataset_May12-Rene-version.xlsx');
xls_file = fullfile(project_folder,'HeartDataset','MasterDataset_June14.xlsx');
[~, ~, raw] = xlsread(xls_file);
raw(strcmp(raw,'Male ')) = {'Male'};
raw(strcmp(raw,'Female ')) = {'Female'};
% raw{1,strcmp(raw(1,:),'Please describe alcohol habits (what kind, how much, how often).')} = 'Alcohol habits';
[a,b]=find(strcmp(raw,'NA')==1);
for ind = 1:size(a,1)
    raw{a(ind,1),b(ind,1)} = NaN;
end

gfr = zeros(size(raw,1)-1,1);
for ind = 2:size(raw,1)
    tmp = raw{ind,strcmp(raw(1,:),'GFR')};
    if strcmp(tmp,'>90')
        gfr(ind-1,1) = 95;
    else
        gfr(ind-1,1) = tmp;
    end
end
pos_gfr = [NaN; gfr];
pos_gfr = pos_gfr >= 60;
tmp = [NaN; gfr];
tmp = tmp(pos_gfr);
adai_gfr = cell(0,0);
for ind = 1:size(tmp,1)
    adai_gfr{ind,1} = tmp(ind,1);
end

adai_ihd = strcmp(raw(pos_gfr,strcmp(raw(1,:),'Heart Issues')),'Yes') &  ( strcmp(raw(pos_gfr,strcmp(raw(1,:),'Ischemic vs non-ischemic heart disease ')),'Ischemic ') | strcmp(raw(pos_gfr,strcmp(raw(1,:),'Ischemic vs non-ischemic heart disease ')),'Ischemic') );
adai_ihd_class = cell(size(adai_ihd));
for ind = 1:size(adai_ihd,1)
    if adai_ihd(ind,1) == 1
        adai_ihd_class{ind,1} = 'Yes';
    else
        adai_ihd_class{ind,1} = 'No';
    end
end
adai_ldl = raw(pos_gfr,strcmp(raw(1,:),'LDL'));
for ind = 1:size(adai_ldl,1)
    if strcmp(adai_ldl{ind,1},'< 1')
        adai_ldl{ind,1} = 0.99;
    end
end

pos_allgfr = [NaN; gfr];
pos_allgfr = pos_allgfr >= 0;
tmp = [NaN; gfr];
tmp = tmp(pos_allgfr);
adai_allgfr = cell(0,0);
for ind = 1:size(tmp,1)
    adai_allgfr{ind,1} = tmp(ind,1);
end

adai_allihd = strcmp(raw(pos_allgfr,strcmp(raw(1,:),'Heart Issues')),'Yes') &  ( strcmp(raw(pos_allgfr,strcmp(raw(1,:),'Ischemic vs non-ischemic heart disease ')),'Ischemic ') | strcmp(raw(pos_allgfr,strcmp(raw(1,:),'Ischemic vs non-ischemic heart disease ')),'Ischemic') );
adai_allihd_class = cell(size(adai_allihd));
for ind = 1:size(adai_allihd,1)
    if adai_allihd(ind,1) == 1
        adai_allihd_class{ind,1} = 'Yes';
    else
        adai_allihd_class{ind,1} = 'No';
    end
end
adai_allldl = raw(pos_allgfr,strcmp(raw(1,:),'LDL'));
for ind = 1:size(adai_allldl,1)
    if strcmp(adai_allldl{ind,1},'< 1')
        adai_allldl{ind,1} = 0.99;
    end
end

adai_allckd = cell(0,0);
for ind = 1:size(adai_allgfr,1)
    if adai_allgfr{ind,1} < 60
        adai_allckd{ind,1} = 'Yes';
    elseif adai_allgfr{ind,1} >= 60
        adai_allckd{ind,1} = 'No';
    end
end

data_names = {'pTau217', 'Age', 'Sex', 'APOE4', 'Abeta42', 'Abeta40',...
    'Height', 'Weight', 'BMI', 'HbA1C', 'LDL', 'HTN', 'IHD', 'Stroke', 'CKD', 'GFR', 'pTau181', 'GFAP', 'NfL' };

adai = [
    raw(pos_gfr,strcmp(raw(1,:),'pTau 217')), ...
    raw(pos_gfr,strcmp(raw(1,:),'Age ')), ...
    raw(pos_gfr,strcmp(raw(1,:),'Sex')), ...
    raw(pos_gfr,strcmp(raw(1,:),'APOE e4 mutations')), ...
    raw(pos_gfr,strcmp(raw(1,:),'Abeta 42')), ...
    raw(pos_gfr,strcmp(raw(1,:),'Abeta 40')), ...
    raw(pos_gfr,strcmp(raw(1,:),'Participant height (cm)')), ...
    raw(pos_gfr,strcmp(raw(1,:),'Participant weight (kg) ')), ...
    raw(pos_gfr,strcmp(raw(1,:),'BMI')), ...
    raw(pos_gfr,strcmp(raw(1,:),'HbA1C')), ...
    adai_ldl, ...
    raw(pos_gfr,strcmp(raw(1,:),'HTN ')), ...
    adai_ihd_class, ...
    raw(pos_gfr,strcmp(raw(1,:),'Stroke Hx')), ...
    raw(pos_gfr,strcmp(raw(1,:),'CKD')), ...
    adai_gfr, ...
    raw(pos_gfr,strcmp(raw(1,:),'pTau 181')), ...
    raw(pos_gfr,strcmp(raw(1,:),'GFAP')), ...
    raw(pos_gfr,strcmp(raw(1,:),'NF-light')) ...
    ];

adai_all = [
    raw(pos_allgfr,strcmp(raw(1,:),'pTau 217')), ...
    raw(pos_allgfr,strcmp(raw(1,:),'Age ')), ...
    raw(pos_allgfr,strcmp(raw(1,:),'Sex')), ...
    raw(pos_allgfr,strcmp(raw(1,:),'APOE e4 mutations')), ...
    raw(pos_allgfr,strcmp(raw(1,:),'Abeta 42')), ...
    raw(pos_allgfr,strcmp(raw(1,:),'Abeta 40')), ...
    raw(pos_allgfr,strcmp(raw(1,:),'Participant height (cm)')), ...
    raw(pos_allgfr,strcmp(raw(1,:),'Participant weight (kg) ')), ...
    raw(pos_allgfr,strcmp(raw(1,:),'BMI')), ...
    raw(pos_allgfr,strcmp(raw(1,:),'HbA1C')), ...
    adai_allldl, ...
    raw(pos_allgfr,strcmp(raw(1,:),'HTN ')), ...
    adai_allihd_class, ...
    raw(pos_allgfr,strcmp(raw(1,:),'Stroke Hx')), ...
    adai_allckd, ...
    adai_allgfr, ...
    raw(pos_allgfr,strcmp(raw(1,:),'pTau 181')), ...
    raw(pos_allgfr,strcmp(raw(1,:),'GFAP')), ...
    raw(pos_allgfr,strcmp(raw(1,:),'NF-light')) ...
    ];

adai_allpidn = cell2mat(raw(pos_allgfr,strcmp(raw(1,:),'PIDN')));
adai_allnoapoe4genotype = adai_allpidn(isnan(cell2mat(adai_all(:,strcmp(data_names,'APOE4')))),1);

% Model 2: Age, Sex, # APOE4 alleles, Hypertension, Ischemic Heart Disease, Hemoglobin A1c, Stroke, Head Trauma, LDL, CKD (GFR>60)

adai_female = strcmp(adai(:,strcmp(data_names,'Sex')),'Female');
adai_apoe4 = cell2mat(adai(:,strcmp(data_names,'APOE4')));
adai_abeta4240ratio = cell2mat(adai(:,strcmp(data_names,'Abeta42'))) ./ cell2mat(adai(:,strcmp(data_names,'Abeta40')));

adai_allabeta4240ratio = cell2mat(adai_all(:,strcmp(data_names,'Abeta42'))) ./ cell2mat(adai_all(:,strcmp(data_names,'Abeta40')));

adai_all_apoe4 = adai_all(~isnan(cell2mat(adai_all(:,strcmp(data_names,'APOE4')))),:);
adai_all_apoe4_gfr = cell2mat(adai_allgfr(~isnan(cell2mat(adai_all(:,strcmp(data_names,'APOE4')))),1));
adai_all_apoe4_abeta4240ratio = adai_allabeta4240ratio(~isnan(cell2mat(adai_all(:,strcmp(data_names,'APOE4')))),:);

%% Stats gemography APOE4 genotypes and GFR available
stats_demography{1,2} = ['N=' num2str(size(adai_all_apoe4,1))];
stats_demography{1,3} = 'All participants';
stats_demography{1,4} = ['N=' num2str(sum(cell2mat(adai_all_apoe4(:,strcmp(data_names,'APOE4')))==0)) ' (' num2str(100*sum(cell2mat(adai_all_apoe4(:,strcmp(data_names,'APOE4')))==0)/size(adai_all_apoe4,1),'%.0f') '%)'];
stats_demography{1,5} = 'APOE4 non-carriers';
stats_demography{1,6} = ['N=' num2str(sum(cell2mat(adai_all_apoe4(:,strcmp(data_names,'APOE4')))>=1)) ' (' num2str(100*sum(cell2mat(adai_all_apoe4(:,strcmp(data_names,'APOE4')))>=1)/size(adai_all_apoe4,1),'%.0f') '%)'];
stats_demography{1,7} = 'APOE4 carriers';
stats_demography{1,8} = 'p';

stats_demography{2,1} = 'Females';
stats_demography{3,1} = 'Age [y.o.]';
stats_demography{4,1} = 'Height [cm]';
stats_demography{5,1} = 'Weight [kg]';
stats_demography{6,1} = 'BMI [kg/m^2]';
stats_demography{7,1} = 'pTau217';
stats_demography{8,1} = 'GFAP';
stats_demography{9,1} = 'NfL';
stats_demography{10,1} = 'Abeta42';
stats_demography{11,1} = 'Abeta40';
stats_demography{12,1} = 'Abeta 42/40';
stats_demography{13,1} = 'HbA1C';
stats_demography{14,1} = 'LDL';
stats_demography{15,1} = 'GFR';
stats_demography{16,1} = 'CKD';
stats_demography{17,1} = 'Hypertension';
stats_demography{18,1} = 'IHD';
stats_demography{19,1} = 'Stroke';

stats_demography{2,2} = sum(strcmp(adai_all_apoe4(:,strcmp(data_names,'Sex')),'Male') | ...
    strcmp(adai_all_apoe4(:,strcmp(data_names,'Sex')),'Female')) ;
stats_demography{2,3} = [ num2str(sum(strcmp(adai_all_apoe4(:,strcmp(data_names,'Sex')),'Female'))) ' (' ...
    num2str(100*sum(strcmp(adai_all_apoe4(:,strcmp(data_names,'Sex')),'Female'))/stats_demography{2,2},'%.0f') '%)' ];

stats_demography{2,4} = sum(strcmp(adai_all_apoe4(cell2mat(adai_all_apoe4(:,strcmp(data_names,'APOE4')))==0,strcmp(data_names,'Sex')),'Male') | ...
    strcmp(adai_all_apoe4(cell2mat(adai_all_apoe4(:,strcmp(data_names,'APOE4')))==0,strcmp(data_names,'Sex')),'Female')) ;
stats_demography{2,5} = [ num2str(sum(strcmp(adai_all_apoe4(cell2mat(adai_all_apoe4(:,strcmp(data_names,'APOE4')))==0,strcmp(data_names,'Sex')),'Female'))) ' (' ...
    num2str(100*sum(strcmp(adai_all_apoe4(cell2mat(adai_all_apoe4(:,strcmp(data_names,'APOE4')))==0,strcmp(data_names,'Sex')),'Female'))/stats_demography{2,4},'%.0f') '%)' ];

stats_demography{2,6} = sum(strcmp(adai_all_apoe4(cell2mat(adai_all_apoe4(:,strcmp(data_names,'APOE4')))>=1,strcmp(data_names,'Sex')),'Male') | ...
    strcmp(adai_all_apoe4(cell2mat(adai_all_apoe4(:,strcmp(data_names,'APOE4')))>=1,strcmp(data_names,'Sex')),'Female')) ;
stats_demography{2,7} = [ num2str(sum(strcmp(adai_all_apoe4(cell2mat(adai_all_apoe4(:,strcmp(data_names,'APOE4')))>=1,strcmp(data_names,'Sex')),'Female'))) ' (' ...
    num2str(100*sum(strcmp(adai_all_apoe4(cell2mat(adai_all_apoe4(:,strcmp(data_names,'APOE4')))>=1,strcmp(data_names,'Sex')),'Female'))/stats_demography{2,6},'%.0f') '%)' ];

x1 = [ ones(stats_demography{2,4},1); 2*ones(stats_demography{2,6},1) ];
x2 = [strcmp(adai_all_apoe4(cell2mat(adai_all_apoe4(:,strcmp(data_names,'APOE4')))==0,strcmp(data_names,'Sex')),'Female'); ...
    strcmp(adai_all_apoe4(cell2mat(adai_all_apoe4(:,strcmp(data_names,'APOE4')))>=1,strcmp(data_names,'Sex')),'Female') ];
[~,~,stats_demography{2,8}] = crosstab(x1,x2);

% AGE stats
stats_demography{3,2} = sum(~isnan(cell2mat(adai_all_apoe4(:,strcmp(data_names,'Age')))));
stats_demography{3,4} = sum(~isnan(cell2mat(adai_all_apoe4(cell2mat(adai_all_apoe4(:,strcmp(data_names,'APOE4')))==0,strcmp(data_names,'Age')))));
stats_demography{3,6} = sum(~isnan(cell2mat(adai_all_apoe4(cell2mat(adai_all_apoe4(:,strcmp(data_names,'APOE4')))>=1,strcmp(data_names,'Age')))));

stats_demography{3,3} = [ num2str(quantile(cell2mat(adai_all_apoe4(:,strcmp(data_names,'Age'))),0.5),'%.0f') ' (' ...
    num2str(quantile(cell2mat(adai_all_apoe4(:,strcmp(data_names,'Age'))),0.25),'%.0f') '; ' ...
    num2str(quantile(cell2mat(adai_all_apoe4(:,strcmp(data_names,'Age'))),0.75),'%.0f') ')' ];

stats_demography{3,5} = [ num2str(quantile(cell2mat(adai_all_apoe4(cell2mat(adai_all_apoe4(:,strcmp(data_names,'APOE4')))==0,strcmp(data_names,'Age'))),0.5),'%.0f') ' (' ...
    num2str(quantile(cell2mat(adai_all_apoe4(cell2mat(adai_all_apoe4(:,strcmp(data_names,'APOE4')))==0,strcmp(data_names,'Age'))),0.25),'%.0f') '; ' ...
    num2str(quantile(cell2mat(adai_all_apoe4(cell2mat(adai_all_apoe4(:,strcmp(data_names,'APOE4')))==0,strcmp(data_names,'Age'))),0.75),'%.0f') ')' ];

stats_demography{3,7} = [ num2str(quantile(cell2mat(adai_all_apoe4(cell2mat(adai_all_apoe4(:,strcmp(data_names,'APOE4')))>=1,strcmp(data_names,'Age'))),0.5),'%.0f') ' (' ...
    num2str(quantile(cell2mat(adai_all_apoe4(cell2mat(adai_all_apoe4(:,strcmp(data_names,'APOE4')))>=1,strcmp(data_names,'Age'))),0.25),'%.0f') '; ' ...
    num2str(quantile(cell2mat(adai_all_apoe4(cell2mat(adai_all_apoe4(:,strcmp(data_names,'APOE4')))>=1,strcmp(data_names,'Age'))),0.75),'%.0f') ')' ];

stats_demography{3,8} = ranksum( ...
    cell2mat(adai_all_apoe4(cell2mat(adai_all_apoe4(:,strcmp(data_names,'APOE4')))==0,strcmp(data_names,'Age'))),...
    cell2mat(adai_all_apoe4(cell2mat(adai_all_apoe4(:,strcmp(data_names,'APOE4')))>=1,strcmp(data_names,'Age'))) ...
    );

% HEIGHT stats
stats_demography{4,2} = sum(~isnan(cell2mat(adai_all_apoe4(:,strcmp(data_names,'Height')))));
stats_demography{4,4} = sum(~isnan(cell2mat(adai_all_apoe4(cell2mat(adai_all_apoe4(:,strcmp(data_names,'APOE4')))==0,strcmp(data_names,'Height')))));
stats_demography{4,6} = sum(~isnan(cell2mat(adai_all_apoe4(cell2mat(adai_all_apoe4(:,strcmp(data_names,'APOE4')))>=1,strcmp(data_names,'Height')))));

stats_demography{4,3} = [ num2str(quantile(cell2mat(adai_all_apoe4(:,strcmp(data_names,'Height'))),0.5),'%.0f') ' (' ...
    num2str(quantile(cell2mat(adai_all_apoe4(:,strcmp(data_names,'Height'))),0.25),'%.0f') '; ' ...
    num2str(quantile(cell2mat(adai_all_apoe4(:,strcmp(data_names,'Height'))),0.75),'%.0f') ')' ];

stats_demography{4,5} = [ num2str(quantile(cell2mat(adai_all_apoe4(cell2mat(adai_all_apoe4(:,strcmp(data_names,'APOE4')))==0,strcmp(data_names,'Height'))),0.5),'%.0f') ' (' ...
    num2str(quantile(cell2mat(adai_all_apoe4(cell2mat(adai_all_apoe4(:,strcmp(data_names,'APOE4')))==0,strcmp(data_names,'Height'))),0.25),'%.0f') '; ' ...
    num2str(quantile(cell2mat(adai_all_apoe4(cell2mat(adai_all_apoe4(:,strcmp(data_names,'APOE4')))==0,strcmp(data_names,'Height'))),0.75),'%.0f') ')' ];

stats_demography{4,7} = [ num2str(quantile(cell2mat(adai_all_apoe4(cell2mat(adai_all_apoe4(:,strcmp(data_names,'APOE4')))>=1,strcmp(data_names,'Height'))),0.5),'%.0f') ' (' ...
    num2str(quantile(cell2mat(adai_all_apoe4(cell2mat(adai_all_apoe4(:,strcmp(data_names,'APOE4')))>=1,strcmp(data_names,'Height'))),0.25),'%.0f') '; ' ...
    num2str(quantile(cell2mat(adai_all_apoe4(cell2mat(adai_all_apoe4(:,strcmp(data_names,'APOE4')))>=1,strcmp(data_names,'Height'))),0.75),'%.0f') ')' ];

stats_demography{4,8} = ranksum( ...
    cell2mat(adai_all_apoe4(cell2mat(adai_all_apoe4(:,strcmp(data_names,'APOE4')))==0,strcmp(data_names,'Height'))),...
    cell2mat(adai_all_apoe4(cell2mat(adai_all_apoe4(:,strcmp(data_names,'APOE4')))>=1,strcmp(data_names,'Height'))) ...
    );

% Weight stats
stats_demography{5,2} = sum(~isnan(cell2mat(adai_all_apoe4(:,strcmp(data_names,'Weight')))));
stats_demography{5,4} = sum(~isnan(cell2mat(adai_all_apoe4(cell2mat(adai_all_apoe4(:,strcmp(data_names,'APOE4')))==0,strcmp(data_names,'Weight')))));
stats_demography{5,6} = sum(~isnan(cell2mat(adai_all_apoe4(cell2mat(adai_all_apoe4(:,strcmp(data_names,'APOE4')))>=1,strcmp(data_names,'Weight')))));

stats_demography{5,3} = [ num2str(quantile(cell2mat(adai_all_apoe4(:,strcmp(data_names,'Weight'))),0.5),'%.0f') ' (' ...
    num2str(quantile(cell2mat(adai_all_apoe4(:,strcmp(data_names,'Weight'))),0.25),'%.0f') '; ' ...
    num2str(quantile(cell2mat(adai_all_apoe4(:,strcmp(data_names,'Weight'))),0.75),'%.0f') ')' ];

stats_demography{5,5} = [ num2str(quantile(cell2mat(adai_all_apoe4(cell2mat(adai_all_apoe4(:,strcmp(data_names,'APOE4')))==0,strcmp(data_names,'Weight'))),0.5),'%.0f') ' (' ...
    num2str(quantile(cell2mat(adai_all_apoe4(cell2mat(adai_all_apoe4(:,strcmp(data_names,'APOE4')))==0,strcmp(data_names,'Weight'))),0.25),'%.0f') '; ' ...
    num2str(quantile(cell2mat(adai_all_apoe4(cell2mat(adai_all_apoe4(:,strcmp(data_names,'APOE4')))==0,strcmp(data_names,'Weight'))),0.75),'%.0f') ')' ];

stats_demography{5,7} = [ num2str(quantile(cell2mat(adai_all_apoe4(cell2mat(adai_all_apoe4(:,strcmp(data_names,'APOE4')))>=1,strcmp(data_names,'Weight'))),0.5),'%.0f') ' (' ...
    num2str(quantile(cell2mat(adai_all_apoe4(cell2mat(adai_all_apoe4(:,strcmp(data_names,'APOE4')))>=1,strcmp(data_names,'Weight'))),0.25),'%.0f') '; ' ...
    num2str(quantile(cell2mat(adai_all_apoe4(cell2mat(adai_all_apoe4(:,strcmp(data_names,'APOE4')))>=1,strcmp(data_names,'Weight'))),0.75),'%.0f') ')' ];

stats_demography{5,8} = ranksum( ...
    cell2mat(adai_all_apoe4(cell2mat(adai_all_apoe4(:,strcmp(data_names,'APOE4')))==0,strcmp(data_names,'Weight'))),...
    cell2mat(adai_all_apoe4(cell2mat(adai_all_apoe4(:,strcmp(data_names,'APOE4')))>=1,strcmp(data_names,'Weight'))) ...
    );

% BMI stats
stats_demography{6,2} = sum(~isnan(cell2mat(adai_all_apoe4(:,strcmp(data_names,'BMI')))));
stats_demography{6,4} = sum(~isnan(cell2mat(adai_all_apoe4(cell2mat(adai_all_apoe4(:,strcmp(data_names,'APOE4')))==0,strcmp(data_names,'BMI')))));
stats_demography{6,6} = sum(~isnan(cell2mat(adai_all_apoe4(cell2mat(adai_all_apoe4(:,strcmp(data_names,'APOE4')))>=1,strcmp(data_names,'BMI')))));

stats_demography{6,3} = [ num2str(quantile(cell2mat(adai_all_apoe4(:,strcmp(data_names,'BMI'))),0.5),'%.0f') ' (' ...
    num2str(quantile(cell2mat(adai_all_apoe4(:,strcmp(data_names,'BMI'))),0.25),'%.0f') '; ' ...
    num2str(quantile(cell2mat(adai_all_apoe4(:,strcmp(data_names,'BMI'))),0.75),'%.0f') ')' ];

stats_demography{6,5} = [ num2str(quantile(cell2mat(adai_all_apoe4(cell2mat(adai_all_apoe4(:,strcmp(data_names,'APOE4')))==0,strcmp(data_names,'BMI'))),0.5),'%.0f') ' (' ...
    num2str(quantile(cell2mat(adai_all_apoe4(cell2mat(adai_all_apoe4(:,strcmp(data_names,'APOE4')))==0,strcmp(data_names,'BMI'))),0.25),'%.0f') '; ' ...
    num2str(quantile(cell2mat(adai_all_apoe4(cell2mat(adai_all_apoe4(:,strcmp(data_names,'APOE4')))==0,strcmp(data_names,'BMI'))),0.75),'%.0f') ')' ];

stats_demography{6,7} = [ num2str(quantile(cell2mat(adai_all_apoe4(cell2mat(adai_all_apoe4(:,strcmp(data_names,'APOE4')))>=1,strcmp(data_names,'BMI'))),0.5),'%.0f') ' (' ...
    num2str(quantile(cell2mat(adai_all_apoe4(cell2mat(adai_all_apoe4(:,strcmp(data_names,'APOE4')))>=1,strcmp(data_names,'BMI'))),0.25),'%.0f') '; ' ...
    num2str(quantile(cell2mat(adai_all_apoe4(cell2mat(adai_all_apoe4(:,strcmp(data_names,'APOE4')))>=1,strcmp(data_names,'BMI'))),0.75),'%.0f') ')' ];

stats_demography{6,8} = ranksum( ...
    cell2mat(adai_all_apoe4(cell2mat(adai_all_apoe4(:,strcmp(data_names,'APOE4')))==0,strcmp(data_names,'BMI'))),...
    cell2mat(adai_all_apoe4(cell2mat(adai_all_apoe4(:,strcmp(data_names,'APOE4')))>=1,strcmp(data_names,'BMI'))) ...
    );

% pTau217 stats
stats_demography{7,2} = sum(~isnan(cell2mat(adai_all_apoe4(:,strcmp(data_names,'pTau217')))));
stats_demography{7,4} = sum(~isnan(cell2mat(adai_all_apoe4(cell2mat(adai_all_apoe4(:,strcmp(data_names,'APOE4')))==0,strcmp(data_names,'pTau217')))));
stats_demography{7,6} = sum(~isnan(cell2mat(adai_all_apoe4(cell2mat(adai_all_apoe4(:,strcmp(data_names,'APOE4')))>=1,strcmp(data_names,'pTau217')))));

stats_demography{7,3} = [ num2str(quantile(cell2mat(adai_all_apoe4(:,strcmp(data_names,'pTau217'))),0.5),'%.2f') ' (' ...
    num2str(quantile(cell2mat(adai_all_apoe4(:,strcmp(data_names,'pTau217'))),0.25),'%.2f') '; ' ...
    num2str(quantile(cell2mat(adai_all_apoe4(:,strcmp(data_names,'pTau217'))),0.75),'%.2f') ')' ];

stats_demography{7,5} = [ num2str(quantile(cell2mat(adai_all_apoe4(cell2mat(adai_all_apoe4(:,strcmp(data_names,'APOE4')))==0,strcmp(data_names,'pTau217'))),0.5),'%.2f') ' (' ...
    num2str(quantile(cell2mat(adai_all_apoe4(cell2mat(adai_all_apoe4(:,strcmp(data_names,'APOE4')))==0,strcmp(data_names,'pTau217'))),0.25),'%.2f') '; ' ...
    num2str(quantile(cell2mat(adai_all_apoe4(cell2mat(adai_all_apoe4(:,strcmp(data_names,'APOE4')))==0,strcmp(data_names,'pTau217'))),0.75),'%.2f') ')' ];

stats_demography{7,7} = [ num2str(quantile(cell2mat(adai_all_apoe4(cell2mat(adai_all_apoe4(:,strcmp(data_names,'APOE4')))>=1,strcmp(data_names,'pTau217'))),0.5),'%.2f') ' (' ...
    num2str(quantile(cell2mat(adai_all_apoe4(cell2mat(adai_all_apoe4(:,strcmp(data_names,'APOE4')))>=1,strcmp(data_names,'pTau217'))),0.25),'%.2f') '; ' ...
    num2str(quantile(cell2mat(adai_all_apoe4(cell2mat(adai_all_apoe4(:,strcmp(data_names,'APOE4')))>=1,strcmp(data_names,'pTau217'))),0.75),'%.2f') ')' ];

stats_demography{7,8} = ranksum( ...
    cell2mat(adai_all_apoe4(cell2mat(adai_all_apoe4(:,strcmp(data_names,'APOE4')))==0,strcmp(data_names,'pTau217'))),...
    cell2mat(adai_all_apoe4(cell2mat(adai_all_apoe4(:,strcmp(data_names,'APOE4')))>=1,strcmp(data_names,'pTau217'))) ...
    );

% GFAP stats
stats_demography{8,2} = sum(~isnan(cell2mat(adai_all_apoe4(:,strcmp(data_names,'GFAP')))));
stats_demography{8,4} = sum(~isnan(cell2mat(adai_all_apoe4(cell2mat(adai_all_apoe4(:,strcmp(data_names,'APOE4')))==0,strcmp(data_names,'GFAP')))));
stats_demography{8,6} = sum(~isnan(cell2mat(adai_all_apoe4(cell2mat(adai_all_apoe4(:,strcmp(data_names,'APOE4')))>=1,strcmp(data_names,'GFAP')))));

stats_demography{8,3} = [ num2str(quantile(cell2mat(adai_all_apoe4(:,strcmp(data_names,'GFAP'))),0.5),'%.0f') ' (' ...
    num2str(quantile(cell2mat(adai_all_apoe4(:,strcmp(data_names,'GFAP'))),0.25),'%.0f') '; ' ...
    num2str(quantile(cell2mat(adai_all_apoe4(:,strcmp(data_names,'GFAP'))),0.75),'%.0f') ')' ];

stats_demography{8,5} = [ num2str(quantile(cell2mat(adai_all_apoe4(cell2mat(adai_all_apoe4(:,strcmp(data_names,'APOE4')))==0,strcmp(data_names,'GFAP'))),0.5),'%.0f') ' (' ...
    num2str(quantile(cell2mat(adai_all_apoe4(cell2mat(adai_all_apoe4(:,strcmp(data_names,'APOE4')))==0,strcmp(data_names,'GFAP'))),0.25),'%.0f') '; ' ...
    num2str(quantile(cell2mat(adai_all_apoe4(cell2mat(adai_all_apoe4(:,strcmp(data_names,'APOE4')))==0,strcmp(data_names,'GFAP'))),0.75),'%.0f') ')' ];

stats_demography{8,7} = [ num2str(quantile(cell2mat(adai_all_apoe4(cell2mat(adai_all_apoe4(:,strcmp(data_names,'APOE4')))>=1,strcmp(data_names,'GFAP'))),0.5),'%.0f') ' (' ...
    num2str(quantile(cell2mat(adai_all_apoe4(cell2mat(adai_all_apoe4(:,strcmp(data_names,'APOE4')))>=1,strcmp(data_names,'GFAP'))),0.25),'%.0f') '; ' ...
    num2str(quantile(cell2mat(adai_all_apoe4(cell2mat(adai_all_apoe4(:,strcmp(data_names,'APOE4')))>=1,strcmp(data_names,'GFAP'))),0.75),'%.0f') ')' ];

stats_demography{8,8} = ranksum( ...
    cell2mat(adai_all_apoe4(cell2mat(adai_all_apoe4(:,strcmp(data_names,'APOE4')))==0,strcmp(data_names,'GFAP'))),...
    cell2mat(adai_all_apoe4(cell2mat(adai_all_apoe4(:,strcmp(data_names,'APOE4')))>=1,strcmp(data_names,'GFAP'))) ...
    );

% NfL stats
stats_demography{9,2} = sum(~isnan(cell2mat(adai_all_apoe4(:,strcmp(data_names,'NfL')))));
stats_demography{9,4} = sum(~isnan(cell2mat(adai_all_apoe4(cell2mat(adai_all_apoe4(:,strcmp(data_names,'APOE4')))==0,strcmp(data_names,'NfL')))));
stats_demography{9,6} = sum(~isnan(cell2mat(adai_all_apoe4(cell2mat(adai_all_apoe4(:,strcmp(data_names,'APOE4')))>=1,strcmp(data_names,'NfL')))));

stats_demography{9,3} = [ num2str(quantile(cell2mat(adai_all_apoe4(:,strcmp(data_names,'NfL'))),0.5),'%.0f') ' (' ...
    num2str(quantile(cell2mat(adai_all_apoe4(:,strcmp(data_names,'NfL'))),0.25),'%.0f') '; ' ...
    num2str(quantile(cell2mat(adai_all_apoe4(:,strcmp(data_names,'NfL'))),0.75),'%.0f') ')' ];

stats_demography{9,5} = [ num2str(quantile(cell2mat(adai_all_apoe4(cell2mat(adai_all_apoe4(:,strcmp(data_names,'APOE4')))==0,strcmp(data_names,'NfL'))),0.5),'%.0f') ' (' ...
    num2str(quantile(cell2mat(adai_all_apoe4(cell2mat(adai_all_apoe4(:,strcmp(data_names,'APOE4')))==0,strcmp(data_names,'NfL'))),0.25),'%.0f') '; ' ...
    num2str(quantile(cell2mat(adai_all_apoe4(cell2mat(adai_all_apoe4(:,strcmp(data_names,'APOE4')))==0,strcmp(data_names,'NfL'))),0.75),'%.0f') ')' ];

stats_demography{9,7} = [ num2str(quantile(cell2mat(adai_all_apoe4(cell2mat(adai_all_apoe4(:,strcmp(data_names,'APOE4')))>=1,strcmp(data_names,'NfL'))),0.5),'%.0f') ' (' ...
    num2str(quantile(cell2mat(adai_all_apoe4(cell2mat(adai_all_apoe4(:,strcmp(data_names,'APOE4')))>=1,strcmp(data_names,'NfL'))),0.25),'%.0f') '; ' ...
    num2str(quantile(cell2mat(adai_all_apoe4(cell2mat(adai_all_apoe4(:,strcmp(data_names,'APOE4')))>=1,strcmp(data_names,'NfL'))),0.75),'%.0f') ')' ];

stats_demography{9,8} = ranksum( ...
    cell2mat(adai_all_apoe4(cell2mat(adai_all_apoe4(:,strcmp(data_names,'APOE4')))==0,strcmp(data_names,'NfL'))),...
    cell2mat(adai_all_apoe4(cell2mat(adai_all_apoe4(:,strcmp(data_names,'APOE4')))>=1,strcmp(data_names,'NfL'))) ...
    );

% Abeta42 stats
stats_demography{10,2} = sum(~isnan(cell2mat(adai_all_apoe4(:,strcmp(data_names,'Abeta42')))));
stats_demography{10,4} = sum(~isnan(cell2mat(adai_all_apoe4(cell2mat(adai_all_apoe4(:,strcmp(data_names,'APOE4')))==0,strcmp(data_names,'Abeta42')))));
stats_demography{10,6} = sum(~isnan(cell2mat(adai_all_apoe4(cell2mat(adai_all_apoe4(:,strcmp(data_names,'APOE4')))>=1,strcmp(data_names,'Abeta42')))));

stats_demography{10,3} = [ num2str(quantile(cell2mat(adai_all_apoe4(:,strcmp(data_names,'Abeta42'))),0.5),'%.1f') ' (' ...
    num2str(quantile(cell2mat(adai_all_apoe4(:,strcmp(data_names,'Abeta42'))),0.25),'%.1f') '; ' ...
    num2str(quantile(cell2mat(adai_all_apoe4(:,strcmp(data_names,'Abeta42'))),0.75),'%.1f') ')' ];

stats_demography{10,5} = [ num2str(quantile(cell2mat(adai_all_apoe4(cell2mat(adai_all_apoe4(:,strcmp(data_names,'APOE4')))==0,strcmp(data_names,'Abeta42'))),0.5),'%.1f') ' (' ...
    num2str(quantile(cell2mat(adai_all_apoe4(cell2mat(adai_all_apoe4(:,strcmp(data_names,'APOE4')))==0,strcmp(data_names,'Abeta42'))),0.25),'%.1f') '; ' ...
    num2str(quantile(cell2mat(adai_all_apoe4(cell2mat(adai_all_apoe4(:,strcmp(data_names,'APOE4')))==0,strcmp(data_names,'Abeta42'))),0.75),'%.1f') ')' ];

stats_demography{10,7} = [ num2str(quantile(cell2mat(adai_all_apoe4(cell2mat(adai_all_apoe4(:,strcmp(data_names,'APOE4')))>=1,strcmp(data_names,'Abeta42'))),0.5),'%.1f') ' (' ...
    num2str(quantile(cell2mat(adai_all_apoe4(cell2mat(adai_all_apoe4(:,strcmp(data_names,'APOE4')))>=1,strcmp(data_names,'Abeta42'))),0.25),'%.1f') '; ' ...
    num2str(quantile(cell2mat(adai_all_apoe4(cell2mat(adai_all_apoe4(:,strcmp(data_names,'APOE4')))>=1,strcmp(data_names,'Abeta42'))),0.75),'%.1f') ')' ];

stats_demography{10,8} = ranksum( ...
    cell2mat(adai_all_apoe4(cell2mat(adai_all_apoe4(:,strcmp(data_names,'APOE4')))==0,strcmp(data_names,'Abeta42'))),...
    cell2mat(adai_all_apoe4(cell2mat(adai_all_apoe4(:,strcmp(data_names,'APOE4')))>=1,strcmp(data_names,'Abeta42'))) ...
    );

% Abeta40 stats
stats_demography{11,2} = sum(~isnan(cell2mat(adai_all_apoe4(:,strcmp(data_names,'Abeta40')))));
stats_demography{11,4} = sum(~isnan(cell2mat(adai_all_apoe4(cell2mat(adai_all_apoe4(:,strcmp(data_names,'APOE4')))==0,strcmp(data_names,'Abeta40')))));
stats_demography{11,6} = sum(~isnan(cell2mat(adai_all_apoe4(cell2mat(adai_all_apoe4(:,strcmp(data_names,'APOE4')))>=1,strcmp(data_names,'Abeta40')))));

stats_demography{11,3} = [ num2str(quantile(cell2mat(adai_all_apoe4(:,strcmp(data_names,'Abeta40'))),0.5),'%.1f') ' (' ...
    num2str(quantile(cell2mat(adai_all_apoe4(:,strcmp(data_names,'Abeta40'))),0.25),'%.1f') '; ' ...
    num2str(quantile(cell2mat(adai_all_apoe4(:,strcmp(data_names,'Abeta40'))),0.75),'%.1f') ')' ];

stats_demography{11,5} = [ num2str(quantile(cell2mat(adai_all_apoe4(cell2mat(adai_all_apoe4(:,strcmp(data_names,'APOE4')))==0,strcmp(data_names,'Abeta40'))),0.5),'%.1f') ' (' ...
    num2str(quantile(cell2mat(adai_all_apoe4(cell2mat(adai_all_apoe4(:,strcmp(data_names,'APOE4')))==0,strcmp(data_names,'Abeta40'))),0.25),'%.1f') '; ' ...
    num2str(quantile(cell2mat(adai_all_apoe4(cell2mat(adai_all_apoe4(:,strcmp(data_names,'APOE4')))==0,strcmp(data_names,'Abeta40'))),0.75),'%.1f') ')' ];

stats_demography{11,7} = [ num2str(quantile(cell2mat(adai_all_apoe4(cell2mat(adai_all_apoe4(:,strcmp(data_names,'APOE4')))>=1,strcmp(data_names,'Abeta40'))),0.5),'%.1f') ' (' ...
    num2str(quantile(cell2mat(adai_all_apoe4(cell2mat(adai_all_apoe4(:,strcmp(data_names,'APOE4')))>=1,strcmp(data_names,'Abeta40'))),0.25),'%.1f') '; ' ...
    num2str(quantile(cell2mat(adai_all_apoe4(cell2mat(adai_all_apoe4(:,strcmp(data_names,'APOE4')))>=1,strcmp(data_names,'Abeta40'))),0.75),'%.1f') ')' ];

stats_demography{11,8} = ranksum( ...
    cell2mat(adai_all_apoe4(cell2mat(adai_all_apoe4(:,strcmp(data_names,'APOE4')))==0,strcmp(data_names,'Abeta40'))),...
    cell2mat(adai_all_apoe4(cell2mat(adai_all_apoe4(:,strcmp(data_names,'APOE4')))>=1,strcmp(data_names,'Abeta40'))) ...
    );

% Abeta42/40 stats
stats_demography{12,2} = sum(~isnan(adai_all_apoe4_abeta4240ratio(:,1)));
stats_demography{12,4} = sum(~isnan(adai_all_apoe4_abeta4240ratio(cell2mat(adai_all_apoe4(:,strcmp(data_names,'APOE4')))==0,1)));
stats_demography{12,6} = sum(~isnan(adai_all_apoe4_abeta4240ratio(cell2mat(adai_all_apoe4(:,strcmp(data_names,'APOE4')))>=1,1)));

stats_demography{12,3} = [ num2str(quantile(adai_all_apoe4_abeta4240ratio(:,1),0.5),'%.3f') ' (' ...
    num2str(quantile(adai_all_apoe4_abeta4240ratio(:,1),0.25),'%.3f') '; ' ...
    num2str(quantile(adai_all_apoe4_abeta4240ratio(:,1),0.75),'%.3f') ')' ];

stats_demography{12,5} = [ num2str(quantile(adai_all_apoe4_abeta4240ratio(cell2mat(adai_all_apoe4(:,strcmp(data_names,'APOE4')))==0,1),0.5),'%.3f') ' (' ...
    num2str(quantile(adai_all_apoe4_abeta4240ratio(cell2mat(adai_all_apoe4(:,strcmp(data_names,'APOE4')))==0,1),0.25),'%.3f') '; ' ...
    num2str(quantile(adai_all_apoe4_abeta4240ratio(cell2mat(adai_all_apoe4(:,strcmp(data_names,'APOE4')))==0,1),0.75),'%.3f') ')' ];

stats_demography{12,7} = [ num2str(quantile(adai_all_apoe4_abeta4240ratio(cell2mat(adai_all_apoe4(:,strcmp(data_names,'APOE4')))>=1,1),0.5),'%.3f') ' (' ...
    num2str(quantile(adai_all_apoe4_abeta4240ratio(cell2mat(adai_all_apoe4(:,strcmp(data_names,'APOE4')))>=1,1),0.25),'%.3f') '; ' ...
    num2str(quantile(adai_all_apoe4_abeta4240ratio(cell2mat(adai_all_apoe4(:,strcmp(data_names,'APOE4')))>=1,1),0.75),'%.3f') ')' ];

stats_demography{12,8} = ranksum( ...
    adai_all_apoe4_abeta4240ratio(cell2mat(adai_all_apoe4(:,strcmp(data_names,'APOE4')))==0,1),...
    adai_all_apoe4_abeta4240ratio(cell2mat(adai_all_apoe4(:,strcmp(data_names,'APOE4')))>=1,1) ...
    );

% HbA1C stats
stats_demography{13,2} = sum(~isnan(cell2mat(adai_all_apoe4(:,strcmp(data_names,'HbA1C')))));
stats_demography{13,4} = sum(~isnan(cell2mat(adai_all_apoe4(cell2mat(adai_all_apoe4(:,strcmp(data_names,'APOE4')))==0,strcmp(data_names,'HbA1C')))));
stats_demography{13,6} = sum(~isnan(cell2mat(adai_all_apoe4(cell2mat(adai_all_apoe4(:,strcmp(data_names,'APOE4')))>=1,strcmp(data_names,'HbA1C')))));

stats_demography{13,3} = [ num2str(quantile(cell2mat(adai_all_apoe4(:,strcmp(data_names,'HbA1C'))),0.5),'%.1f') ' (' ...
    num2str(quantile(cell2mat(adai_all_apoe4(:,strcmp(data_names,'HbA1C'))),0.25),'%.1f') '; ' ...
    num2str(quantile(cell2mat(adai_all_apoe4(:,strcmp(data_names,'HbA1C'))),0.75),'%.1f') ')' ];

stats_demography{13,5} = [ num2str(quantile(cell2mat(adai_all_apoe4(cell2mat(adai_all_apoe4(:,strcmp(data_names,'APOE4')))==0,strcmp(data_names,'HbA1C'))),0.5),'%.1f') ' (' ...
    num2str(quantile(cell2mat(adai_all_apoe4(cell2mat(adai_all_apoe4(:,strcmp(data_names,'APOE4')))==0,strcmp(data_names,'HbA1C'))),0.25),'%.1f') '; ' ...
    num2str(quantile(cell2mat(adai_all_apoe4(cell2mat(adai_all_apoe4(:,strcmp(data_names,'APOE4')))==0,strcmp(data_names,'HbA1C'))),0.75),'%.1f') ')' ];

stats_demography{13,7} = [ num2str(quantile(cell2mat(adai_all_apoe4(cell2mat(adai_all_apoe4(:,strcmp(data_names,'APOE4')))>=1,strcmp(data_names,'HbA1C'))),0.5),'%.1f') ' (' ...
    num2str(quantile(cell2mat(adai_all_apoe4(cell2mat(adai_all_apoe4(:,strcmp(data_names,'APOE4')))>=1,strcmp(data_names,'HbA1C'))),0.25),'%.1f') '; ' ...
    num2str(quantile(cell2mat(adai_all_apoe4(cell2mat(adai_all_apoe4(:,strcmp(data_names,'APOE4')))>=1,strcmp(data_names,'HbA1C'))),0.75),'%.1f') ')' ];

stats_demography{13,8} = ranksum( ...
    cell2mat(adai_all_apoe4(cell2mat(adai_all_apoe4(:,strcmp(data_names,'APOE4')))==0,strcmp(data_names,'HbA1C'))),...
    cell2mat(adai_all_apoe4(cell2mat(adai_all_apoe4(:,strcmp(data_names,'APOE4')))>=1,strcmp(data_names,'HbA1C'))) ...
    );

% LDL stats
stats_demography{14,2} = sum(~isnan(cell2mat(adai_all_apoe4(:,strcmp(data_names,'LDL')))));
stats_demography{14,4} = sum(~isnan(cell2mat(adai_all_apoe4(cell2mat(adai_all_apoe4(:,strcmp(data_names,'APOE4')))==0,strcmp(data_names,'LDL')))));
stats_demography{14,6} = sum(~isnan(cell2mat(adai_all_apoe4(cell2mat(adai_all_apoe4(:,strcmp(data_names,'APOE4')))>=1,strcmp(data_names,'LDL')))));

stats_demography{14,3} = [ num2str(quantile(cell2mat(adai_all_apoe4(:,strcmp(data_names,'LDL'))),0.5),'%.0f') ' (' ...
    num2str(quantile(cell2mat(adai_all_apoe4(:,strcmp(data_names,'LDL'))),0.25),'%.0f') '; ' ...
    num2str(quantile(cell2mat(adai_all_apoe4(:,strcmp(data_names,'LDL'))),0.75),'%.0f') ')' ];

stats_demography{14,5} = [ num2str(quantile(cell2mat(adai_all_apoe4(cell2mat(adai_all_apoe4(:,strcmp(data_names,'APOE4')))==0,strcmp(data_names,'LDL'))),0.5),'%.0f') ' (' ...
    num2str(quantile(cell2mat(adai_all_apoe4(cell2mat(adai_all_apoe4(:,strcmp(data_names,'APOE4')))==0,strcmp(data_names,'LDL'))),0.25),'%.0f') '; ' ...
    num2str(quantile(cell2mat(adai_all_apoe4(cell2mat(adai_all_apoe4(:,strcmp(data_names,'APOE4')))==0,strcmp(data_names,'LDL'))),0.75),'%.0f') ')' ];

stats_demography{14,7} = [ num2str(quantile(cell2mat(adai_all_apoe4(cell2mat(adai_all_apoe4(:,strcmp(data_names,'APOE4')))>=1,strcmp(data_names,'LDL'))),0.5),'%.0f') ' (' ...
    num2str(quantile(cell2mat(adai_all_apoe4(cell2mat(adai_all_apoe4(:,strcmp(data_names,'APOE4')))>=1,strcmp(data_names,'LDL'))),0.25),'%.0f') '; ' ...
    num2str(quantile(cell2mat(adai_all_apoe4(cell2mat(adai_all_apoe4(:,strcmp(data_names,'APOE4')))>=1,strcmp(data_names,'LDL'))),0.75),'%.0f') ')' ];

stats_demography{14,8} = ranksum( ...
    cell2mat(adai_all_apoe4(cell2mat(adai_all_apoe4(:,strcmp(data_names,'APOE4')))==0,strcmp(data_names,'LDL'))),...
    cell2mat(adai_all_apoe4(cell2mat(adai_all_apoe4(:,strcmp(data_names,'APOE4')))>=1,strcmp(data_names,'LDL'))) ...
    );

% GFR stats
stats_demography{15,2} = sum(~isnan(cell2mat(adai_all_apoe4(:,strcmp(data_names,'GFR')))));
stats_demography{15,4} = sum(~isnan(cell2mat(adai_all_apoe4(cell2mat(adai_all_apoe4(:,strcmp(data_names,'APOE4')))==0,strcmp(data_names,'GFR')))));
stats_demography{15,6} = sum(~isnan(cell2mat(adai_all_apoe4(cell2mat(adai_all_apoe4(:,strcmp(data_names,'APOE4')))>=1,strcmp(data_names,'GFR')))));

stats_demography{15,3} = [ num2str(quantile(cell2mat(adai_all_apoe4(:,strcmp(data_names,'GFR'))),0.5),'%.0f') ' (' ...
    num2str(quantile(cell2mat(adai_all_apoe4(:,strcmp(data_names,'GFR'))),0.25),'%.0f') '; ' ...
    num2str(quantile(cell2mat(adai_all_apoe4(:,strcmp(data_names,'GFR'))),0.75),'%.0f') ')' ];

stats_demography{15,5} = [ num2str(quantile(cell2mat(adai_all_apoe4(cell2mat(adai_all_apoe4(:,strcmp(data_names,'APOE4')))==0,strcmp(data_names,'GFR'))),0.5),'%.0f') ' (' ...
    num2str(quantile(cell2mat(adai_all_apoe4(cell2mat(adai_all_apoe4(:,strcmp(data_names,'APOE4')))==0,strcmp(data_names,'GFR'))),0.25),'%.0f') '; ' ...
    num2str(quantile(cell2mat(adai_all_apoe4(cell2mat(adai_all_apoe4(:,strcmp(data_names,'APOE4')))==0,strcmp(data_names,'GFR'))),0.75),'%.0f') ')' ];

stats_demography{15,7} = [ num2str(quantile(cell2mat(adai_all_apoe4(cell2mat(adai_all_apoe4(:,strcmp(data_names,'APOE4')))>=1,strcmp(data_names,'GFR'))),0.5),'%.0f') ' (' ...
    num2str(quantile(cell2mat(adai_all_apoe4(cell2mat(adai_all_apoe4(:,strcmp(data_names,'APOE4')))>=1,strcmp(data_names,'GFR'))),0.25),'%.0f') '; ' ...
    num2str(quantile(cell2mat(adai_all_apoe4(cell2mat(adai_all_apoe4(:,strcmp(data_names,'APOE4')))>=1,strcmp(data_names,'GFR'))),0.75),'%.0f') ')' ];

stats_demography{15,8} = ranksum( ...
    cell2mat(adai_all_apoe4(cell2mat(adai_all_apoe4(:,strcmp(data_names,'APOE4')))==0,strcmp(data_names,'GFR'))),...
    cell2mat(adai_all_apoe4(cell2mat(adai_all_apoe4(:,strcmp(data_names,'APOE4')))>=1,strcmp(data_names,'GFR'))) ...
    );

% CKD stats
stats_demography{16,2} = sum(strcmp(adai_all_apoe4(:,strcmp(data_names,'CKD')),'No') | ...
    strcmp(adai_all_apoe4(:,strcmp(data_names,'CKD')),'Yes')) ;
stats_demography{16,3} = [ num2str(sum(strcmp(adai_all_apoe4(:,strcmp(data_names,'CKD')),'Yes'))) ' (' ...
    num2str(100*sum(strcmp(adai_all_apoe4(:,strcmp(data_names,'CKD')),'Yes'))/stats_demography{16,2},'%.0f') '%)' ];

stats_demography{16,4} = sum(strcmp(adai_all_apoe4(cell2mat(adai_all_apoe4(:,strcmp(data_names,'APOE4')))==0,strcmp(data_names,'CKD')),'No') | ...
    strcmp(adai_all_apoe4(cell2mat(adai_all_apoe4(:,strcmp(data_names,'APOE4')))==0,strcmp(data_names,'CKD')),'Yes')) ;
stats_demography{16,5} = [ num2str(sum(strcmp(adai_all_apoe4(cell2mat(adai_all_apoe4(:,strcmp(data_names,'APOE4')))==0,strcmp(data_names,'CKD')),'Yes'))) ' (' ...
    num2str(100*sum(strcmp(adai_all_apoe4(cell2mat(adai_all_apoe4(:,strcmp(data_names,'APOE4')))==0,strcmp(data_names,'CKD')),'Yes'))/stats_demography{16,4},'%.0f') '%)' ];

stats_demography{16,6} = sum(strcmp(adai_all_apoe4(cell2mat(adai_all_apoe4(:,strcmp(data_names,'APOE4')))>=1,strcmp(data_names,'CKD')),'No') | ...
    strcmp(adai_all_apoe4(cell2mat(adai_all_apoe4(:,strcmp(data_names,'APOE4')))>=1,strcmp(data_names,'CKD')),'Yes')) ;
stats_demography{16,7} = [ num2str(sum(strcmp(adai_all_apoe4(cell2mat(adai_all_apoe4(:,strcmp(data_names,'APOE4')))>=1,strcmp(data_names,'CKD')),'Yes'))) ' (' ...
    num2str(100*sum(strcmp(adai_all_apoe4(cell2mat(adai_all_apoe4(:,strcmp(data_names,'APOE4')))>=1,strcmp(data_names,'CKD')),'Yes'))/stats_demography{16,6},'%.0f') '%)' ];

x1 = [ ones(stats_demography{16,4},1); 2*ones(stats_demography{16,6},1) ];
x2 = [strcmp(adai_all_apoe4(cell2mat(adai_all_apoe4(:,strcmp(data_names,'APOE4')))==0,strcmp(data_names,'CKD')),'Yes'); ...
    strcmp(adai_all_apoe4(cell2mat(adai_all_apoe4(:,strcmp(data_names,'APOE4')))>=1,strcmp(data_names,'CKD')),'Yes') ];
[~,~,stats_demography{16,8}] = crosstab(x1,x2);

% HYPERTENSION stats
stats_demography{17,2} = sum(strcmp(adai_all_apoe4(:,strcmp(data_names,'HTN')),'No') | ...
    strcmp(adai_all_apoe4(:,strcmp(data_names,'HTN')),'Yes')) ;
stats_demography{17,3} = [ num2str(sum(strcmp(adai_all_apoe4(:,strcmp(data_names,'HTN')),'Yes'))) ' (' ...
    num2str(100*sum(strcmp(adai_all_apoe4(:,strcmp(data_names,'HTN')),'Yes'))/stats_demography{17,2},'%.0f') '%)' ];

stats_demography{17,4} = sum(strcmp(adai_all_apoe4(cell2mat(adai_all_apoe4(:,strcmp(data_names,'APOE4')))==0,strcmp(data_names,'HTN')),'No') | ...
    strcmp(adai_all_apoe4(cell2mat(adai_all_apoe4(:,strcmp(data_names,'APOE4')))==0,strcmp(data_names,'HTN')),'Yes')) ;
stats_demography{17,5} = [ num2str(sum(strcmp(adai_all_apoe4(cell2mat(adai_all_apoe4(:,strcmp(data_names,'APOE4')))==0,strcmp(data_names,'HTN')),'Yes'))) ' (' ...
    num2str(100*sum(strcmp(adai_all_apoe4(cell2mat(adai_all_apoe4(:,strcmp(data_names,'APOE4')))==0,strcmp(data_names,'HTN')),'Yes'))/stats_demography{17,4},'%.0f') '%)' ];

stats_demography{17,6} = sum(strcmp(adai_all_apoe4(cell2mat(adai_all_apoe4(:,strcmp(data_names,'APOE4')))>=1,strcmp(data_names,'HTN')),'No') | ...
    strcmp(adai_all_apoe4(cell2mat(adai_all_apoe4(:,strcmp(data_names,'APOE4')))>=1,strcmp(data_names,'HTN')),'Yes')) ;
stats_demography{17,7} = [ num2str(sum(strcmp(adai_all_apoe4(cell2mat(adai_all_apoe4(:,strcmp(data_names,'APOE4')))>=1,strcmp(data_names,'HTN')),'Yes'))) ' (' ...
    num2str(100*sum(strcmp(adai_all_apoe4(cell2mat(adai_all_apoe4(:,strcmp(data_names,'APOE4')))>=1,strcmp(data_names,'HTN')),'Yes'))/stats_demography{17,6},'%.0f') '%)' ];

x1 = [ ones(stats_demography{17,4},1); 2*ones(stats_demography{17,6},1) ];
x2 = [strcmp(adai_all_apoe4(cell2mat(adai_all_apoe4(:,strcmp(data_names,'APOE4')))==0,strcmp(data_names,'HTN')),'Yes'); ...
    strcmp(adai_all_apoe4(cell2mat(adai_all_apoe4(:,strcmp(data_names,'APOE4')))>=1,strcmp(data_names,'HTN')),'Yes') ];
[~,~,stats_demography{17,8}] = crosstab(x1,x2);

% IHD stats
stats_demography{18,2} = sum(strcmp(adai_all_apoe4(:,strcmp(data_names,'IHD')),'No') | ...
    strcmp(adai_all_apoe4(:,strcmp(data_names,'IHD')),'Yes')) ;
stats_demography{18,3} = [ num2str(sum(strcmp(adai_all_apoe4(:,strcmp(data_names,'IHD')),'Yes'))) ' (' ...
    num2str(100*sum(strcmp(adai_all_apoe4(:,strcmp(data_names,'IHD')),'Yes'))/stats_demography{18,2},'%.0f') '%)' ];

stats_demography{18,4} = sum(strcmp(adai_all_apoe4(cell2mat(adai_all_apoe4(:,strcmp(data_names,'APOE4')))==0,strcmp(data_names,'IHD')),'No') | ...
    strcmp(adai_all_apoe4(cell2mat(adai_all_apoe4(:,strcmp(data_names,'APOE4')))==0,strcmp(data_names,'IHD')),'Yes')) ;
stats_demography{18,5} = [ num2str(sum(strcmp(adai_all_apoe4(cell2mat(adai_all_apoe4(:,strcmp(data_names,'APOE4')))==0,strcmp(data_names,'IHD')),'Yes'))) ' (' ...
    num2str(100*sum(strcmp(adai_all_apoe4(cell2mat(adai_all_apoe4(:,strcmp(data_names,'APOE4')))==0,strcmp(data_names,'IHD')),'Yes'))/stats_demography{18,4},'%.0f') '%)' ];

stats_demography{18,6} = sum(strcmp(adai_all_apoe4(cell2mat(adai_all_apoe4(:,strcmp(data_names,'APOE4')))>=1,strcmp(data_names,'IHD')),'No') | ...
    strcmp(adai_all_apoe4(cell2mat(adai_all_apoe4(:,strcmp(data_names,'APOE4')))>=1,strcmp(data_names,'IHD')),'Yes')) ;
stats_demography{18,7} = [ num2str(sum(strcmp(adai_all_apoe4(cell2mat(adai_all_apoe4(:,strcmp(data_names,'APOE4')))>=1,strcmp(data_names,'IHD')),'Yes'))) ' (' ...
    num2str(100*sum(strcmp(adai_all_apoe4(cell2mat(adai_all_apoe4(:,strcmp(data_names,'APOE4')))>=1,strcmp(data_names,'IHD')),'Yes'))/stats_demography{18,6},'%.0f') '%)' ];

x1 = [ ones(stats_demography{18,4},1); 2*ones(stats_demography{18,6},1) ];
x2 = [strcmp(adai_all_apoe4(cell2mat(adai_all_apoe4(:,strcmp(data_names,'APOE4')))==0,strcmp(data_names,'IHD')),'Yes'); ...
    strcmp(adai_all_apoe4(cell2mat(adai_all_apoe4(:,strcmp(data_names,'APOE4')))>=1,strcmp(data_names,'IHD')),'Yes') ];
[~,~,stats_demography{18,8}] = crosstab(x1,x2);

% STROKE stats
stats_demography{19,2} = sum(strcmp(adai_all_apoe4(:,strcmp(data_names,'Stroke')),'No') | ...
    strcmp(adai_all_apoe4(:,strcmp(data_names,'Stroke')),'Yes')) ;
stats_demography{19,3} = [ num2str(sum(strcmp(adai_all_apoe4(:,strcmp(data_names,'Stroke')),'Yes'))) ' (' ...
    num2str(100*sum(strcmp(adai_all_apoe4(:,strcmp(data_names,'Stroke')),'Yes'))/stats_demography{19,2},'%.0f') '%)' ];

stats_demography{19,4} = sum(strcmp(adai_all_apoe4(cell2mat(adai_all_apoe4(:,strcmp(data_names,'APOE4')))==0,strcmp(data_names,'Stroke')),'No') | ...
    strcmp(adai_all_apoe4(cell2mat(adai_all_apoe4(:,strcmp(data_names,'APOE4')))==0,strcmp(data_names,'Stroke')),'Yes')) ;
stats_demography{19,5} = [ num2str(sum(strcmp(adai_all_apoe4(cell2mat(adai_all_apoe4(:,strcmp(data_names,'APOE4')))==0,strcmp(data_names,'Stroke')),'Yes'))) ' (' ...
    num2str(100*sum(strcmp(adai_all_apoe4(cell2mat(adai_all_apoe4(:,strcmp(data_names,'APOE4')))==0,strcmp(data_names,'Stroke')),'Yes'))/stats_demography{19,4},'%.0f') '%)' ];

stats_demography{19,6} = sum(strcmp(adai_all_apoe4(cell2mat(adai_all_apoe4(:,strcmp(data_names,'APOE4')))>=1,strcmp(data_names,'Stroke')),'No') | ...
    strcmp(adai_all_apoe4(cell2mat(adai_all_apoe4(:,strcmp(data_names,'APOE4')))>=1,strcmp(data_names,'Stroke')),'Yes')) ;
stats_demography{19,7} = [ num2str(sum(strcmp(adai_all_apoe4(cell2mat(adai_all_apoe4(:,strcmp(data_names,'APOE4')))>=1,strcmp(data_names,'Stroke')),'Yes'))) ' (' ...
    num2str(100*sum(strcmp(adai_all_apoe4(cell2mat(adai_all_apoe4(:,strcmp(data_names,'APOE4')))>=1,strcmp(data_names,'Stroke')),'Yes'))/stats_demography{19,6},'%.0f') '%)' ];

x1 = [ ones(stats_demography{19,4},1); 2*ones(stats_demography{19,6},1) ];
x2 = [strcmp(adai_all_apoe4(cell2mat(adai_all_apoe4(:,strcmp(data_names,'APOE4')))==0,strcmp(data_names,'Stroke')),'Yes'); ...
    strcmp(adai_all_apoe4(cell2mat(adai_all_apoe4(:,strcmp(data_names,'APOE4')))>=1,strcmp(data_names,'Stroke')),'Yes') ];
[~,~,stats_demography{19,8}] = crosstab(x1,x2);

%% Stats demography GFR>=60 only
stats_demography_gfr60plus{1,2} = 'ADAI';
stats_demography_gfr60plus{2,1} = 'Number of subjects';
stats_demography_gfr60plus{3,1} = 'Females';
stats_demography_gfr60plus{4,1} = 'Age [y.o.]';
stats_demography_gfr60plus{5,1} = 'Height [cm]';
stats_demography_gfr60plus{6,1} = 'Weight [kg]';
stats_demography_gfr60plus{7,1} = 'BMI [kg/m^2]';
stats_demography_gfr60plus{8,1} = 'pTau217';
stats_demography_gfr60plus{9,1} = 'Abeta42';
stats_demography_gfr60plus{10,1} = 'Abeta40';
stats_demography_gfr60plus{11,1} = 'Abeta 42/40';
stats_demography_gfr60plus{12,1} = 'APOE4';
stats_demography_gfr60plus{13,1} = 'Non-carrier';
stats_demography_gfr60plus{14,1} = '1-allele';
stats_demography_gfr60plus{15,1} = '2-allele';
stats_demography_gfr60plus{16,1} = 'Unknown';

stats_demography_gfr60plus{2,2} = size(adai,1);
stats_demography_gfr60plus{3,2} = [num2str(sum(adai_female)) ' (' num2str(100*sum(adai_female)/size(adai_female,1),'%.1f') '%)'];
stats_demography_gfr60plus{4,2} = [ num2str(mean(cell2mat(adai(:,strcmp(data_names,'Age')))),'%.1f') '±' num2str(std(cell2mat(adai(:,strcmp(data_names,'Age')))),'%.1f') ];
stats_demography_gfr60plus{5,2} = [ num2str(mean(cell2mat(adai(:,strcmp(data_names,'Height'))),'omitnan'),'%.1f') '±' num2str(std(cell2mat(adai(:,strcmp(data_names,'Height'))),'omitnan'),'%.1f') ' missing: ' num2str(sum(isnan(cell2mat(adai(:,strcmp(data_names,'Height')))))) ];
stats_demography_gfr60plus{6,2} = [ num2str(mean(cell2mat(adai(:,strcmp(data_names,'Weight'))),'omitnan'),'%.1f') '±' num2str(std(cell2mat(adai(:,strcmp(data_names,'Weight'))),'omitnan'),'%.1f') ' missing: ' num2str(sum(isnan(cell2mat(adai(:,strcmp(data_names,'Weight')))))) ];
stats_demography_gfr60plus{7,2} = [ num2str(mean(cell2mat(adai(:,strcmp(data_names,'BMI'))),'omitnan'),'%.1f') '±' num2str(std(cell2mat(adai(:,strcmp(data_names,'BMI'))),'omitnan'),'%.1f') ' missing: ' num2str(sum(isnan(cell2mat(adai(:,strcmp(data_names,'BMI')))))) ];
stats_demography_gfr60plus{8,2} = [ num2str(mean(cell2mat(adai(:,strcmp(data_names,'pTau217'))),'omitnan'),'%.2f') '±' num2str(std(cell2mat(adai(:,strcmp(data_names,'pTau217'))),'omitnan'),'%.2f') ' missing: ' num2str(sum(isnan(cell2mat(adai(:,strcmp(data_names,'pTau217')))))) ];
stats_demography_gfr60plus{9,2} = [ num2str(mean(cell2mat(adai(:,strcmp(data_names,'Abeta42'))),'omitnan'),'%.2f') '±' num2str(std(cell2mat(adai(:,strcmp(data_names,'Abeta42'))),'omitnan'),'%.2f') ' missing: ' num2str(sum(isnan(cell2mat(adai(:,strcmp(data_names,'Abeta42')))))) ];
stats_demography_gfr60plus{10,2} = [ num2str(mean(cell2mat(adai(:,strcmp(data_names,'Abeta40'))),'omitnan'),'%.1f') '±' num2str(std(cell2mat(adai(:,strcmp(data_names,'Abeta40'))),'omitnan'),'%.1f') ' missing: ' num2str(sum(isnan(cell2mat(adai(:,strcmp(data_names,'Abeta40')))))) ];
stats_demography_gfr60plus{11,2} = [ num2str(mean(adai_abeta4240ratio,'omitnan'),'%.3f') '±' num2str(std(adai_abeta4240ratio,'omitnan'),'%.3f') ' missing: ' num2str(sum(isnan(adai_abeta4240ratio))) ];
stats_demography_gfr60plus{13,2} = [num2str(sum(adai_apoe4==0)) ' (' num2str(100*sum(adai_apoe4==0)/size(adai_female,1),'%.1f') '%)'];
stats_demography_gfr60plus{14,2} = [num2str(sum(adai_apoe4==1)) ' (' num2str(100*sum(adai_apoe4==1)/size(adai_female,1),'%.1f') '%)'];
stats_demography_gfr60plus{15,2} = [num2str(sum(adai_apoe4==2)) ' (' num2str(100*sum(adai_apoe4==2)/size(adai_female,1),'%.1f') '%)'];
stats_demography_gfr60plus{16,2} = [num2str(sum(isnan(adai_apoe4))) ' (' num2str(100*sum(isnan(adai_apoe4))/size(adai_female,1),'%.1f') '%)'];

[r, p_r] = corrcoef( cell2mat(adai(:,strcmp(data_names,'pTau217'))) , adai_abeta4240ratio , 'Rows', 'Pairwise');

stats_ptau217 = quantile(cell2mat(adai(:,strcmp(data_names,'pTau217'))), [0.5 0.25 0.75]);
stats_ptau181 = quantile(cell2mat(adai(:,strcmp(data_names,'pTau181'))), [0.5 0.25 0.75]);

%% Linear mixture models

tbl = table( cell2mat(adai(:,strcmp(data_names,'pTau217'))), ...
    cell2mat(adai(:,strcmp(data_names,'APOE4'))), ...
    cell2mat(adai(:,strcmp(data_names,'Age')))/10, ...
    adai(:,strcmp(data_names,'Sex')) , ...
    cell2mat(adai(:,strcmp(data_names,'GFAP')))/100, ...
    cell2mat(adai(:,strcmp(data_names,'NfL')))/100, ...
    adai_abeta4240ratio*10, ...
    'VariableNames', {'pTau217','APOE4','Age','Sex', 'GFAP', 'NfL', 'Abeta42/40'} );
tbl.APOE4 = categorical(tbl.APOE4);
tbl.Sex = categorical(tbl.Sex);

tbl2 = table( cell2mat(adai(:,strcmp(data_names,'pTau217'))), ...
    cell2mat(adai(:,strcmp(data_names,'APOE4'))), ...
    cell2mat(adai(:,strcmp(data_names,'Age')))/10, ...
    adai(:,strcmp(data_names,'Sex')), ...
    cell2mat(adai(:,strcmp(data_names,'HbA1C')))/10, ...
    cell2mat(adai(:,strcmp(data_names,'LDL')))/100, ...
    adai(:,strcmp(data_names,'HTN')), ...
    adai(:,strcmp(data_names,'IHD')), ...
    adai(:,strcmp(data_names,'Stroke')), ...
    cell2mat(adai(:,strcmp(data_names,'GFR')))/10, ...
    cell2mat(adai(:,strcmp(data_names,'GFAP')))/100, ...
    cell2mat(adai(:,strcmp(data_names,'NfL')))/100, ...
    adai_abeta4240ratio*10, ...
    'VariableNames', {'pTau217','APOE4','Age','Sex','HbA1C','LDL', 'HTN', 'IHD', 'Stroke', 'GFR', 'GFAP', 'NfL', 'Abeta42/40'} );
tbl2.APOE4 = categorical(tbl2.APOE4);
tbl2.Sex = categorical(tbl2.Sex);
tbl2.HTN = categorical(tbl2.HTN);
tbl2.IHD = categorical(tbl2.IHD);
tbl2.Stroke = categorical(tbl2.Stroke);
% tbl2.CKD = categorical(tbl2.CKD);

tbl3 = table( cell2mat(adai(:,strcmp(data_names,'pTau217'))), ...
    cell2mat(adai(:,strcmp(data_names,'APOE4'))), ...
    cell2mat(adai(:,strcmp(data_names,'Age')))/10, ...
    adai(:,strcmp(data_names,'Sex')) , ...
    cell2mat(adai(:,strcmp(data_names,'GFAP')))/100, ...
    cell2mat(adai(:,strcmp(data_names,'NfL')))/100, ...
    'VariableNames', {'pTau217','APOE4','Age','Sex', 'GFAP', 'NfL'} );
tbl3.APOE4 = categorical(tbl3.APOE4);
tbl3.Sex = categorical(tbl3.Sex);

tbl4 = table( cell2mat(adai(:,strcmp(data_names,'pTau217'))), ...
    cell2mat(adai(:,strcmp(data_names,'APOE4'))), ...
    cell2mat(adai(:,strcmp(data_names,'Age')))/10, ...
    adai(:,strcmp(data_names,'Sex')), ...
    cell2mat(adai(:,strcmp(data_names,'HbA1C')))/10, ...
    cell2mat(adai(:,strcmp(data_names,'LDL')))/100, ...
    adai(:,strcmp(data_names,'HTN')), ...
    adai(:,strcmp(data_names,'IHD')), ...
    adai(:,strcmp(data_names,'Stroke')), ...
    cell2mat(adai(:,strcmp(data_names,'GFR')))/10, ...
    cell2mat(adai(:,strcmp(data_names,'GFAP')))/100, ...
    cell2mat(adai(:,strcmp(data_names,'NfL')))/100, ...
    'VariableNames', {'pTau217','APOE4','Age','Sex','HbA1C','LDL', 'HTN', 'IHD', 'Stroke', 'GFR', 'GFAP', 'NfL'} );
tbl4.APOE4 = categorical(tbl4.APOE4);
tbl4.Sex = categorical(tbl4.Sex);
tbl4.HTN = categorical(tbl4.HTN);
tbl4.IHD = categorical(tbl4.IHD);
tbl4.Stroke = categorical(tbl4.Stroke);
% tbl4.CKD = categorical(tbl4.CKD);

tbl5 = table( cell2mat(adai_all(:,strcmp(data_names,'pTau217'))), ...
    cell2mat(adai_all(:,strcmp(data_names,'APOE4'))), ...
    cell2mat(adai_all(:,strcmp(data_names,'Age')))/10, ...
    adai_all(:,strcmp(data_names,'Sex')), ...
    cell2mat(adai_all(:,strcmp(data_names,'HbA1C')))/10, ...
    cell2mat(adai_all(:,strcmp(data_names,'LDL')))/100, ...
    adai_all(:,strcmp(data_names,'HTN')), ...
    adai_all(:,strcmp(data_names,'IHD')), ...
    adai_all(:,strcmp(data_names,'Stroke')), ...
    adai_allckd, ...
    cell2mat(adai_all(:,strcmp(data_names,'GFAP')))/100, ...
    cell2mat(adai_all(:,strcmp(data_names,'NfL')))/100, ...
    adai_allabeta4240ratio*10, ...
    'VariableNames', {'pTau217','APOE4','Age','Sex','HbA1C','LDL', 'HTN', 'IHD', 'Stroke', 'CKD', 'GFAP', 'NfL', 'Abeta42/40'} );
tbl5.APOE4 = categorical(tbl5.APOE4);
tbl5.Sex = categorical(tbl5.Sex);
tbl5.HTN = categorical(tbl5.HTN);
tbl5.IHD = categorical(tbl5.IHD);
tbl5.Stroke = categorical(tbl5.Stroke);
tbl5.CKD = categorical(tbl5.CKD);

tbl6 = table( cell2mat(adai_all(:,strcmp(data_names,'pTau217'))), ...
    cell2mat(adai_all(:,strcmp(data_names,'APOE4'))), ...
    cell2mat(adai_all(:,strcmp(data_names,'Age')))/10, ...
    adai_all(:,strcmp(data_names,'Sex')), ...
    cell2mat(adai_all(:,strcmp(data_names,'HbA1C')))/10, ...
    cell2mat(adai_all(:,strcmp(data_names,'LDL')))/100, ...
    adai_all(:,strcmp(data_names,'HTN')), ...
    adai_all(:,strcmp(data_names,'IHD')), ...
    adai_all(:,strcmp(data_names,'Stroke')), ...
    adai_allckd, ...
    cell2mat(adai_all(:,strcmp(data_names,'GFAP')))/100, ...
    cell2mat(adai_all(:,strcmp(data_names,'NfL')))/100, ...
    'VariableNames', {'pTau217','APOE4','Age','Sex','HbA1C','LDL', 'HTN', 'IHD', 'Stroke', 'CKD', 'GFAP', 'NfL'} );
tbl6.APOE4 = categorical(tbl6.APOE4);
tbl6.Sex = categorical(tbl6.Sex);
tbl6.HTN = categorical(tbl6.HTN);
tbl6.IHD = categorical(tbl6.IHD);
tbl6.Stroke = categorical(tbl6.Stroke);
tbl6.CKD = categorical(tbl6.CKD);

tbl_ptau217_model1 = table( cell2mat(adai(:,strcmp(data_names,'pTau217'))), ...
    cell2mat(adai(:,strcmp(data_names,'APOE4'))), ...
    cell2mat(adai(:,strcmp(data_names,'Age')))/10, ...
    adai(:,strcmp(data_names,'Sex')) , ...
    'VariableNames', {'pTau217','APOE4','Age','Sex'} );
tbl_ptau217_model1.APOE4 = categorical(tbl_ptau217_model1.APOE4);
tbl_ptau217_model1.Sex = categorical(tbl_ptau217_model1.Sex);


tbl_ptau217_model2 = table( cell2mat(adai_all(:,strcmp(data_names,'pTau217'))), ...
    cell2mat(adai_all(:,strcmp(data_names,'APOE4'))), ...
    cell2mat(adai_all(:,strcmp(data_names,'Age')))/10, ...
    adai_all(:,strcmp(data_names,'Sex')), ...
    cell2mat(adai_all(:,strcmp(data_names,'HbA1C')))/10, ...
    adai_all(:,strcmp(data_names,'IHD')), ...
    adai_all(:,strcmp(data_names,'Stroke')), ...
    adai_allckd, ...
    adai_allabeta4240ratio*10, ...
    cell2mat(adai_all(:,strcmp(data_names,'BMI'))), ...
    'VariableNames', {'pTau217','APOE4','Age','Sex','HbA1C', 'IHD', 'Stroke', 'CKD', 'Abeta42/40', 'BMI'} );
tbl_ptau217_model2.APOE4 = categorical(tbl_ptau217_model2.APOE4);
tbl_ptau217_model2.Sex = categorical(tbl_ptau217_model2.Sex);
tbl_ptau217_model2.IHD = categorical(tbl_ptau217_model2.IHD);
tbl_ptau217_model2.Stroke = categorical(tbl_ptau217_model2.Stroke);
tbl_ptau217_model2.CKD = categorical(tbl_ptau217_model2.CKD);

tmp_apoe4 = cell2mat(adai(:,strcmp(data_names,'APOE4')));
tmp_apoe4(tmp_apoe4>1) = 1;
tbl_ptau217_model3 = table( cell2mat(adai(:,strcmp(data_names,'pTau217'))), ...
    tmp_apoe4, ...
    cell2mat(adai(:,strcmp(data_names,'Age')))/10, ...
    adai(:,strcmp(data_names,'Sex')) , ...
    'VariableNames', {'pTau217','APOE4','Age','Sex'} );
tbl_ptau217_model3.APOE4 = categorical(tbl_ptau217_model3.APOE4);
tbl_ptau217_model3.Sex = categorical(tbl_ptau217_model3.Sex);

tmp_apoe4 = cell2mat(adai_all(:,strcmp(data_names,'APOE4')));
tmp_apoe4(tmp_apoe4>1) = 1;
tbl_ptau217_model4 = table( cell2mat(adai_all(:,strcmp(data_names,'pTau217'))), ...
    tmp_apoe4, ...
    cell2mat(adai_all(:,strcmp(data_names,'Age')))/10, ...
    adai_all(:,strcmp(data_names,'Sex')), ...
    cell2mat(adai_all(:,strcmp(data_names,'HbA1C')))/10, ...
    adai_all(:,strcmp(data_names,'IHD')), ...
    adai_all(:,strcmp(data_names,'Stroke')), ...
    adai_allckd, ...
    adai_allabeta4240ratio*10, ...
    cell2mat(adai_all(:,strcmp(data_names,'BMI'))), ...
    'VariableNames', {'pTau217','APOE4','Age','Sex','HbA1C', 'IHD', 'Stroke', 'CKD', 'Abeta42/40', 'BMI'} );
tbl_ptau217_model4.APOE4 = categorical(tbl_ptau217_model4.APOE4);
tbl_ptau217_model4.Sex = categorical(tbl_ptau217_model4.Sex);
tbl_ptau217_model4.IHD = categorical(tbl_ptau217_model4.IHD);
tbl_ptau217_model4.Stroke = categorical(tbl_ptau217_model4.Stroke);
tbl_ptau217_model4.CKD = categorical(tbl_ptau217_model4.CKD);

tbl_gfap_model1 = table( cell2mat(adai(:,strcmp(data_names,'GFAP'))), ...
    cell2mat(adai(:,strcmp(data_names,'APOE4'))), ...
    cell2mat(adai(:,strcmp(data_names,'Age')))/10, ...
    adai(:,strcmp(data_names,'Sex')) , ...
    'VariableNames', {'GFAP','APOE4','Age','Sex'} );
tbl_gfap_model1.APOE4 = categorical(tbl_gfap_model1.APOE4);
tbl_gfap_model1.Sex = categorical(tbl_gfap_model1.Sex);

tbl_gfap_model2 = table( cell2mat(adai_all(:,strcmp(data_names,'GFAP'))), ...
    cell2mat(adai_all(:,strcmp(data_names,'APOE4'))), ...
    cell2mat(adai_all(:,strcmp(data_names,'Age')))/10, ...
    adai_all(:,strcmp(data_names,'Sex')), ...
    cell2mat(adai_all(:,strcmp(data_names,'HbA1C')))/10, ...
    adai_all(:,strcmp(data_names,'IHD')), ...
    adai_all(:,strcmp(data_names,'Stroke')), ...
    adai_allckd, ...
    adai_allabeta4240ratio*10, ...
    cell2mat(adai_all(:,strcmp(data_names,'BMI'))), ...
    'VariableNames', {'GFAP','APOE4','Age','Sex','HbA1C', 'IHD', 'Stroke', 'CKD', 'Abeta42/40', 'BMI'} );
tbl_gfap_model2.APOE4 = categorical(tbl_gfap_model2.APOE4);
tbl_gfap_model2.Sex = categorical(tbl_gfap_model2.Sex);
tbl_gfap_model2.IHD = categorical(tbl_gfap_model2.IHD);
tbl_gfap_model2.Stroke = categorical(tbl_gfap_model2.Stroke);
tbl_gfap_model2.CKD = categorical(tbl_gfap_model2.CKD);

tmp_apoe4 = cell2mat(adai(:,strcmp(data_names,'APOE4')));
tmp_apoe4(tmp_apoe4>1) = 1;
tbl_gfap_model3 = table( cell2mat(adai(:,strcmp(data_names,'GFAP'))), ...
    tmp_apoe4, ...
    cell2mat(adai(:,strcmp(data_names,'Age')))/10, ...
    adai(:,strcmp(data_names,'Sex')) , ...
    'VariableNames', {'GFAP','APOE4','Age','Sex'} );
tbl_gfap_model3.APOE4 = categorical(tbl_gfap_model3.APOE4);
tbl_gfap_model3.Sex = categorical(tbl_gfap_model3.Sex);

tmp_apoe4 = cell2mat(adai_all(:,strcmp(data_names,'APOE4')));
tmp_apoe4(tmp_apoe4>1) = 1;
tbl_gfap_model4 = table( cell2mat(adai_all(:,strcmp(data_names,'GFAP'))), ...
    tmp_apoe4, ...
    cell2mat(adai_all(:,strcmp(data_names,'Age')))/10, ...
    adai_all(:,strcmp(data_names,'Sex')), ...
    cell2mat(adai_all(:,strcmp(data_names,'HbA1C')))/10, ...
    adai_all(:,strcmp(data_names,'IHD')), ...
    adai_all(:,strcmp(data_names,'Stroke')), ...
    adai_allckd, ...
    adai_allabeta4240ratio*10, ...
    cell2mat(adai_all(:,strcmp(data_names,'BMI'))), ...
    'VariableNames', {'GFAP','APOE4','Age','Sex','HbA1C', 'IHD', 'Stroke', 'CKD', 'Abeta42/40', 'BMI'} );
tbl_gfap_model4.APOE4 = categorical(tbl_gfap_model4.APOE4);
tbl_gfap_model4.Sex = categorical(tbl_gfap_model4.Sex);
tbl_gfap_model4.IHD = categorical(tbl_gfap_model4.IHD);
tbl_gfap_model4.Stroke = categorical(tbl_gfap_model4.Stroke);
tbl_gfap_model4.CKD = categorical(tbl_gfap_model4.CKD);

tbl_nfl_model1 = table( cell2mat(adai(:,strcmp(data_names,'NfL'))), ...
    cell2mat(adai(:,strcmp(data_names,'APOE4'))), ...
    cell2mat(adai(:,strcmp(data_names,'Age')))/10, ...
    adai(:,strcmp(data_names,'Sex')) , ...
    'VariableNames', {'NfL','APOE4','Age','Sex'} );
tbl_nfl_model1.APOE4 = categorical(tbl_nfl_model1.APOE4);
tbl_nfl_model1.Sex = categorical(tbl_nfl_model1.Sex);

tbl_nfl_model2 = table( cell2mat(adai_all(:,strcmp(data_names,'NfL'))), ...
    cell2mat(adai_all(:,strcmp(data_names,'APOE4'))), ...
    cell2mat(adai_all(:,strcmp(data_names,'Age')))/10, ...
    adai_all(:,strcmp(data_names,'Sex')), ...
    cell2mat(adai_all(:,strcmp(data_names,'HbA1C')))/10, ...
    adai_all(:,strcmp(data_names,'IHD')), ...
    adai_all(:,strcmp(data_names,'Stroke')), ...
    adai_allckd, ...
    adai_allabeta4240ratio*10, ...
    cell2mat(adai_all(:,strcmp(data_names,'BMI'))), ...
    'VariableNames', {'NfL','APOE4','Age','Sex','HbA1C', 'IHD', 'Stroke', 'CKD', 'Abeta42/40', 'BMI'} );
tbl_nfl_model2.APOE4 = categorical(tbl_nfl_model2.APOE4);
tbl_nfl_model2.Sex = categorical(tbl_nfl_model2.Sex);
tbl_nfl_model2.IHD = categorical(tbl_nfl_model2.IHD);
tbl_nfl_model2.Stroke = categorical(tbl_nfl_model2.Stroke);
tbl_nfl_model2.CKD = categorical(tbl_nfl_model2.CKD);

tmp_apoe4 = cell2mat(adai(:,strcmp(data_names,'APOE4')));
tmp_apoe4(tmp_apoe4>1) = 1;
tbl_nfl_model3 = table( cell2mat(adai(:,strcmp(data_names,'NfL'))), ...
    tmp_apoe4, ...
    cell2mat(adai(:,strcmp(data_names,'Age')))/10, ...
    adai(:,strcmp(data_names,'Sex')) , ...
    'VariableNames', {'NfL','APOE4','Age','Sex'} );
tbl_nfl_model3.APOE4 = categorical(tbl_nfl_model3.APOE4);
tbl_nfl_model3.Sex = categorical(tbl_nfl_model3.Sex);

tmp_apoe4 = cell2mat(adai_all(:,strcmp(data_names,'APOE4')));
tmp_apoe4(tmp_apoe4>1) = 1;
tbl_nfl_model4 = table( cell2mat(adai_all(:,strcmp(data_names,'NfL'))), ...
    tmp_apoe4, ...
    cell2mat(adai_all(:,strcmp(data_names,'Age')))/10, ...
    adai_all(:,strcmp(data_names,'Sex')), ...
    cell2mat(adai_all(:,strcmp(data_names,'HbA1C')))/10, ...
    adai_all(:,strcmp(data_names,'IHD')), ...
    adai_all(:,strcmp(data_names,'Stroke')), ...
    adai_allckd, ...
    adai_allabeta4240ratio*10, ...
    cell2mat(adai_all(:,strcmp(data_names,'BMI'))), ...
    'VariableNames', {'NfL','APOE4','Age','Sex','HbA1C', 'IHD', 'Stroke', 'CKD', 'Abeta42/40', 'BMI'} );
tbl_nfl_model4.APOE4 = categorical(tbl_nfl_model4.APOE4);
tbl_nfl_model4.Sex = categorical(tbl_nfl_model4.Sex);
tbl_nfl_model4.IHD = categorical(tbl_nfl_model4.IHD);
tbl_nfl_model4.Stroke = categorical(tbl_nfl_model4.Stroke);
tbl_nfl_model4.CKD = categorical(tbl_nfl_model4.CKD);

tbl_abeta4240_model1 = table( adai_abeta4240ratio*10, ...
    cell2mat(adai(:,strcmp(data_names,'APOE4'))), ...
    cell2mat(adai(:,strcmp(data_names,'Age')))/10, ...
    adai(:,strcmp(data_names,'Sex')) , ...
    'VariableNames', {'Abeta42/40','APOE4','Age','Sex'} );
tbl_abeta4240_model1.APOE4 = categorical(tbl_abeta4240_model1.APOE4);
tbl_abeta4240_model1.Sex = categorical(tbl_abeta4240_model1.Sex);

tbl_abeta4240_model5 = table( adai_allabeta4240ratio*10, ...
    cell2mat(adai_all(:,strcmp(data_names,'APOE4'))), ...
    cell2mat(adai_all(:,strcmp(data_names,'Age')))/10, ...
    adai_all(:,strcmp(data_names,'Sex')), ...
    cell2mat(adai_all(:,strcmp(data_names,'HbA1C')))/10, ...
    adai_all(:,strcmp(data_names,'IHD')), ...
    adai_all(:,strcmp(data_names,'Stroke')), ...
    adai_allckd, ...
    cell2mat(adai_all(:,strcmp(data_names,'BMI'))), ...
    'VariableNames', {'Abeta42/40','APOE4','Age','Sex','HbA1C', 'IHD', 'Stroke', 'CKD', 'BMI'} );
tbl_abeta4240_model5.APOE4 = categorical(tbl_abeta4240_model5.APOE4);
tbl_abeta4240_model5.Sex = categorical(tbl_abeta4240_model5.Sex);
tbl_abeta4240_model5.IHD = categorical(tbl_abeta4240_model5.IHD);
tbl_abeta4240_model5.Stroke = categorical(tbl_abeta4240_model5.Stroke);
tbl_abeta4240_model5.CKD = categorical(tbl_abeta4240_model5.CKD);

tmp_apoe4 = cell2mat(adai(:,strcmp(data_names,'APOE4')));
tmp_apoe4(tmp_apoe4>1) = 1;
tbl_abeta4240_model3 = table( adai_abeta4240ratio*10, ...
    tmp_apoe4, ...
    cell2mat(adai(:,strcmp(data_names,'Age')))/10, ...
    adai(:,strcmp(data_names,'Sex')) , ...
    'VariableNames', {'Abeta42/40','APOE4','Age','Sex'} );
tbl_abeta4240_model3.APOE4 = categorical(tbl_abeta4240_model3.APOE4);
tbl_abeta4240_model3.Sex = categorical(tbl_abeta4240_model3.Sex);

tmp_apoe4 = cell2mat(adai_all(:,strcmp(data_names,'APOE4')));
tmp_apoe4(tmp_apoe4>1) = 1;
tbl_abeta4240_model6 = table( adai_allabeta4240ratio*10, ...
    tmp_apoe4, ...
    cell2mat(adai_all(:,strcmp(data_names,'Age')))/10, ...
    adai_all(:,strcmp(data_names,'Sex')), ...
    cell2mat(adai_all(:,strcmp(data_names,'HbA1C')))/10, ...
    adai_all(:,strcmp(data_names,'IHD')), ...
    adai_all(:,strcmp(data_names,'Stroke')), ...
    adai_allckd, ...
    cell2mat(adai_all(:,strcmp(data_names,'BMI'))), ...
    'VariableNames', {'Abeta42/40','APOE4','Age','Sex','HbA1C', 'IHD', 'Stroke', 'CKD', 'BMI'} );
tbl_abeta4240_model6.APOE4 = categorical(tbl_abeta4240_model6.APOE4);
tbl_abeta4240_model6.Sex = categorical(tbl_abeta4240_model6.Sex);
tbl_abeta4240_model6.IHD = categorical(tbl_abeta4240_model6.IHD);
tbl_abeta4240_model6.Stroke = categorical(tbl_abeta4240_model6.Stroke);
tbl_abeta4240_model6.CKD = categorical(tbl_abeta4240_model6.CKD);

% Age, Sex, # APOE4 alleles, Hypertension, Ischemic Heart Disease, Hemoglobin A1c, Stroke, Head Trauma, LDL, CKD


if include_bmi == 0 || include_bmi == 2
    tbl_ptau217_model2(:,'BMI') = [];
    tbl_ptau217_model4(:,'BMI') = [];
    tbl_gfap_model2(:,'BMI') = [];
    tbl_gfap_model4(:,'BMI') = [];
    tbl_nfl_model2(:,'BMI') = [];
    tbl_nfl_model4(:,'BMI') = [];
    tbl_abeta4240_model5(:,'BMI') = [];
    tbl_abeta4240_model6(:,'BMI') = [];
    if include_bmi == 2
        tbl_ptau217_model2(isnan(cell2mat(adai_all(:,strcmp(data_names,'BMI')))),:) = [];
        tbl_ptau217_model4(isnan(cell2mat(adai_all(:,strcmp(data_names,'BMI')))),:) = [];
        tbl_gfap_model2(isnan(cell2mat(adai_all(:,strcmp(data_names,'BMI')))),:) = [];
        tbl_gfap_model4(isnan(cell2mat(adai_all(:,strcmp(data_names,'BMI')))),:) = [];
        tbl_nfl_model2(isnan(cell2mat(adai_all(:,strcmp(data_names,'BMI')))),:) = [];
        tbl_nfl_model4(isnan(cell2mat(adai_all(:,strcmp(data_names,'BMI')))),:) = [];
        tbl_abeta4240_model5(isnan(cell2mat(adai_all(:,strcmp(data_names,'BMI')))),:) = [];
        tbl_abeta4240_model6(isnan(cell2mat(adai_all(:,strcmp(data_names,'BMI')))),:) = [];
    end
end
    

T = eye(size(tbl,2));
T(1,1) = 0;

T2 = eye(size(tbl2,2));
T2(1,1) = 0;

T3 = eye(size(tbl3,2));
T3(1,1) = 0;

T4 = eye(size(tbl4,2));
T4(1,1) = 0;

T_model1 = eye(size(tbl_ptau217_model1,2));
T_model1(1,1) = 0;

T_model2 = eye(size(tbl_ptau217_model2,2));
T_model2(1,1) = 0;

T_model5 = eye(size(tbl_abeta4240_model5,2));
T_model5(1,1) = 0;

mdl1 = fitglm(tbl,T);
disp(' ')
mdl2 = fitglm(tbl2,T2);
disp(' ')
mdl3 = fitglm(tbl3,T3);
disp(' ')
mdl4 = fitglm(tbl4,T4);
disp(' ')
mdl5 = fitglm(tbl5,T2);
disp(' ')
mdl6 = fitglm(tbl6,T4);
disp(' ')
mdl_ptau217_model1 = fitglm(tbl_ptau217_model1,T_model1);
disp(' ')
mdl_ptau217_model2 = fitglm(tbl_ptau217_model2,T_model2);
disp(' ')
mdl_ptau217_model3 = fitglm(tbl_ptau217_model3,T_model1);
disp(' ')
mdl_ptau217_model4 = fitglm(tbl_ptau217_model4,T_model2);
disp(' ')
mdl_gfap_model1 = fitglm(tbl_gfap_model1,T_model1);
disp(' ')
mdl_gfap_model2 = fitglm(tbl_gfap_model2,T_model2);
disp(' ')
mdl_gfap_model3 = fitglm(tbl_gfap_model3,T_model1);
disp(' ')
mdl_gfap_model4 = fitglm(tbl_gfap_model4,T_model2);
disp(' ')
mdl_nfl_model1 = fitglm(tbl_nfl_model1,T_model1);
disp(' ')
mdl_nfl_model2 = fitglm(tbl_nfl_model2,T_model2);
disp(' ')
mdl_nfl_model3 = fitglm(tbl_nfl_model3,T_model1);
disp(' ')
mdl_nfl_model4 = fitglm(tbl_nfl_model4,T_model2);
disp(' ')
mdl_abeta4240_model1 = fitglm(tbl_abeta4240_model1,T_model1);
disp(' ')
mdl_abeta4240_model5 = fitglm(tbl_abeta4240_model5,T_model5);
disp(' ')
mdl_abeta4240_model3 = fitglm(tbl_abeta4240_model3,T_model1);
disp(' ')
mdl_abeta4240_model6 = fitglm(tbl_abeta4240_model6,T_model5);


ci1 = coefCI(mdl1);
ci2 = coefCI(mdl2);
ci3 = coefCI(mdl3);
ci4 = coefCI(mdl4);
ci5 = coefCI(mdl5);
ci6 = coefCI(mdl6);
ci_ptau217_model1 = coefCI(mdl_ptau217_model1);
ci_ptau217_model2 = coefCI(mdl_ptau217_model2);
ci_ptau217_model3 = coefCI(mdl_ptau217_model3);
ci_ptau217_model4 = coefCI(mdl_ptau217_model4);
ci_gfap_model1 = coefCI(mdl_gfap_model1);
ci_gfap_model2 = coefCI(mdl_gfap_model2);
ci_gfap_model3 = coefCI(mdl_gfap_model3);
ci_gfap_model4 = coefCI(mdl_gfap_model4);
ci_nfl_model1 = coefCI(mdl_nfl_model1);
ci_nfl_model2 = coefCI(mdl_nfl_model2);
ci_nfl_model3 = coefCI(mdl_nfl_model3);
ci_nfl_model4 = coefCI(mdl_nfl_model4);
ci_abeta4240_model1 = coefCI(mdl_abeta4240_model1);
ci_abeta4240_model5 = coefCI(mdl_abeta4240_model5);
ci_abeta4240_model3 = coefCI(mdl_abeta4240_model3);
ci_abeta4240_model6 = coefCI(mdl_abeta4240_model6);

%% Assemble TABLE of regression coefficients
stats_regression{1,1} = 'y';
stats_regression{2,1} = 'pTau217';
stats_regression{6,1} = 'GFAP';
stats_regression{10,1} = 'NfL';
stats_regression{14,1} = 'Abeta42/40';

stats_regression{1,3} = 'GFR<60';
stats_regression(2:2:12,3) = {'Excluding'};
stats_regression(3:2:13,3) = {'Including'};
stats_regression(14:17,3) = {'Including'};

stats_regression{1,4} = ['N (' num2str(size(adai_all,1)) ')'];
stats_regression{1,5} = 'Age [10y]^-1';
stats_regression{1,6} = 'Sex [Male]';
stats_regression{1,7} = 'APOE4 [Hom]';
stats_regression{1,8} = 'APOE4 [Het]';
stats_regression{1,9} = 'APOE4 [Carrier]';
stats_regression{1,10} = 'Abeta42/40';
stats_regression{1,11} = 'CKD';
stats_regression{1,12} = 'HbA1c';
stats_regression{1,13} = 'IHD';
stats_regression{1,14} = 'Stroke';
stats_regression{1,15} = 'BMI';
stats_regression{1,16} = 'R^2';

stats_regression{1,2} = 'Model';
stats_regression(2:4:14,2) = {'Eq. 1'};
stats_regression(3:4:11,2) = {'Eq. 2'};
stats_regression(4:4:16,2) = {'Eq. 3'};
stats_regression(5:4:13,2) = {'Eq. 4'};
stats_regression{15,2} = 'Eq. 5';
stats_regression{17,2} = 'Eq. 6';

%% ptau217 model1
stats_regression{2,4} = mdl_ptau217_model1.NumObservations;

tmp = [ num2str( cell2mat(table2cell(mdl_ptau217_model1.Coefficients('Age','Estimate'))) , '%.3f' ) ' (' ...
    num2str( ci_ptau217_model1(strcmp(mdl_ptau217_model1.CoefficientNames,'Age'),1) , '%.3f' ) '; ' ...
    num2str( ci_ptau217_model1(strcmp(mdl_ptau217_model1.CoefficientNames,'Age'),2) , '%.3f' ) ')' ...
    ];
if cell2mat(table2cell(mdl_ptau217_model1.Coefficients('Age','pValue'))) < 0.05
    tmp = [tmp '*'];
end
stats_regression{2,5} = tmp;

tmp = [ num2str( cell2mat(table2cell(mdl_ptau217_model1.Coefficients('Sex_Male','Estimate'))) , '%.3f' ) ' (' ...
    num2str( ci_ptau217_model1(strcmp(mdl_ptau217_model1.CoefficientNames,'Sex_Male'),1) , '%.3f' ) '; ' ...
    num2str( ci_ptau217_model1(strcmp(mdl_ptau217_model1.CoefficientNames,'Sex_Male'),2) , '%.3f' ) ')' ...
    ];
if cell2mat(table2cell(mdl_ptau217_model1.Coefficients('Sex_Male','pValue'))) < 0.05
    tmp = [tmp '*'];
end
stats_regression{2,6} = tmp;

tmp = [ num2str( cell2mat(table2cell(mdl_ptau217_model1.Coefficients('APOE4_2','Estimate'))) , '%.3f' ) ' (' ...
    num2str( ci_ptau217_model1(strcmp(mdl_ptau217_model1.CoefficientNames,'APOE4_2'),1) , '%.3f' ) '; ' ...
    num2str( ci_ptau217_model1(strcmp(mdl_ptau217_model1.CoefficientNames,'APOE4_2'),2) , '%.3f' ) ')' ...
    ];
if cell2mat(table2cell(mdl_ptau217_model1.Coefficients('APOE4_2','pValue'))) < 0.05
    tmp = [tmp '*'];
end
stats_regression{2,7} = tmp;

tmp = [ num2str( cell2mat(table2cell(mdl_ptau217_model1.Coefficients('APOE4_1','Estimate'))) , '%.3f' ) ' (' ...
    num2str( ci_ptau217_model1(strcmp(mdl_ptau217_model1.CoefficientNames,'APOE4_1'),1) , '%.3f' ) '; ' ...
    num2str( ci_ptau217_model1(strcmp(mdl_ptau217_model1.CoefficientNames,'APOE4_1'),2) , '%.3f' ) ')' ...
    ];
if cell2mat(table2cell(mdl_ptau217_model1.Coefficients('APOE4_1','pValue'))) < 0.05
    tmp = [tmp '*'];
end
stats_regression{2,8} = tmp;

stats_regression{2,16} = mdl_ptau217_model1.Rsquared.Ordinary;

%% ptau217 model2

stats_regression{3,4} = mdl_ptau217_model2.NumObservations;

tmp = [ num2str( cell2mat(table2cell(mdl_ptau217_model2.Coefficients('Age','Estimate'))) , '%.3f' ) ' (' ...
    num2str( ci_ptau217_model2(strcmp(mdl_ptau217_model2.CoefficientNames,'Age'),1) , '%.3f' ) '; ' ...
    num2str( ci_ptau217_model2(strcmp(mdl_ptau217_model2.CoefficientNames,'Age'),2) , '%.3f' ) ')' ...
    ];
if cell2mat(table2cell(mdl_ptau217_model2.Coefficients('Age','pValue'))) < 0.05
    tmp = [tmp '*'];
end
stats_regression{3,5} = tmp;

tmp = [ num2str( cell2mat(table2cell(mdl_ptau217_model2.Coefficients('Sex_Male','Estimate'))) , '%.3f' ) ' (' ...
    num2str( ci_ptau217_model2(strcmp(mdl_ptau217_model2.CoefficientNames,'Sex_Male'),1) , '%.3f' ) '; ' ...
    num2str( ci_ptau217_model2(strcmp(mdl_ptau217_model2.CoefficientNames,'Sex_Male'),2) , '%.3f' ) ')' ...
    ];
if cell2mat(table2cell(mdl_ptau217_model2.Coefficients('Sex_Male','pValue'))) < 0.05
    tmp = [tmp '*'];
end
stats_regression{3,6} = tmp;

tmp = [ num2str( cell2mat(table2cell(mdl_ptau217_model2.Coefficients('APOE4_2','Estimate'))) , '%.3f' ) ' (' ...
    num2str( ci_ptau217_model2(strcmp(mdl_ptau217_model2.CoefficientNames,'APOE4_2'),1) , '%.3f' ) '; ' ...
    num2str( ci_ptau217_model2(strcmp(mdl_ptau217_model2.CoefficientNames,'APOE4_2'),2) , '%.3f' ) ')' ...
    ];
if cell2mat(table2cell(mdl_ptau217_model2.Coefficients('APOE4_2','pValue'))) < 0.05
    tmp = [tmp '*'];
end
stats_regression{3,7} = tmp;

tmp = [ num2str( cell2mat(table2cell(mdl_ptau217_model2.Coefficients('APOE4_1','Estimate'))) , '%.3f' ) ' (' ...
    num2str( ci_ptau217_model2(strcmp(mdl_ptau217_model2.CoefficientNames,'APOE4_1'),1) , '%.3f' ) '; ' ...
    num2str( ci_ptau217_model2(strcmp(mdl_ptau217_model2.CoefficientNames,'APOE4_1'),2) , '%.3f' ) ')' ...
    ];
if cell2mat(table2cell(mdl_ptau217_model2.Coefficients('APOE4_1','pValue'))) < 0.05
    tmp = [tmp '*'];
end
stats_regression{3,8} = tmp;

tmp = [ num2str( cell2mat(table2cell(mdl_ptau217_model2.Coefficients('Abeta42/40','Estimate'))) , '%.3f' ) ' (' ...
    num2str( ci_ptau217_model2(strcmp(mdl_ptau217_model2.CoefficientNames,'Abeta42/40'),1) , '%.3f' ) '; ' ...
    num2str( ci_ptau217_model2(strcmp(mdl_ptau217_model2.CoefficientNames,'Abeta42/40'),2) , '%.3f' ) ')' ...
    ];
if cell2mat(table2cell(mdl_ptau217_model2.Coefficients('Abeta42/40','pValue'))) < 0.05
    tmp = [tmp '*'];
end
stats_regression{3,10} = tmp;

tmp = [ num2str( cell2mat(table2cell(mdl_ptau217_model2.Coefficients('CKD_Yes','Estimate'))) , '%.3f' ) ' (' ...
    num2str( ci_ptau217_model2(strcmp(mdl_ptau217_model2.CoefficientNames,'CKD_Yes'),1) , '%.3f' ) '; ' ...
    num2str( ci_ptau217_model2(strcmp(mdl_ptau217_model2.CoefficientNames,'CKD_Yes'),2) , '%.3f' ) ')' ...
    ];
if cell2mat(table2cell(mdl_ptau217_model2.Coefficients('CKD_Yes','pValue'))) < 0.05
    tmp = [tmp '*'];
end
stats_regression{3,11} = tmp;

tmp = [ num2str( cell2mat(table2cell(mdl_ptau217_model2.Coefficients('HbA1C','Estimate'))) , '%.3f' ) ' (' ...
    num2str( ci_ptau217_model2(strcmp(mdl_ptau217_model2.CoefficientNames,'HbA1C'),1) , '%.3f' ) '; ' ...
    num2str( ci_ptau217_model2(strcmp(mdl_ptau217_model2.CoefficientNames,'HbA1C'),2) , '%.3f' ) ')' ...
    ];
if cell2mat(table2cell(mdl_ptau217_model2.Coefficients('HbA1C','pValue'))) < 0.05
    tmp = [tmp '*'];
end
stats_regression{3,12} = tmp;

tmp = [ num2str( cell2mat(table2cell(mdl_ptau217_model2.Coefficients('IHD_Yes','Estimate'))) , '%.3f' ) ' (' ...
    num2str( ci_ptau217_model2(strcmp(mdl_ptau217_model2.CoefficientNames,'IHD_Yes'),1) , '%.3f' ) '; ' ...
    num2str( ci_ptau217_model2(strcmp(mdl_ptau217_model2.CoefficientNames,'IHD_Yes'),2) , '%.3f' ) ')' ...
    ];
if cell2mat(table2cell(mdl_ptau217_model2.Coefficients('IHD_Yes','pValue'))) < 0.05
    tmp = [tmp '*'];
end
stats_regression{3,13} = tmp;

tmp = [ num2str( cell2mat(table2cell(mdl_ptau217_model2.Coefficients('Stroke_Yes','Estimate'))) , '%.3f' ) ' (' ...
    num2str( ci_ptau217_model2(strcmp(mdl_ptau217_model2.CoefficientNames,'Stroke_Yes'),1) , '%.3f' ) '; ' ...
    num2str( ci_ptau217_model2(strcmp(mdl_ptau217_model2.CoefficientNames,'Stroke_Yes'),2) , '%.3f' ) ')' ...
    ];
if cell2mat(table2cell(mdl_ptau217_model2.Coefficients('Stroke_Yes','pValue'))) < 0.05
    tmp = [tmp '*'];
end
stats_regression{3,14} = tmp;

if include_bmi == 1
    tmp = [ num2str( cell2mat(table2cell(mdl_ptau217_model2.Coefficients('BMI','Estimate'))) , '%.3f' ) ' (' ...
        num2str( ci_ptau217_model2(strcmp(mdl_ptau217_model2.CoefficientNames,'BMI'),1) , '%.3f' ) '; ' ...
        num2str( ci_ptau217_model2(strcmp(mdl_ptau217_model2.CoefficientNames,'BMI'),2) , '%.3f' ) ')' ...
        ];
    if cell2mat(table2cell(mdl_ptau217_model2.Coefficients('BMI','pValue'))) < 0.05
        tmp = [tmp '*'];
    end
    stats_regression{3,15} = tmp;
end

stats_regression{3,16} = mdl_ptau217_model2.Rsquared.Ordinary;

%% ptau217 model3
stats_regression{4,4} = mdl_ptau217_model3.NumObservations;

tmp = [ num2str( cell2mat(table2cell(mdl_ptau217_model3.Coefficients('Age','Estimate'))) , '%.3f' ) ' (' ...
    num2str( ci_ptau217_model3(strcmp(mdl_ptau217_model3.CoefficientNames,'Age'),1) , '%.3f' ) '; ' ...
    num2str( ci_ptau217_model3(strcmp(mdl_ptau217_model3.CoefficientNames,'Age'),2) , '%.3f' ) ')' ...
    ];
if cell2mat(table2cell(mdl_ptau217_model3.Coefficients('Age','pValue'))) < 0.05
    tmp = [tmp '*'];
end
stats_regression{4,5} = tmp;

tmp = [ num2str( cell2mat(table2cell(mdl_ptau217_model3.Coefficients('Sex_Male','Estimate'))) , '%.3f' ) ' (' ...
    num2str( ci_ptau217_model3(strcmp(mdl_ptau217_model3.CoefficientNames,'Sex_Male'),1) , '%.3f' ) '; ' ...
    num2str( ci_ptau217_model3(strcmp(mdl_ptau217_model3.CoefficientNames,'Sex_Male'),2) , '%.3f' ) ')' ...
    ];
if cell2mat(table2cell(mdl_ptau217_model3.Coefficients('Sex_Male','pValue'))) < 0.05
    tmp = [tmp '*'];
end
stats_regression{4,6} = tmp;

tmp = [ num2str( cell2mat(table2cell(mdl_ptau217_model3.Coefficients('APOE4_1','Estimate'))) , '%.3f' ) ' (' ...
    num2str( ci_ptau217_model3(strcmp(mdl_ptau217_model3.CoefficientNames,'APOE4_1'),1) , '%.3f' ) '; ' ...
    num2str( ci_ptau217_model3(strcmp(mdl_ptau217_model3.CoefficientNames,'APOE4_1'),2) , '%.3f' ) ')' ...
    ];
if cell2mat(table2cell(mdl_ptau217_model3.Coefficients('APOE4_1','pValue'))) < 0.05
    tmp = [tmp '*'];
end
stats_regression{4,9} = tmp;

stats_regression{4,16} = mdl_ptau217_model3.Rsquared.Ordinary;

%% ptau217 model4

stats_regression{5,4} = mdl_ptau217_model4.NumObservations;

tmp = [ num2str( cell2mat(table2cell(mdl_ptau217_model4.Coefficients('Age','Estimate'))) , '%.3f' ) ' (' ...
    num2str( ci_ptau217_model4(strcmp(mdl_ptau217_model4.CoefficientNames,'Age'),1) , '%.3f' ) '; ' ...
    num2str( ci_ptau217_model4(strcmp(mdl_ptau217_model4.CoefficientNames,'Age'),2) , '%.3f' ) ')' ...
    ];
if cell2mat(table2cell(mdl_ptau217_model4.Coefficients('Age','pValue'))) < 0.05
    tmp = [tmp '*'];
end
stats_regression{5,5} = tmp;

tmp = [ num2str( cell2mat(table2cell(mdl_ptau217_model4.Coefficients('Sex_Male','Estimate'))) , '%.3f' ) ' (' ...
    num2str( ci_ptau217_model4(strcmp(mdl_ptau217_model4.CoefficientNames,'Sex_Male'),1) , '%.3f' ) '; ' ...
    num2str( ci_ptau217_model4(strcmp(mdl_ptau217_model4.CoefficientNames,'Sex_Male'),2) , '%.3f' ) ')' ...
    ];
if cell2mat(table2cell(mdl_ptau217_model4.Coefficients('Sex_Male','pValue'))) < 0.05
    tmp = [tmp '*'];
end
stats_regression{5,6} = tmp;

tmp = [ num2str( cell2mat(table2cell(mdl_ptau217_model4.Coefficients('APOE4_1','Estimate'))) , '%.3f' ) ' (' ...
    num2str( ci_ptau217_model4(strcmp(mdl_ptau217_model4.CoefficientNames,'APOE4_1'),1) , '%.3f' ) '; ' ...
    num2str( ci_ptau217_model4(strcmp(mdl_ptau217_model4.CoefficientNames,'APOE4_1'),2) , '%.3f' ) ')' ...
    ];
if cell2mat(table2cell(mdl_ptau217_model4.Coefficients('APOE4_1','pValue'))) < 0.05
    tmp = [tmp '*'];
end
stats_regression{5,9} = tmp;

tmp = [ num2str( cell2mat(table2cell(mdl_ptau217_model4.Coefficients('Abeta42/40','Estimate'))) , '%.3f' ) ' (' ...
    num2str( ci_ptau217_model4(strcmp(mdl_ptau217_model4.CoefficientNames,'Abeta42/40'),1) , '%.3f' ) '; ' ...
    num2str( ci_ptau217_model4(strcmp(mdl_ptau217_model4.CoefficientNames,'Abeta42/40'),2) , '%.3f' ) ')' ...
    ];
if cell2mat(table2cell(mdl_ptau217_model4.Coefficients('Abeta42/40','pValue'))) < 0.05
    tmp = [tmp '*'];
end
stats_regression{5,10} = tmp;

tmp = [ num2str( cell2mat(table2cell(mdl_ptau217_model4.Coefficients('CKD_Yes','Estimate'))) , '%.3f' ) ' (' ...
    num2str( ci_ptau217_model4(strcmp(mdl_ptau217_model4.CoefficientNames,'CKD_Yes'),1) , '%.3f' ) '; ' ...
    num2str( ci_ptau217_model4(strcmp(mdl_ptau217_model4.CoefficientNames,'CKD_Yes'),2) , '%.3f' ) ')' ...
    ];
if cell2mat(table2cell(mdl_ptau217_model4.Coefficients('CKD_Yes','pValue'))) < 0.05
    tmp = [tmp '*'];
end
stats_regression{5,11} = tmp;

tmp = [ num2str( cell2mat(table2cell(mdl_ptau217_model4.Coefficients('HbA1C','Estimate'))) , '%.3f' ) ' (' ...
    num2str( ci_ptau217_model4(strcmp(mdl_ptau217_model4.CoefficientNames,'HbA1C'),1) , '%.3f' ) '; ' ...
    num2str( ci_ptau217_model4(strcmp(mdl_ptau217_model4.CoefficientNames,'HbA1C'),2) , '%.3f' ) ')' ...
    ];
if cell2mat(table2cell(mdl_ptau217_model4.Coefficients('HbA1C','pValue'))) < 0.05
    tmp = [tmp '*'];
end
stats_regression{5,12} = tmp;

tmp = [ num2str( cell2mat(table2cell(mdl_ptau217_model4.Coefficients('IHD_Yes','Estimate'))) , '%.3f' ) ' (' ...
    num2str( ci_ptau217_model4(strcmp(mdl_ptau217_model4.CoefficientNames,'IHD_Yes'),1) , '%.3f' ) '; ' ...
    num2str( ci_ptau217_model4(strcmp(mdl_ptau217_model4.CoefficientNames,'IHD_Yes'),2) , '%.3f' ) ')' ...
    ];
if cell2mat(table2cell(mdl_ptau217_model4.Coefficients('IHD_Yes','pValue'))) < 0.05
    tmp = [tmp '*'];
end
stats_regression{5,13} = tmp;

tmp = [ num2str( cell2mat(table2cell(mdl_ptau217_model4.Coefficients('Stroke_Yes','Estimate'))) , '%.3f' ) ' (' ...
    num2str( ci_ptau217_model4(strcmp(mdl_ptau217_model4.CoefficientNames,'Stroke_Yes'),1) , '%.3f' ) '; ' ...
    num2str( ci_ptau217_model4(strcmp(mdl_ptau217_model4.CoefficientNames,'Stroke_Yes'),2) , '%.3f' ) ')' ...
    ];
if cell2mat(table2cell(mdl_ptau217_model4.Coefficients('Stroke_Yes','pValue'))) < 0.05
    tmp = [tmp '*'];
end
stats_regression{5,14} = tmp;

if include_bmi == 1
    tmp = [ num2str( cell2mat(table2cell(mdl_ptau217_model4.Coefficients('BMI','Estimate'))) , '%.3f' ) ' (' ...
        num2str( ci_ptau217_model4(strcmp(mdl_ptau217_model4.CoefficientNames,'BMI'),1) , '%.3f' ) '; ' ...
        num2str( ci_ptau217_model4(strcmp(mdl_ptau217_model4.CoefficientNames,'BMI'),2) , '%.3f' ) ')' ...
        ];
    if cell2mat(table2cell(mdl_ptau217_model4.Coefficients('BMI','pValue'))) < 0.05
        tmp = [tmp '*'];
    end
    stats_regression{5,15} = tmp;
end

stats_regression{5,16} = mdl_ptau217_model4.Rsquared.Ordinary;

%% gfap model1
stats_regression{6,4} = mdl_gfap_model1.NumObservations;

tmp = [ num2str( cell2mat(table2cell(mdl_gfap_model1.Coefficients('Age','Estimate'))) , '%.1f' ) ' (' ...
    num2str( ci_gfap_model1(strcmp(mdl_gfap_model1.CoefficientNames,'Age'),1) , '%.1f' ) '; ' ...
    num2str( ci_gfap_model1(strcmp(mdl_gfap_model1.CoefficientNames,'Age'),2) , '%.1f' ) ')' ...
    ];
if cell2mat(table2cell(mdl_gfap_model1.Coefficients('Age','pValue'))) < 0.05
    tmp = [tmp '*'];
end
stats_regression{6,5} = tmp;

tmp = [ num2str( cell2mat(table2cell(mdl_gfap_model1.Coefficients('Sex_Male','Estimate'))) , '%.1f' ) ' (' ...
    num2str( ci_gfap_model1(strcmp(mdl_gfap_model1.CoefficientNames,'Sex_Male'),1) , '%.1f' ) '; ' ...
    num2str( ci_gfap_model1(strcmp(mdl_gfap_model1.CoefficientNames,'Sex_Male'),2) , '%.1f' ) ')' ...
    ];
if cell2mat(table2cell(mdl_gfap_model1.Coefficients('Sex_Male','pValue'))) < 0.05
    tmp = [tmp '*'];
end
stats_regression{6,6} = tmp;

tmp = [ num2str( cell2mat(table2cell(mdl_gfap_model1.Coefficients('APOE4_2','Estimate'))) , '%.1f' ) ' (' ...
    num2str( ci_gfap_model1(strcmp(mdl_gfap_model1.CoefficientNames,'APOE4_2'),1) , '%.1f' ) '; ' ...
    num2str( ci_gfap_model1(strcmp(mdl_gfap_model1.CoefficientNames,'APOE4_2'),2) , '%.1f' ) ')' ...
    ];
if cell2mat(table2cell(mdl_gfap_model1.Coefficients('APOE4_2','pValue'))) < 0.05
    tmp = [tmp '*'];
end
stats_regression{6,7} = tmp;

tmp = [ num2str( cell2mat(table2cell(mdl_gfap_model1.Coefficients('APOE4_1','Estimate'))) , '%.1f' ) ' (' ...
    num2str( ci_gfap_model1(strcmp(mdl_gfap_model1.CoefficientNames,'APOE4_1'),1) , '%.1f' ) '; ' ...
    num2str( ci_gfap_model1(strcmp(mdl_gfap_model1.CoefficientNames,'APOE4_1'),2) , '%.1f' ) ')' ...
    ];
if cell2mat(table2cell(mdl_gfap_model1.Coefficients('APOE4_1','pValue'))) < 0.05
    tmp = [tmp '*'];
end
stats_regression{6,8} = tmp;

stats_regression{6,16} = mdl_gfap_model1.Rsquared.Ordinary;

%% gfap model2

stats_regression{7,4} = mdl_gfap_model2.NumObservations;

tmp = [ num2str( cell2mat(table2cell(mdl_gfap_model2.Coefficients('Age','Estimate'))) , '%.1f' ) ' (' ...
    num2str( ci_gfap_model2(strcmp(mdl_gfap_model2.CoefficientNames,'Age'),1) , '%.1f' ) '; ' ...
    num2str( ci_gfap_model2(strcmp(mdl_gfap_model2.CoefficientNames,'Age'),2) , '%.1f' ) ')' ...
    ];
if cell2mat(table2cell(mdl_gfap_model2.Coefficients('Age','pValue'))) < 0.05
    tmp = [tmp '*'];
end
stats_regression{7,5} = tmp;

tmp = [ num2str( cell2mat(table2cell(mdl_gfap_model2.Coefficients('Sex_Male','Estimate'))) , '%.1f' ) ' (' ...
    num2str( ci_gfap_model2(strcmp(mdl_gfap_model2.CoefficientNames,'Sex_Male'),1) , '%.1f' ) '; ' ...
    num2str( ci_gfap_model2(strcmp(mdl_gfap_model2.CoefficientNames,'Sex_Male'),2) , '%.1f' ) ')' ...
    ];
if cell2mat(table2cell(mdl_gfap_model2.Coefficients('Sex_Male','pValue'))) < 0.05
    tmp = [tmp '*'];
end
stats_regression{7,6} = tmp;

tmp = [ num2str( cell2mat(table2cell(mdl_gfap_model2.Coefficients('APOE4_2','Estimate'))) , '%.1f' ) ' (' ...
    num2str( ci_gfap_model2(strcmp(mdl_gfap_model2.CoefficientNames,'APOE4_2'),1) , '%.1f' ) '; ' ...
    num2str( ci_gfap_model2(strcmp(mdl_gfap_model2.CoefficientNames,'APOE4_2'),2) , '%.1f' ) ')' ...
    ];
if cell2mat(table2cell(mdl_gfap_model2.Coefficients('APOE4_2','pValue'))) < 0.05
    tmp = [tmp '*'];
end
stats_regression{7,7} = tmp;

tmp = [ num2str( cell2mat(table2cell(mdl_gfap_model2.Coefficients('APOE4_1','Estimate'))) , '%.1f' ) ' (' ...
    num2str( ci_gfap_model2(strcmp(mdl_gfap_model2.CoefficientNames,'APOE4_1'),1) , '%.1f' ) '; ' ...
    num2str( ci_gfap_model2(strcmp(mdl_gfap_model2.CoefficientNames,'APOE4_1'),2) , '%.1f' ) ')' ...
    ];
if cell2mat(table2cell(mdl_gfap_model2.Coefficients('APOE4_1','pValue'))) < 0.05
    tmp = [tmp '*'];
end
stats_regression{7,8} = tmp;

tmp = [ num2str( cell2mat(table2cell(mdl_gfap_model2.Coefficients('Abeta42/40','Estimate'))) , '%.1f' ) ' (' ...
    num2str( ci_gfap_model2(strcmp(mdl_gfap_model2.CoefficientNames,'Abeta42/40'),1) , '%.1f' ) '; ' ...
    num2str( ci_gfap_model2(strcmp(mdl_gfap_model2.CoefficientNames,'Abeta42/40'),2) , '%.1f' ) ')' ...
    ];
if cell2mat(table2cell(mdl_gfap_model2.Coefficients('Abeta42/40','pValue'))) < 0.05
    tmp = [tmp '*'];
end
stats_regression{7,10} = tmp;

tmp = [ num2str( cell2mat(table2cell(mdl_gfap_model2.Coefficients('CKD_Yes','Estimate'))) , '%.1f' ) ' (' ...
    num2str( ci_gfap_model2(strcmp(mdl_gfap_model2.CoefficientNames,'CKD_Yes'),1) , '%.1f' ) '; ' ...
    num2str( ci_gfap_model2(strcmp(mdl_gfap_model2.CoefficientNames,'CKD_Yes'),2) , '%.1f' ) ')' ...
    ];
if cell2mat(table2cell(mdl_gfap_model2.Coefficients('CKD_Yes','pValue'))) < 0.05
    tmp = [tmp '*'];
end
stats_regression{7,11} = tmp;

tmp = [ num2str( cell2mat(table2cell(mdl_gfap_model2.Coefficients('HbA1C','Estimate'))) , '%.1f' ) ' (' ...
    num2str( ci_gfap_model2(strcmp(mdl_gfap_model2.CoefficientNames,'HbA1C'),1) , '%.1f' ) '; ' ...
    num2str( ci_gfap_model2(strcmp(mdl_gfap_model2.CoefficientNames,'HbA1C'),2) , '%.1f' ) ')' ...
    ];
if cell2mat(table2cell(mdl_gfap_model2.Coefficients('HbA1C','pValue'))) < 0.05
    tmp = [tmp '*'];
end
stats_regression{7,12} = tmp;

tmp = [ num2str( cell2mat(table2cell(mdl_gfap_model2.Coefficients('IHD_Yes','Estimate'))) , '%.1f' ) ' (' ...
    num2str( ci_gfap_model2(strcmp(mdl_gfap_model2.CoefficientNames,'IHD_Yes'),1) , '%.1f' ) '; ' ...
    num2str( ci_gfap_model2(strcmp(mdl_gfap_model2.CoefficientNames,'IHD_Yes'),2) , '%.1f' ) ')' ...
    ];
if cell2mat(table2cell(mdl_gfap_model2.Coefficients('IHD_Yes','pValue'))) < 0.05
    tmp = [tmp '*'];
end
stats_regression{7,13} = tmp;

tmp = [ num2str( cell2mat(table2cell(mdl_gfap_model2.Coefficients('Stroke_Yes','Estimate'))) , '%.1f' ) ' (' ...
    num2str( ci_gfap_model2(strcmp(mdl_gfap_model2.CoefficientNames,'Stroke_Yes'),1) , '%.1f' ) '; ' ...
    num2str( ci_gfap_model2(strcmp(mdl_gfap_model2.CoefficientNames,'Stroke_Yes'),2) , '%.1f' ) ')' ...
    ];
if cell2mat(table2cell(mdl_gfap_model2.Coefficients('Stroke_Yes','pValue'))) < 0.05
    tmp = [tmp '*'];
end
stats_regression{7,14} = tmp;

if include_bmi == 1
    tmp = [ num2str( cell2mat(table2cell(mdl_gfap_model2.Coefficients('BMI','Estimate'))) , '%.1f' ) ' (' ...
        num2str( ci_gfap_model2(strcmp(mdl_gfap_model2.CoefficientNames,'BMI'),1) , '%.1f' ) '; ' ...
        num2str( ci_gfap_model2(strcmp(mdl_gfap_model2.CoefficientNames,'BMI'),2) , '%.1f' ) ')' ...
        ];
    if cell2mat(table2cell(mdl_gfap_model2.Coefficients('BMI','pValue'))) < 0.05
        tmp = [tmp '*'];
    end
    stats_regression{7,15} = tmp;
end

stats_regression{7,16} = mdl_gfap_model2.Rsquared.Ordinary;

%% gfap model3
stats_regression{8,4} = mdl_gfap_model3.NumObservations;

tmp = [ num2str( cell2mat(table2cell(mdl_gfap_model3.Coefficients('Age','Estimate'))) , '%.1f' ) ' (' ...
    num2str( ci_gfap_model3(strcmp(mdl_gfap_model3.CoefficientNames,'Age'),1) , '%.1f' ) '; ' ...
    num2str( ci_gfap_model3(strcmp(mdl_gfap_model3.CoefficientNames,'Age'),2) , '%.1f' ) ')' ...
    ];
if cell2mat(table2cell(mdl_gfap_model3.Coefficients('Age','pValue'))) < 0.05
    tmp = [tmp '*'];
end
stats_regression{8,5} = tmp;

tmp = [ num2str( cell2mat(table2cell(mdl_gfap_model3.Coefficients('Sex_Male','Estimate'))) , '%.1f' ) ' (' ...
    num2str( ci_gfap_model3(strcmp(mdl_gfap_model3.CoefficientNames,'Sex_Male'),1) , '%.1f' ) '; ' ...
    num2str( ci_gfap_model3(strcmp(mdl_gfap_model3.CoefficientNames,'Sex_Male'),2) , '%.1f' ) ')' ...
    ];
if cell2mat(table2cell(mdl_gfap_model3.Coefficients('Sex_Male','pValue'))) < 0.05
    tmp = [tmp '*'];
end
stats_regression{8,6} = tmp;

tmp = [ num2str( cell2mat(table2cell(mdl_gfap_model3.Coefficients('APOE4_1','Estimate'))) , '%.1f' ) ' (' ...
    num2str( ci_gfap_model3(strcmp(mdl_gfap_model3.CoefficientNames,'APOE4_1'),1) , '%.1f' ) '; ' ...
    num2str( ci_gfap_model3(strcmp(mdl_gfap_model3.CoefficientNames,'APOE4_1'),2) , '%.1f' ) ')' ...
    ];
if cell2mat(table2cell(mdl_gfap_model3.Coefficients('APOE4_1','pValue'))) < 0.05
    tmp = [tmp '*'];
end
stats_regression{8,9} = tmp;

stats_regression{8,16} = mdl_gfap_model3.Rsquared.Ordinary;

%% gfap model4

stats_regression{9,4} = mdl_gfap_model4.NumObservations;

tmp = [ num2str( cell2mat(table2cell(mdl_gfap_model4.Coefficients('Age','Estimate'))) , '%.1f' ) ' (' ...
    num2str( ci_gfap_model4(strcmp(mdl_gfap_model4.CoefficientNames,'Age'),1) , '%.1f' ) '; ' ...
    num2str( ci_gfap_model4(strcmp(mdl_gfap_model4.CoefficientNames,'Age'),2) , '%.1f' ) ')' ...
    ];
if cell2mat(table2cell(mdl_gfap_model4.Coefficients('Age','pValue'))) < 0.05
    tmp = [tmp '*'];
end
stats_regression{9,5} = tmp;

tmp = [ num2str( cell2mat(table2cell(mdl_gfap_model4.Coefficients('Sex_Male','Estimate'))) , '%.1f' ) ' (' ...
    num2str( ci_gfap_model4(strcmp(mdl_gfap_model4.CoefficientNames,'Sex_Male'),1) , '%.1f' ) '; ' ...
    num2str( ci_gfap_model4(strcmp(mdl_gfap_model4.CoefficientNames,'Sex_Male'),2) , '%.1f' ) ')' ...
    ];
if cell2mat(table2cell(mdl_gfap_model4.Coefficients('Sex_Male','pValue'))) < 0.05
    tmp = [tmp '*'];
end
stats_regression{9,6} = tmp;

tmp = [ num2str( cell2mat(table2cell(mdl_gfap_model4.Coefficients('APOE4_1','Estimate'))) , '%.1f' ) ' (' ...
    num2str( ci_gfap_model4(strcmp(mdl_gfap_model4.CoefficientNames,'APOE4_1'),1) , '%.1f' ) '; ' ...
    num2str( ci_gfap_model4(strcmp(mdl_gfap_model4.CoefficientNames,'APOE4_1'),2) , '%.1f' ) ')' ...
    ];
if cell2mat(table2cell(mdl_gfap_model4.Coefficients('APOE4_1','pValue'))) < 0.05
    tmp = [tmp '*'];
end
stats_regression{9,9} = tmp;

tmp = [ num2str( cell2mat(table2cell(mdl_gfap_model4.Coefficients('Abeta42/40','Estimate'))) , '%.1f' ) ' (' ...
    num2str( ci_gfap_model4(strcmp(mdl_gfap_model4.CoefficientNames,'Abeta42/40'),1) , '%.1f' ) '; ' ...
    num2str( ci_gfap_model4(strcmp(mdl_gfap_model4.CoefficientNames,'Abeta42/40'),2) , '%.1f' ) ')' ...
    ];
if cell2mat(table2cell(mdl_gfap_model4.Coefficients('Abeta42/40','pValue'))) < 0.05
    tmp = [tmp '*'];
end
stats_regression{9,10} = tmp;

tmp = [ num2str( cell2mat(table2cell(mdl_gfap_model4.Coefficients('CKD_Yes','Estimate'))) , '%.1f' ) ' (' ...
    num2str( ci_gfap_model4(strcmp(mdl_gfap_model4.CoefficientNames,'CKD_Yes'),1) , '%.1f' ) '; ' ...
    num2str( ci_gfap_model4(strcmp(mdl_gfap_model4.CoefficientNames,'CKD_Yes'),2) , '%.1f' ) ')' ...
    ];
if cell2mat(table2cell(mdl_gfap_model4.Coefficients('CKD_Yes','pValue'))) < 0.05
    tmp = [tmp '*'];
end
stats_regression{9,11} = tmp;

tmp = [ num2str( cell2mat(table2cell(mdl_gfap_model4.Coefficients('HbA1C','Estimate'))) , '%.1f' ) ' (' ...
    num2str( ci_gfap_model4(strcmp(mdl_gfap_model4.CoefficientNames,'HbA1C'),1) , '%.1f' ) '; ' ...
    num2str( ci_gfap_model4(strcmp(mdl_gfap_model4.CoefficientNames,'HbA1C'),2) , '%.1f' ) ')' ...
    ];
if cell2mat(table2cell(mdl_gfap_model4.Coefficients('HbA1C','pValue'))) < 0.05
    tmp = [tmp '*'];
end
stats_regression{9,12} = tmp;

tmp = [ num2str( cell2mat(table2cell(mdl_gfap_model4.Coefficients('IHD_Yes','Estimate'))) , '%.1f' ) ' (' ...
    num2str( ci_gfap_model4(strcmp(mdl_gfap_model4.CoefficientNames,'IHD_Yes'),1) , '%.1f' ) '; ' ...
    num2str( ci_gfap_model4(strcmp(mdl_gfap_model4.CoefficientNames,'IHD_Yes'),2) , '%.1f' ) ')' ...
    ];
if cell2mat(table2cell(mdl_gfap_model4.Coefficients('IHD_Yes','pValue'))) < 0.05
    tmp = [tmp '*'];
end
stats_regression{9,13} = tmp;

tmp = [ num2str( cell2mat(table2cell(mdl_gfap_model4.Coefficients('Stroke_Yes','Estimate'))) , '%.1f' ) ' (' ...
    num2str( ci_gfap_model4(strcmp(mdl_gfap_model4.CoefficientNames,'Stroke_Yes'),1) , '%.1f' ) '; ' ...
    num2str( ci_gfap_model4(strcmp(mdl_gfap_model4.CoefficientNames,'Stroke_Yes'),2) , '%.1f' ) ')' ...
    ];
if cell2mat(table2cell(mdl_gfap_model4.Coefficients('Stroke_Yes','pValue'))) < 0.05
    tmp = [tmp '*'];
end
stats_regression{9,14} = tmp;

if include_bmi == 1
    tmp = [ num2str( cell2mat(table2cell(mdl_gfap_model4.Coefficients('BMI','Estimate'))) , '%.1f' ) ' (' ...
        num2str( ci_gfap_model4(strcmp(mdl_gfap_model4.CoefficientNames,'BMI'),1) , '%.1f' ) '; ' ...
        num2str( ci_gfap_model4(strcmp(mdl_gfap_model4.CoefficientNames,'BMI'),2) , '%.1f' ) ')' ...
        ];
    if cell2mat(table2cell(mdl_gfap_model4.Coefficients('BMI','pValue'))) < 0.05
        tmp = [tmp '*'];
    end
    stats_regression{9,15} = tmp;
end

stats_regression{9,16} = mdl_gfap_model4.Rsquared.Ordinary;

%% nfl model1
stats_regression{10,4} = mdl_nfl_model1.NumObservations;

tmp = [ num2str( cell2mat(table2cell(mdl_nfl_model1.Coefficients('Age','Estimate'))) , '%.2f' ) ' (' ...
    num2str( ci_nfl_model1(strcmp(mdl_nfl_model1.CoefficientNames,'Age'),1) , '%.2f' ) '; ' ...
    num2str( ci_nfl_model1(strcmp(mdl_nfl_model1.CoefficientNames,'Age'),2) , '%.2f' ) ')' ...
    ];
if cell2mat(table2cell(mdl_nfl_model1.Coefficients('Age','pValue'))) < 0.05
    tmp = [tmp '*'];
end
stats_regression{10,5} = tmp;

tmp = [ num2str( cell2mat(table2cell(mdl_nfl_model1.Coefficients('Sex_Male','Estimate'))) , '%.2f' ) ' (' ...
    num2str( ci_nfl_model1(strcmp(mdl_nfl_model1.CoefficientNames,'Sex_Male'),1) , '%.2f' ) '; ' ...
    num2str( ci_nfl_model1(strcmp(mdl_nfl_model1.CoefficientNames,'Sex_Male'),2) , '%.2f' ) ')' ...
    ];
if cell2mat(table2cell(mdl_nfl_model1.Coefficients('Sex_Male','pValue'))) < 0.05
    tmp = [tmp '*'];
end
stats_regression{10,6} = tmp;

tmp = [ num2str( cell2mat(table2cell(mdl_nfl_model1.Coefficients('APOE4_2','Estimate'))) , '%.2f' ) ' (' ...
    num2str( ci_nfl_model1(strcmp(mdl_nfl_model1.CoefficientNames,'APOE4_2'),1) , '%.2f' ) '; ' ...
    num2str( ci_nfl_model1(strcmp(mdl_nfl_model1.CoefficientNames,'APOE4_2'),2) , '%.2f' ) ')' ...
    ];
if cell2mat(table2cell(mdl_nfl_model1.Coefficients('APOE4_2','pValue'))) < 0.05
    tmp = [tmp '*'];
end
stats_regression{10,7} = tmp;

tmp = [ num2str( cell2mat(table2cell(mdl_nfl_model1.Coefficients('APOE4_1','Estimate'))) , '%.2f' ) ' (' ...
    num2str( ci_nfl_model1(strcmp(mdl_nfl_model1.CoefficientNames,'APOE4_1'),1) , '%.2f' ) '; ' ...
    num2str( ci_nfl_model1(strcmp(mdl_nfl_model1.CoefficientNames,'APOE4_1'),2) , '%.2f' ) ')' ...
    ];
if cell2mat(table2cell(mdl_nfl_model1.Coefficients('APOE4_1','pValue'))) < 0.05
    tmp = [tmp '*'];
end
stats_regression{10,8} = tmp;

stats_regression{10,16} = mdl_nfl_model1.Rsquared.Ordinary;

%% nfl model2

stats_regression{11,4} = mdl_nfl_model2.NumObservations;

tmp = [ num2str( cell2mat(table2cell(mdl_nfl_model2.Coefficients('Age','Estimate'))) , '%.2f' ) ' (' ...
    num2str( ci_nfl_model2(strcmp(mdl_nfl_model2.CoefficientNames,'Age'),1) , '%.2f' ) '; ' ...
    num2str( ci_nfl_model2(strcmp(mdl_nfl_model2.CoefficientNames,'Age'),2) , '%.2f' ) ')' ...
    ];
if cell2mat(table2cell(mdl_nfl_model2.Coefficients('Age','pValue'))) < 0.05
    tmp = [tmp '*'];
end
stats_regression{11,5} = tmp;

tmp = [ num2str( cell2mat(table2cell(mdl_nfl_model2.Coefficients('Sex_Male','Estimate'))) , '%.2f' ) ' (' ...
    num2str( ci_nfl_model2(strcmp(mdl_nfl_model2.CoefficientNames,'Sex_Male'),1) , '%.2f' ) '; ' ...
    num2str( ci_nfl_model2(strcmp(mdl_nfl_model2.CoefficientNames,'Sex_Male'),2) , '%.2f' ) ')' ...
    ];
if cell2mat(table2cell(mdl_nfl_model2.Coefficients('Sex_Male','pValue'))) < 0.05
    tmp = [tmp '*'];
end
stats_regression{11,6} = tmp;

tmp = [ num2str( cell2mat(table2cell(mdl_nfl_model2.Coefficients('APOE4_2','Estimate'))) , '%.2f' ) ' (' ...
    num2str( ci_nfl_model2(strcmp(mdl_nfl_model2.CoefficientNames,'APOE4_2'),1) , '%.2f' ) '; ' ...
    num2str( ci_nfl_model2(strcmp(mdl_nfl_model2.CoefficientNames,'APOE4_2'),2) , '%.2f' ) ')' ...
    ];
if cell2mat(table2cell(mdl_nfl_model2.Coefficients('APOE4_2','pValue'))) < 0.05
    tmp = [tmp '*'];
end
stats_regression{11,7} = tmp;

tmp = [ num2str( cell2mat(table2cell(mdl_nfl_model2.Coefficients('APOE4_1','Estimate'))) , '%.2f' ) ' (' ...
    num2str( ci_nfl_model2(strcmp(mdl_nfl_model2.CoefficientNames,'APOE4_1'),1) , '%.2f' ) '; ' ...
    num2str( ci_nfl_model2(strcmp(mdl_nfl_model2.CoefficientNames,'APOE4_1'),2) , '%.2f' ) ')' ...
    ];
if cell2mat(table2cell(mdl_nfl_model2.Coefficients('APOE4_1','pValue'))) < 0.05
    tmp = [tmp '*'];
end
stats_regression{11,8} = tmp;

tmp = [ num2str( cell2mat(table2cell(mdl_nfl_model2.Coefficients('Abeta42/40','Estimate'))) , '%.2f' ) ' (' ...
    num2str( ci_nfl_model2(strcmp(mdl_nfl_model2.CoefficientNames,'Abeta42/40'),1) , '%.2f' ) '; ' ...
    num2str( ci_nfl_model2(strcmp(mdl_nfl_model2.CoefficientNames,'Abeta42/40'),2) , '%.2f' ) ')' ...
    ];
if cell2mat(table2cell(mdl_nfl_model2.Coefficients('Abeta42/40','pValue'))) < 0.05
    tmp = [tmp '*'];
end
stats_regression{11,10} = tmp;

tmp = [ num2str( cell2mat(table2cell(mdl_nfl_model2.Coefficients('CKD_Yes','Estimate'))) , '%.2f' ) ' (' ...
    num2str( ci_nfl_model2(strcmp(mdl_nfl_model2.CoefficientNames,'CKD_Yes'),1) , '%.2f' ) '; ' ...
    num2str( ci_nfl_model2(strcmp(mdl_nfl_model2.CoefficientNames,'CKD_Yes'),2) , '%.2f' ) ')' ...
    ];
if cell2mat(table2cell(mdl_nfl_model2.Coefficients('CKD_Yes','pValue'))) < 0.05
    tmp = [tmp '*'];
end
stats_regression{11,11} = tmp;

tmp = [ num2str( cell2mat(table2cell(mdl_nfl_model2.Coefficients('HbA1C','Estimate'))) , '%.2f' ) ' (' ...
    num2str( ci_nfl_model2(strcmp(mdl_nfl_model2.CoefficientNames,'HbA1C'),1) , '%.2f' ) '; ' ...
    num2str( ci_nfl_model2(strcmp(mdl_nfl_model2.CoefficientNames,'HbA1C'),2) , '%.2f' ) ')' ...
    ];
if cell2mat(table2cell(mdl_nfl_model2.Coefficients('HbA1C','pValue'))) < 0.05
    tmp = [tmp '*'];
end
stats_regression{11,12} = tmp;

tmp = [ num2str( cell2mat(table2cell(mdl_nfl_model2.Coefficients('IHD_Yes','Estimate'))) , '%.2f' ) ' (' ...
    num2str( ci_nfl_model2(strcmp(mdl_nfl_model2.CoefficientNames,'IHD_Yes'),1) , '%.2f' ) '; ' ...
    num2str( ci_nfl_model2(strcmp(mdl_nfl_model2.CoefficientNames,'IHD_Yes'),2) , '%.2f' ) ')' ...
    ];
if cell2mat(table2cell(mdl_nfl_model2.Coefficients('IHD_Yes','pValue'))) < 0.05
    tmp = [tmp '*'];
end
stats_regression{11,13} = tmp;

tmp = [ num2str( cell2mat(table2cell(mdl_nfl_model2.Coefficients('Stroke_Yes','Estimate'))) , '%.2f' ) ' (' ...
    num2str( ci_nfl_model2(strcmp(mdl_nfl_model2.CoefficientNames,'Stroke_Yes'),1) , '%.2f' ) '; ' ...
    num2str( ci_nfl_model2(strcmp(mdl_nfl_model2.CoefficientNames,'Stroke_Yes'),2) , '%.2f' ) ')' ...
    ];
if cell2mat(table2cell(mdl_nfl_model2.Coefficients('Stroke_Yes','pValue'))) < 0.05
    tmp = [tmp '*'];
end
stats_regression{11,14} = tmp;

if include_bmi == 1
    tmp = [ num2str( cell2mat(table2cell(mdl_nfl_model2.Coefficients('BMI','Estimate'))) , '%.2f' ) ' (' ...
        num2str( ci_nfl_model2(strcmp(mdl_nfl_model2.CoefficientNames,'BMI'),1) , '%.2f' ) '; ' ...
        num2str( ci_nfl_model2(strcmp(mdl_nfl_model2.CoefficientNames,'BMI'),2) , '%.2f' ) ')' ...
        ];
    if cell2mat(table2cell(mdl_nfl_model2.Coefficients('BMI','pValue'))) < 0.05
        tmp = [tmp '*'];
    end
    stats_regression{11,15} = tmp;
end

stats_regression{11,16} = mdl_nfl_model2.Rsquared.Ordinary;

%% nfl model3
stats_regression{12,4} = mdl_nfl_model3.NumObservations;

tmp = [ num2str( cell2mat(table2cell(mdl_nfl_model3.Coefficients('Age','Estimate'))) , '%.2f' ) ' (' ...
    num2str( ci_nfl_model3(strcmp(mdl_nfl_model3.CoefficientNames,'Age'),1) , '%.2f' ) '; ' ...
    num2str( ci_nfl_model3(strcmp(mdl_nfl_model3.CoefficientNames,'Age'),2) , '%.2f' ) ')' ...
    ];
if cell2mat(table2cell(mdl_nfl_model3.Coefficients('Age','pValue'))) < 0.05
    tmp = [tmp '*'];
end
stats_regression{12,5} = tmp;

tmp = [ num2str( cell2mat(table2cell(mdl_nfl_model3.Coefficients('Sex_Male','Estimate'))) , '%.2f' ) ' (' ...
    num2str( ci_nfl_model3(strcmp(mdl_nfl_model3.CoefficientNames,'Sex_Male'),1) , '%.2f' ) '; ' ...
    num2str( ci_nfl_model3(strcmp(mdl_nfl_model3.CoefficientNames,'Sex_Male'),2) , '%.2f' ) ')' ...
    ];
if cell2mat(table2cell(mdl_nfl_model3.Coefficients('Sex_Male','pValue'))) < 0.05
    tmp = [tmp '*'];
end
stats_regression{12,6} = tmp;

tmp = [ num2str( cell2mat(table2cell(mdl_nfl_model3.Coefficients('APOE4_1','Estimate'))) , '%.2f' ) ' (' ...
    num2str( ci_nfl_model3(strcmp(mdl_nfl_model3.CoefficientNames,'APOE4_1'),1) , '%.2f' ) '; ' ...
    num2str( ci_nfl_model3(strcmp(mdl_nfl_model3.CoefficientNames,'APOE4_1'),2) , '%.2f' ) ')' ...
    ];
if cell2mat(table2cell(mdl_nfl_model3.Coefficients('APOE4_1','pValue'))) < 0.05
    tmp = [tmp '*'];
end
stats_regression{12,9} = tmp;

stats_regression{12,16} = mdl_nfl_model3.Rsquared.Ordinary;

%% nfl model4

stats_regression{13,4} = mdl_nfl_model4.NumObservations;

tmp = [ num2str( cell2mat(table2cell(mdl_nfl_model4.Coefficients('Age','Estimate'))) , '%.2f' ) ' (' ...
    num2str( ci_nfl_model4(strcmp(mdl_nfl_model4.CoefficientNames,'Age'),1) , '%.2f' ) '; ' ...
    num2str( ci_nfl_model4(strcmp(mdl_nfl_model4.CoefficientNames,'Age'),2) , '%.2f' ) ')' ...
    ];
if cell2mat(table2cell(mdl_nfl_model4.Coefficients('Age','pValue'))) < 0.05
    tmp = [tmp '*'];
end
stats_regression{13,5} = tmp;

tmp = [ num2str( cell2mat(table2cell(mdl_nfl_model4.Coefficients('Sex_Male','Estimate'))) , '%.2f' ) ' (' ...
    num2str( ci_nfl_model4(strcmp(mdl_nfl_model4.CoefficientNames,'Sex_Male'),1) , '%.2f' ) '; ' ...
    num2str( ci_nfl_model4(strcmp(mdl_nfl_model4.CoefficientNames,'Sex_Male'),2) , '%.2f' ) ')' ...
    ];
if cell2mat(table2cell(mdl_nfl_model4.Coefficients('Sex_Male','pValue'))) < 0.05
    tmp = [tmp '*'];
end
stats_regression{13,6} = tmp;

tmp = [ num2str( cell2mat(table2cell(mdl_nfl_model4.Coefficients('APOE4_1','Estimate'))) , '%.2f' ) ' (' ...
    num2str( ci_nfl_model4(strcmp(mdl_nfl_model4.CoefficientNames,'APOE4_1'),1) , '%.2f' ) '; ' ...
    num2str( ci_nfl_model4(strcmp(mdl_nfl_model4.CoefficientNames,'APOE4_1'),2) , '%.2f' ) ')' ...
    ];
if cell2mat(table2cell(mdl_nfl_model4.Coefficients('APOE4_1','pValue'))) < 0.05
    tmp = [tmp '*'];
end
stats_regression{13,9} = tmp;

tmp = [ num2str( cell2mat(table2cell(mdl_nfl_model4.Coefficients('Abeta42/40','Estimate'))) , '%.2f' ) ' (' ...
    num2str( ci_nfl_model4(strcmp(mdl_nfl_model4.CoefficientNames,'Abeta42/40'),1) , '%.2f' ) '; ' ...
    num2str( ci_nfl_model4(strcmp(mdl_nfl_model4.CoefficientNames,'Abeta42/40'),2) , '%.2f' ) ')' ...
    ];
if cell2mat(table2cell(mdl_nfl_model4.Coefficients('Abeta42/40','pValue'))) < 0.05
    tmp = [tmp '*'];
end
stats_regression{13,10} = tmp;

tmp = [ num2str( cell2mat(table2cell(mdl_nfl_model4.Coefficients('CKD_Yes','Estimate'))) , '%.2f' ) ' (' ...
    num2str( ci_nfl_model4(strcmp(mdl_nfl_model4.CoefficientNames,'CKD_Yes'),1) , '%.2f' ) '; ' ...
    num2str( ci_nfl_model4(strcmp(mdl_nfl_model4.CoefficientNames,'CKD_Yes'),2) , '%.2f' ) ')' ...
    ];
if cell2mat(table2cell(mdl_nfl_model4.Coefficients('CKD_Yes','pValue'))) < 0.05
    tmp = [tmp '*'];
end
stats_regression{13,11} = tmp;

tmp = [ num2str( cell2mat(table2cell(mdl_nfl_model4.Coefficients('HbA1C','Estimate'))) , '%.2f' ) ' (' ...
    num2str( ci_nfl_model4(strcmp(mdl_nfl_model4.CoefficientNames,'HbA1C'),1) , '%.2f' ) '; ' ...
    num2str( ci_nfl_model4(strcmp(mdl_nfl_model4.CoefficientNames,'HbA1C'),2) , '%.2f' ) ')' ...
    ];
if cell2mat(table2cell(mdl_nfl_model4.Coefficients('HbA1C','pValue'))) < 0.05
    tmp = [tmp '*'];
end
stats_regression{13,12} = tmp;

tmp = [ num2str( cell2mat(table2cell(mdl_nfl_model4.Coefficients('IHD_Yes','Estimate'))) , '%.2f' ) ' (' ...
    num2str( ci_nfl_model4(strcmp(mdl_nfl_model4.CoefficientNames,'IHD_Yes'),1) , '%.2f' ) '; ' ...
    num2str( ci_nfl_model4(strcmp(mdl_nfl_model4.CoefficientNames,'IHD_Yes'),2) , '%.2f' ) ')' ...
    ];
if cell2mat(table2cell(mdl_nfl_model4.Coefficients('IHD_Yes','pValue'))) < 0.05
    tmp = [tmp '*'];
end
stats_regression{13,13} = tmp;

tmp = [ num2str( cell2mat(table2cell(mdl_nfl_model4.Coefficients('Stroke_Yes','Estimate'))) , '%.2f' ) ' (' ...
    num2str( ci_nfl_model4(strcmp(mdl_nfl_model4.CoefficientNames,'Stroke_Yes'),1) , '%.2f' ) '; ' ...
    num2str( ci_nfl_model4(strcmp(mdl_nfl_model4.CoefficientNames,'Stroke_Yes'),2) , '%.2f' ) ')' ...
    ];
if cell2mat(table2cell(mdl_nfl_model4.Coefficients('Stroke_Yes','pValue'))) < 0.05
    tmp = [tmp '*'];
end
stats_regression{13,14} = tmp;

if include_bmi == 1
    tmp = [ num2str( cell2mat(table2cell(mdl_nfl_model4.Coefficients('BMI','Estimate'))) , '%.2f' ) ' (' ...
        num2str( ci_nfl_model4(strcmp(mdl_nfl_model4.CoefficientNames,'BMI'),1) , '%.2f' ) '; ' ...
        num2str( ci_nfl_model4(strcmp(mdl_nfl_model4.CoefficientNames,'BMI'),2) , '%.2f' ) ')' ...
        ];
    if cell2mat(table2cell(mdl_nfl_model4.Coefficients('BMI','pValue'))) < 0.05
        tmp = [tmp '*'];
    end
    stats_regression{13,15} = tmp;
end

stats_regression{13,16} = mdl_nfl_model4.Rsquared.Ordinary;


%% abeta4240 model1
stats_regression{14,4} = mdl_abeta4240_model1.NumObservations;

tmp = [ num2str( cell2mat(table2cell(mdl_abeta4240_model1.Coefficients('Age','Estimate'))) , '%.3f' ) ' (' ...
    num2str( ci_abeta4240_model1(strcmp(mdl_abeta4240_model1.CoefficientNames,'Age'),1) , '%.3f' ) '; ' ...
    num2str( ci_abeta4240_model1(strcmp(mdl_abeta4240_model1.CoefficientNames,'Age'),2) , '%.3f' ) ')' ...
    ];
if cell2mat(table2cell(mdl_abeta4240_model1.Coefficients('Age','pValue'))) < 0.05
    tmp = [tmp '*'];
end
stats_regression{14,5} = tmp;

tmp = [ num2str( cell2mat(table2cell(mdl_abeta4240_model1.Coefficients('Sex_Male','Estimate'))) , '%.3f' ) ' (' ...
    num2str( ci_abeta4240_model1(strcmp(mdl_abeta4240_model1.CoefficientNames,'Sex_Male'),1) , '%.3f' ) '; ' ...
    num2str( ci_abeta4240_model1(strcmp(mdl_abeta4240_model1.CoefficientNames,'Sex_Male'),2) , '%.3f' ) ')' ...
    ];
if cell2mat(table2cell(mdl_abeta4240_model1.Coefficients('Sex_Male','pValue'))) < 0.05
    tmp = [tmp '*'];
end
stats_regression{14,6} = tmp;

tmp = [ num2str( cell2mat(table2cell(mdl_abeta4240_model1.Coefficients('APOE4_2','Estimate'))) , '%.3f' ) ' (' ...
    num2str( ci_abeta4240_model1(strcmp(mdl_abeta4240_model1.CoefficientNames,'APOE4_2'),1) , '%.3f' ) '; ' ...
    num2str( ci_abeta4240_model1(strcmp(mdl_abeta4240_model1.CoefficientNames,'APOE4_2'),2) , '%.3f' ) ')' ...
    ];
if cell2mat(table2cell(mdl_abeta4240_model1.Coefficients('APOE4_2','pValue'))) < 0.05
    tmp = [tmp '*'];
end
stats_regression{14,7} = tmp;

tmp = [ num2str( cell2mat(table2cell(mdl_abeta4240_model1.Coefficients('APOE4_1','Estimate'))) , '%.3f' ) ' (' ...
    num2str( ci_abeta4240_model1(strcmp(mdl_abeta4240_model1.CoefficientNames,'APOE4_1'),1) , '%.3f' ) '; ' ...
    num2str( ci_abeta4240_model1(strcmp(mdl_abeta4240_model1.CoefficientNames,'APOE4_1'),2) , '%.3f' ) ')' ...
    ];
if cell2mat(table2cell(mdl_abeta4240_model1.Coefficients('APOE4_1','pValue'))) < 0.05
    tmp = [tmp '*'];
end
stats_regression{14,8} = tmp;

stats_regression{14,16} = mdl_abeta4240_model1.Rsquared.Ordinary;

%% abeta4240 model5

stats_regression{15,4} = mdl_abeta4240_model5.NumObservations;

tmp = [ num2str( cell2mat(table2cell(mdl_abeta4240_model5.Coefficients('Age','Estimate'))) , '%.3f' ) ' (' ...
    num2str( ci_abeta4240_model5(strcmp(mdl_abeta4240_model5.CoefficientNames,'Age'),1) , '%.3f' ) '; ' ...
    num2str( ci_abeta4240_model5(strcmp(mdl_abeta4240_model5.CoefficientNames,'Age'),2) , '%.3f' ) ')' ...
    ];
if cell2mat(table2cell(mdl_abeta4240_model5.Coefficients('Age','pValue'))) < 0.05
    tmp = [tmp '*'];
end
stats_regression{15,5} = tmp;

tmp = [ num2str( cell2mat(table2cell(mdl_abeta4240_model5.Coefficients('Sex_Male','Estimate'))) , '%.3f' ) ' (' ...
    num2str( ci_abeta4240_model5(strcmp(mdl_abeta4240_model5.CoefficientNames,'Sex_Male'),1) , '%.3f' ) '; ' ...
    num2str( ci_abeta4240_model5(strcmp(mdl_abeta4240_model5.CoefficientNames,'Sex_Male'),2) , '%.3f' ) ')' ...
    ];
if cell2mat(table2cell(mdl_abeta4240_model5.Coefficients('Sex_Male','pValue'))) < 0.05
    tmp = [tmp '*'];
end
stats_regression{15,6} = tmp;

tmp = [ num2str( cell2mat(table2cell(mdl_abeta4240_model5.Coefficients('APOE4_2','Estimate'))) , '%.3f' ) ' (' ...
    num2str( ci_abeta4240_model5(strcmp(mdl_abeta4240_model5.CoefficientNames,'APOE4_2'),1) , '%.3f' ) '; ' ...
    num2str( ci_abeta4240_model5(strcmp(mdl_abeta4240_model5.CoefficientNames,'APOE4_2'),2) , '%.3f' ) ')' ...
    ];
if cell2mat(table2cell(mdl_abeta4240_model5.Coefficients('APOE4_2','pValue'))) < 0.05
    tmp = [tmp '*'];
end
stats_regression{15,7} = tmp;

tmp = [ num2str( cell2mat(table2cell(mdl_abeta4240_model5.Coefficients('APOE4_1','Estimate'))) , '%.3f' ) ' (' ...
    num2str( ci_abeta4240_model5(strcmp(mdl_abeta4240_model5.CoefficientNames,'APOE4_1'),1) , '%.3f' ) '; ' ...
    num2str( ci_abeta4240_model5(strcmp(mdl_abeta4240_model5.CoefficientNames,'APOE4_1'),2) , '%.3f' ) ')' ...
    ];
if cell2mat(table2cell(mdl_abeta4240_model5.Coefficients('APOE4_1','pValue'))) < 0.05
    tmp = [tmp '*'];
end
stats_regression{15,8} = tmp;

tmp = [ num2str( cell2mat(table2cell(mdl_abeta4240_model5.Coefficients('CKD_Yes','Estimate'))) , '%.3f' ) ' (' ...
    num2str( ci_abeta4240_model5(strcmp(mdl_abeta4240_model5.CoefficientNames,'CKD_Yes'),1) , '%.3f' ) '; ' ...
    num2str( ci_abeta4240_model5(strcmp(mdl_abeta4240_model5.CoefficientNames,'CKD_Yes'),2) , '%.3f' ) ')' ...
    ];
if cell2mat(table2cell(mdl_abeta4240_model5.Coefficients('CKD_Yes','pValue'))) < 0.05
    tmp = [tmp '*'];
end
stats_regression{15,11} = tmp;

tmp = [ num2str( cell2mat(table2cell(mdl_abeta4240_model5.Coefficients('HbA1C','Estimate'))) , '%.3f' ) ' (' ...
    num2str( ci_abeta4240_model5(strcmp(mdl_abeta4240_model5.CoefficientNames,'HbA1C'),1) , '%.3f' ) '; ' ...
    num2str( ci_abeta4240_model5(strcmp(mdl_abeta4240_model5.CoefficientNames,'HbA1C'),2) , '%.3f' ) ')' ...
    ];
if cell2mat(table2cell(mdl_abeta4240_model5.Coefficients('HbA1C','pValue'))) < 0.05
    tmp = [tmp '*'];
end
stats_regression{15,12} = tmp;

tmp = [ num2str( cell2mat(table2cell(mdl_abeta4240_model5.Coefficients('IHD_Yes','Estimate'))) , '%.3f' ) ' (' ...
    num2str( ci_abeta4240_model5(strcmp(mdl_abeta4240_model5.CoefficientNames,'IHD_Yes'),1) , '%.3f' ) '; ' ...
    num2str( ci_abeta4240_model5(strcmp(mdl_abeta4240_model5.CoefficientNames,'IHD_Yes'),2) , '%.3f' ) ')' ...
    ];
if cell2mat(table2cell(mdl_abeta4240_model5.Coefficients('IHD_Yes','pValue'))) < 0.05
    tmp = [tmp '*'];
end
stats_regression{15,13} = tmp;

tmp = [ num2str( cell2mat(table2cell(mdl_abeta4240_model5.Coefficients('Stroke_Yes','Estimate'))) , '%.3f' ) ' (' ...
    num2str( ci_abeta4240_model5(strcmp(mdl_abeta4240_model5.CoefficientNames,'Stroke_Yes'),1) , '%.3f' ) '; ' ...
    num2str( ci_abeta4240_model5(strcmp(mdl_abeta4240_model5.CoefficientNames,'Stroke_Yes'),2) , '%.3f' ) ')' ...
    ];
if cell2mat(table2cell(mdl_abeta4240_model5.Coefficients('Stroke_Yes','pValue'))) < 0.05
    tmp = [tmp '*'];
end
stats_regression{15,14} = tmp;

if include_bmi == 1
    tmp = [ num2str( cell2mat(table2cell(mdl_abeta4240_model5.Coefficients('BMI','Estimate'))) , '%.3f' ) ' (' ...
        num2str( ci_abeta4240_model5(strcmp(mdl_abeta4240_model5.CoefficientNames,'BMI'),1) , '%.3f' ) '; ' ...
        num2str( ci_abeta4240_model5(strcmp(mdl_abeta4240_model5.CoefficientNames,'BMI'),2) , '%.3f' ) ')' ...
        ];
    if cell2mat(table2cell(mdl_abeta4240_model5.Coefficients('BMI','pValue'))) < 0.05
        tmp = [tmp '*'];
    end
    stats_regression{15,15} = tmp;
end

stats_regression{15,16} = mdl_abeta4240_model5.Rsquared.Ordinary;

%% abeta4240 model3
stats_regression{16,4} = mdl_abeta4240_model3.NumObservations;

tmp = [ num2str( cell2mat(table2cell(mdl_abeta4240_model3.Coefficients('Age','Estimate'))) , '%.3f' ) ' (' ...
    num2str( ci_abeta4240_model3(strcmp(mdl_abeta4240_model3.CoefficientNames,'Age'),1) , '%.3f' ) '; ' ...
    num2str( ci_abeta4240_model3(strcmp(mdl_abeta4240_model3.CoefficientNames,'Age'),2) , '%.3f' ) ')' ...
    ];
if cell2mat(table2cell(mdl_abeta4240_model3.Coefficients('Age','pValue'))) < 0.05
    tmp = [tmp '*'];
end
stats_regression{16,5} = tmp;

tmp = [ num2str( cell2mat(table2cell(mdl_abeta4240_model3.Coefficients('Sex_Male','Estimate'))) , '%.3f' ) ' (' ...
    num2str( ci_abeta4240_model3(strcmp(mdl_abeta4240_model3.CoefficientNames,'Sex_Male'),1) , '%.3f' ) '; ' ...
    num2str( ci_abeta4240_model3(strcmp(mdl_abeta4240_model3.CoefficientNames,'Sex_Male'),2) , '%.3f' ) ')' ...
    ];
if cell2mat(table2cell(mdl_abeta4240_model3.Coefficients('Sex_Male','pValue'))) < 0.05
    tmp = [tmp '*'];
end
stats_regression{16,6} = tmp;

tmp = [ num2str( cell2mat(table2cell(mdl_abeta4240_model3.Coefficients('APOE4_1','Estimate'))) , '%.3f' ) ' (' ...
    num2str( ci_abeta4240_model3(strcmp(mdl_abeta4240_model3.CoefficientNames,'APOE4_1'),1) , '%.3f' ) '; ' ...
    num2str( ci_abeta4240_model3(strcmp(mdl_abeta4240_model3.CoefficientNames,'APOE4_1'),2) , '%.3f' ) ')' ...
    ];
if cell2mat(table2cell(mdl_abeta4240_model3.Coefficients('APOE4_1','pValue'))) < 0.05
    tmp = [tmp '*'];
end
stats_regression{16,9} = tmp;

stats_regression{16,16} = mdl_abeta4240_model3.Rsquared.Ordinary;

%% abeta4240 model6

stats_regression{17,4} = mdl_abeta4240_model6.NumObservations;

tmp = [ num2str( cell2mat(table2cell(mdl_abeta4240_model6.Coefficients('Age','Estimate'))) , '%.3f' ) ' (' ...
    num2str( ci_abeta4240_model6(strcmp(mdl_abeta4240_model6.CoefficientNames,'Age'),1) , '%.3f' ) '; ' ...
    num2str( ci_abeta4240_model6(strcmp(mdl_abeta4240_model6.CoefficientNames,'Age'),2) , '%.3f' ) ')' ...
    ];
if cell2mat(table2cell(mdl_abeta4240_model6.Coefficients('Age','pValue'))) < 0.05
    tmp = [tmp '*'];
end
stats_regression{17,5} = tmp;

tmp = [ num2str( cell2mat(table2cell(mdl_abeta4240_model6.Coefficients('Sex_Male','Estimate'))) , '%.3f' ) ' (' ...
    num2str( ci_abeta4240_model6(strcmp(mdl_abeta4240_model6.CoefficientNames,'Sex_Male'),1) , '%.3f' ) '; ' ...
    num2str( ci_abeta4240_model6(strcmp(mdl_abeta4240_model6.CoefficientNames,'Sex_Male'),2) , '%.3f' ) ')' ...
    ];
if cell2mat(table2cell(mdl_abeta4240_model6.Coefficients('Sex_Male','pValue'))) < 0.05
    tmp = [tmp '*'];
end
stats_regression{17,6} = tmp;

tmp = [ num2str( cell2mat(table2cell(mdl_abeta4240_model6.Coefficients('APOE4_1','Estimate'))) , '%.3f' ) ' (' ...
    num2str( ci_abeta4240_model6(strcmp(mdl_abeta4240_model6.CoefficientNames,'APOE4_1'),1) , '%.3f' ) '; ' ...
    num2str( ci_abeta4240_model6(strcmp(mdl_abeta4240_model6.CoefficientNames,'APOE4_1'),2) , '%.3f' ) ')' ...
    ];
if cell2mat(table2cell(mdl_abeta4240_model6.Coefficients('APOE4_1','pValue'))) < 0.05
    tmp = [tmp '*'];
end
stats_regression{17,9} = tmp;

tmp = [ num2str( cell2mat(table2cell(mdl_abeta4240_model6.Coefficients('CKD_Yes','Estimate'))) , '%.3f' ) ' (' ...
    num2str( ci_abeta4240_model6(strcmp(mdl_abeta4240_model6.CoefficientNames,'CKD_Yes'),1) , '%.3f' ) '; ' ...
    num2str( ci_abeta4240_model6(strcmp(mdl_abeta4240_model6.CoefficientNames,'CKD_Yes'),2) , '%.3f' ) ')' ...
    ];
if cell2mat(table2cell(mdl_abeta4240_model6.Coefficients('CKD_Yes','pValue'))) < 0.05
    tmp = [tmp '*'];
end
stats_regression{17,11} = tmp;

tmp = [ num2str( cell2mat(table2cell(mdl_abeta4240_model6.Coefficients('HbA1C','Estimate'))) , '%.3f' ) ' (' ...
    num2str( ci_abeta4240_model6(strcmp(mdl_abeta4240_model6.CoefficientNames,'HbA1C'),1) , '%.3f' ) '; ' ...
    num2str( ci_abeta4240_model6(strcmp(mdl_abeta4240_model6.CoefficientNames,'HbA1C'),2) , '%.3f' ) ')' ...
    ];
if cell2mat(table2cell(mdl_abeta4240_model6.Coefficients('HbA1C','pValue'))) < 0.05
    tmp = [tmp '*'];
end
stats_regression{17,12} = tmp;

tmp = [ num2str( cell2mat(table2cell(mdl_abeta4240_model6.Coefficients('IHD_Yes','Estimate'))) , '%.3f' ) ' (' ...
    num2str( ci_abeta4240_model6(strcmp(mdl_abeta4240_model6.CoefficientNames,'IHD_Yes'),1) , '%.3f' ) '; ' ...
    num2str( ci_abeta4240_model6(strcmp(mdl_abeta4240_model6.CoefficientNames,'IHD_Yes'),2) , '%.3f' ) ')' ...
    ];
if cell2mat(table2cell(mdl_abeta4240_model6.Coefficients('IHD_Yes','pValue'))) < 0.05
    tmp = [tmp '*'];
end
stats_regression{17,13} = tmp;

tmp = [ num2str( cell2mat(table2cell(mdl_abeta4240_model6.Coefficients('Stroke_Yes','Estimate'))) , '%.3f' ) ' (' ...
    num2str( ci_abeta4240_model6(strcmp(mdl_abeta4240_model6.CoefficientNames,'Stroke_Yes'),1) , '%.3f' ) '; ' ...
    num2str( ci_abeta4240_model6(strcmp(mdl_abeta4240_model6.CoefficientNames,'Stroke_Yes'),2) , '%.3f' ) ')' ...
    ];
if cell2mat(table2cell(mdl_abeta4240_model6.Coefficients('Stroke_Yes','pValue'))) < 0.05
    tmp = [tmp '*'];
end
stats_regression{17,14} = tmp;

if include_bmi == 1
    tmp = [ num2str( cell2mat(table2cell(mdl_abeta4240_model6.Coefficients('BMI','Estimate'))) , '%.3f' ) ' (' ...
        num2str( ci_abeta4240_model6(strcmp(mdl_abeta4240_model6.CoefficientNames,'BMI'),1) , '%.3f' ) '; ' ...
        num2str( ci_abeta4240_model6(strcmp(mdl_abeta4240_model6.CoefficientNames,'BMI'),2) , '%.3f' ) ')' ...
        ];
    if cell2mat(table2cell(mdl_abeta4240_model6.Coefficients('BMI','pValue'))) < 0.05
        tmp = [tmp '*'];
    end
    stats_regression{17,15} = tmp;
end

stats_regression{17,16} = mdl_abeta4240_model6.Rsquared.Ordinary;

%% Cross-correlation analysis


% clr='ggbbrr';
% sym='*.*.*.';
% grp = ones(size(adai,1),1);
% grp( isnan(cell2mat(adai(:,strcmp(data_names,'APOE4')))) ) = NaN;
% grp( cell2mat(adai(:,strcmp(data_names,'APOE4')))==0 & strcmp(adai(:,strcmp(data_names,'Sex')),'Female') ) = 2;
% grp( cell2mat(adai(:,strcmp(data_names,'APOE4')))==1 & strcmp(adai(:,strcmp(data_names,'Sex')),'Male') ) = 3;
% grp( cell2mat(adai(:,strcmp(data_names,'APOE4')))==1 & strcmp(adai(:,strcmp(data_names,'Sex')),'Female') ) = 4;
% grp( cell2mat(adai(:,strcmp(data_names,'APOE4')))==2 & strcmp(adai(:,strcmp(data_names,'Sex')),'Male') ) = 5;
% grp( cell2mat(adai(:,strcmp(data_names,'APOE4')))==2 & strcmp(adai(:,strcmp(data_names,'Sex')),'Female') ) = 6;
% grp = categorical(grp);
% % variable_name = {'APOE4 non-carrier male', 'APOE4 non-carrier female', ...
% %     'APOE4 heterozygous male', 'APOE4 heterozygous female',...
% %     'APOE4 homozygous male', 'APOE4 homozygous female'};
% 
% variable_name = {'BMI','Age','b42','b40','42/40','t217'};
% 
% data_corr = [ cell2mat(adai(:,strcmp(data_names,'BMI'))), ...
%     cell2mat(adai(:,strcmp(data_names,'Age'))), ...
%     cell2mat(adai(:,strcmp(data_names,'Abeta42'))), ...
%     cell2mat(adai(:,strcmp(data_names,'Abeta40'))), ...
%     adai_abeta4240ratio, ...
%     cell2mat(adai(:,strcmp(data_names,'pTau217'))) ...
%     ];

clr='ggbbrr';
sym='*.*.*.';
grp = ones(size(adai_all_apoe4,1),1);
grp( isnan(cell2mat(adai_all_apoe4(:,strcmp(data_names,'APOE4')))) ) = NaN;
grp( cell2mat(adai_all_apoe4(:,strcmp(data_names,'APOE4')))==0 & strcmp(adai_all_apoe4(:,strcmp(data_names,'Sex')),'Female') ) = 2;
grp( cell2mat(adai_all_apoe4(:,strcmp(data_names,'APOE4')))==1 & strcmp(adai_all_apoe4(:,strcmp(data_names,'Sex')),'Male') ) = 3;
grp( cell2mat(adai_all_apoe4(:,strcmp(data_names,'APOE4')))==1 & strcmp(adai_all_apoe4(:,strcmp(data_names,'Sex')),'Female') ) = 4;
grp( cell2mat(adai_all_apoe4(:,strcmp(data_names,'APOE4')))==2 & strcmp(adai_all_apoe4(:,strcmp(data_names,'Sex')),'Male') ) = 5;
grp( cell2mat(adai_all_apoe4(:,strcmp(data_names,'APOE4')))==2 & strcmp(adai_all_apoe4(:,strcmp(data_names,'Sex')),'Female') ) = 6;
grp = categorical(grp);
% variable_name = {'APOE4 non-carrier male', 'APOE4 non-carrier female', ...
%     'APOE4 heterozygous male', 'APOE4 heterozygous female',...
%     'APOE4 homozygous male', 'APOE4 homozygous female'};

variable_name = {'BMI','Age','b42','b40','42/40','t217','GFAP','NfL'};

data_corr = [ cell2mat(adai_all_apoe4(:,strcmp(data_names,'BMI'))), ...
    cell2mat(adai_all_apoe4(:,strcmp(data_names,'Age'))), ...
    cell2mat(adai_all_apoe4(:,strcmp(data_names,'Abeta42'))), ...
    cell2mat(adai_all_apoe4(:,strcmp(data_names,'Abeta40'))), ...
    adai_all_apoe4_abeta4240ratio, ...
    cell2mat(adai_all_apoe4(:,strcmp(data_names,'pTau217'))), ...
    cell2mat(adai_all_apoe4(:,strcmp(data_names,'GFAP'))), ...
    cell2mat(adai_all_apoe4(:,strcmp(data_names,'NfL'))) ...
%     cell2mat(adai_all_apoe4(:,strcmp(data_names,'GFR'))) ...
    ];

[R, Rpval] = corrplotg(data_corr,grp,clr,sym,'VarNames',variable_name,'testR','on','alpha',0.001);
subplot(4,2,2)
H1=scatter(1,1,1,850,'g*');
hold on
H2=scatter(1,1,1,850,'g.');
H3=scatter(1,1,1,850,'b*');
H4=scatter(1,1,1,100,'b.');
H5=scatter(1,1,1,850,'r*');
H6=scatter(1,1,1,850,'r.');
hold off
legend([H1 H2 H3 H4 H5 H6],{'APOE4 non-carrier male', 'APOE4 non-carrier female', ...
    'APOE4 heterozygous male', 'APOE4 heterozygous female',...
    'APOE4 homozygous male', 'APOE4 homozygous female'},...
    'location','southwest')
set(gca,'FontSize',14)
axis off
% print(fullfile(save_path,'supplfig-crosscorr'), '-dpng', '-r300')
% pause(0.2)


%% Forest plot
% Age, Sex, # APOE4 alleles, Hypertension, Ischemic Heart Disease, Hemoglobin A1c, Stroke, Head Trauma, LDL, CKD
ymax = 10;

yticklbl = {
    ['pTau217 ∝ ' mdl2.Formula.LinearPredictor]
    ['pTau217 ∝ ' mdl4.Formula.LinearPredictor]
    ['pTau217 ∝ ' mdl1.Formula.LinearPredictor]
    ['pTau217 ∝ ' mdl3.Formula.LinearPredictor]
    };
yticklbl = strrep(yticklbl,'1 +','x_0 +');

% yticklbl = {
%     'Model2'
%     'Model4'
%     'Model1'
%     'Model3'
%     };

clr_apoe4_homo = [1 0 0];
clr_apoe4_hetero = [1 0 1];
clr_sex = [0 0 1];
clr_age = [0 1 0];
clr_ihd = [0.3 0.3 0.3];
clr_hypertension = [0 1 1];
clr_hba1c = [0.7 0.7 0];
clr_stroke = [0.75 0.75 0.75];
clr_ldl = [0.3 0.2 0.1];
clr_gfr = [0.7 0.4 0.2];
clr_b4240 = [0.2 0.4 0.2];

h(11).fig = figure(11);
set(h(11).fig,'Position',[50 50 2200 1250])

%% mdl3
mdl = mdl3;
ci = ci3;
cii = [];
plot([0 0],[-10 10],'k','LineWidth',2)
hold on

e_apoe4_hetero = cell2mat(table2cell(mdl.Coefficients('APOE4_1','Estimate')));
e_apoe4_homo = cell2mat(table2cell(mdl.Coefficients('APOE4_2','Estimate')));
e_sex = cell2mat(table2cell(mdl.Coefficients('Sex_Male','Estimate')));
e_age = cell2mat(table2cell(mdl.Coefficients('Age','Estimate')));
ci_apoe4_hetero = ci(strcmp(mdl.CoefficientNames,'APOE4_1'),:);
ci_apoe4_homo = ci(strcmp(mdl.CoefficientNames,'APOE4_2'),:);
ci_sex = ci(strcmp(mdl.CoefficientNames,'Sex_Male'),:);
ci_age = ci(strcmp(mdl.CoefficientNames,'Age'),:);

cii = [cii; ci_apoe4_hetero; ci_apoe4_homo; ci_sex; ci_age];
E_apoe4_hetero = e_apoe4_hetero;
E_apoe4_homo = e_apoe4_homo;
E_sex = e_sex;
E_age = e_age;
y = ymax - 1;
plot(ci_apoe4_homo,[y y],'-','LineWidth',4,'Color',clr_apoe4_homo)
plot(ci_apoe4_hetero,[y-0.3 y-0.3],'-','LineWidth',4,'Color',clr_apoe4_hetero)
plot(ci_sex,[y-0.6 y-0.6],'-','LineWidth',4,'Color',clr_sex)
plot(ci_age,[y-0.9 y-0.9],'-','LineWidth',4,'Color',clr_age)

plot(e_apoe4_homo,y,'d','MarkerSize',12,'LineWidth',4,'Color',clr_apoe4_homo,'markerfacecolor',clr_apoe4_homo);
plot(e_apoe4_hetero,[y-0.3 y-0.3],'x','MarkerSize',12,'LineWidth',4,'Color',clr_apoe4_hetero,'markerfacecolor',clr_apoe4_hetero);
plot(e_sex,[y-0.6 y-0.6],'o','MarkerSize',12,'LineWidth',4,'Color',clr_sex,'markerfacecolor',clr_sex);
plot(e_age,[y-0.9 y-0.9],'^','MarkerSize',12,'LineWidth',4,'Color',clr_age,'markerfacecolor',clr_age);


%% mdl1
mdl = mdl1;
ci = ci1;

e_apoe4_hetero = cell2mat(table2cell(mdl.Coefficients('APOE4_1','Estimate')));
e_apoe4_homo = cell2mat(table2cell(mdl.Coefficients('APOE4_2','Estimate')));
e_sex = cell2mat(table2cell(mdl.Coefficients('Sex_Male','Estimate')));
e_age = cell2mat(table2cell(mdl.Coefficients('Age','Estimate')));
e_b4240 = cell2mat(table2cell(mdl.Coefficients('Abeta42/40','Estimate')));
ci_apoe4_hetero = ci(strcmp(mdl.CoefficientNames,'APOE4_1'),:);
ci_apoe4_homo = ci(strcmp(mdl.CoefficientNames,'APOE4_2'),:);
ci_sex = ci(strcmp(mdl.CoefficientNames,'Sex_Male'),:);
ci_age = ci(strcmp(mdl.CoefficientNames,'Age'),:);
ci_b4240 = ci(strcmp(mdl.CoefficientNames,'Abeta42/40'),:);

cii = [cii; ci_apoe4_hetero; ci_apoe4_homo; ci_sex; ci_age; ci_b4240];
E_apoe4_hetero = [E_apoe4_hetero; e_apoe4_hetero];
E_apoe4_homo = [E_apoe4_homo; e_apoe4_homo];
E_sex = [E_sex; e_sex];
E_age = [E_age; e_age];
E_b4240 = e_b4240;
y = ymax - 3;

plot(ci_apoe4_homo,[y y],'-','LineWidth',4,'Color',clr_apoe4_homo)
plot(ci_apoe4_hetero,[y-0.3 y-0.3],'-','LineWidth',4,'Color',clr_apoe4_hetero)
plot(ci_sex,[y-0.6 y-0.6],'-','LineWidth',4,'Color',clr_sex)
plot(ci_age,[y-0.9 y-0.9],'-','LineWidth',4,'Color',clr_age)
plot(ci_b4240,[y-1.2 y-1.2],'-','LineWidth',4,'Color',clr_b4240)

plot(e_apoe4_homo,y,'d','MarkerSize',12,'LineWidth',4,'Color',clr_apoe4_homo,'markerfacecolor',clr_apoe4_homo);
plot(e_apoe4_hetero,[y-0.3 y-0.3],'x','MarkerSize',12,'LineWidth',4,'Color',clr_apoe4_hetero,'markerfacecolor',clr_apoe4_hetero);
plot(e_sex,[y-0.6 y-0.6],'o','MarkerSize',12,'LineWidth',4,'Color',clr_sex,'markerfacecolor',clr_sex);
plot(e_age,[y-0.9 y-0.9],'^','MarkerSize',12,'LineWidth',4,'Color',clr_age,'markerfacecolor',clr_age);
plot(e_b4240,[y-1.2 y-1.2],'<','MarkerSize',12,'LineWidth',4,'Color',clr_b4240,'markerfacecolor',clr_b4240);

%% mdl4
mdl = mdl4;
ci = ci4;

e_apoe4_hetero = cell2mat(table2cell(mdl.Coefficients('APOE4_1','Estimate')));
e_apoe4_homo = cell2mat(table2cell(mdl.Coefficients('APOE4_2','Estimate')));
e_sex = cell2mat(table2cell(mdl.Coefficients('Sex_Male','Estimate')));
e_age = cell2mat(table2cell(mdl.Coefficients('Age','Estimate')));
e_hba1c = cell2mat(table2cell(mdl.Coefficients('HbA1C','Estimate')));
e_ldl = cell2mat(table2cell(mdl.Coefficients('LDL','Estimate')));
e_hypertension = cell2mat(table2cell(mdl.Coefficients('HTN_Yes','Estimate')));
e_ihd = cell2mat(table2cell(mdl.Coefficients('IHD_Yes','Estimate')));
e_stroke = cell2mat(table2cell(mdl.Coefficients('Stroke_Yes','Estimate')));
e_gfr = cell2mat(table2cell(mdl.Coefficients('GFR','Estimate')));
% e_b4240 = cell2mat(table2cell(mdl.Coefficients('Abeta42/40','Estimate')));
ci_apoe4_hetero = ci(strcmp(mdl.CoefficientNames,'APOE4_1'),:);
ci_apoe4_homo = ci(strcmp(mdl.CoefficientNames,'APOE4_2'),:);
ci_sex = ci(strcmp(mdl.CoefficientNames,'Sex_Male'),:);
ci_age = ci(strcmp(mdl.CoefficientNames,'Age'),:);
ci_hba1c = ci(strcmp(mdl.CoefficientNames,'HbA1C'),:);
ci_ldl = ci(strcmp(mdl.CoefficientNames,'LDL'),:);
ci_hypertension = ci(strcmp(mdl.CoefficientNames,'HTN_Yes'),:);
ci_ihd = ci(strcmp(mdl.CoefficientNames,'IHD_Yes'),:);
ci_stroke = ci(strcmp(mdl.CoefficientNames,'Stroke_Yes'),:);
ci_gfr = ci(strcmp(mdl.CoefficientNames,'GFR'),:);
% ci_b4240 = ci(strcmp(mdl.CoefficientNames,'Abeta42/40'),:);

cii = [cii; ci_apoe4_hetero; ci_apoe4_homo; ci_sex; ci_age; ...
    ci_hba1c; ci_ldl; ci_hypertension; ci_ihd; ci_stroke; ci_gfr ]; % ci_b4240
E_apoe4_hetero = [E_apoe4_hetero; e_apoe4_hetero];
E_apoe4_homo = [E_apoe4_homo; e_apoe4_homo];
E_sex = [E_sex; e_sex];
E_age = [E_age; e_age];
E_hba1c = e_hba1c;
E_ldl = e_ldl;
E_hypertension = e_hypertension;
E_ihd = e_ihd;
E_stroke = e_stroke;
E_gfr = e_gfr;
% E_b4240 = e_b4240;
y = ymax - 5;

plot(ci_apoe4_homo,[y y],'-','LineWidth',4,'Color',clr_apoe4_homo)
plot(ci_apoe4_hetero,[y-0.3 y-0.3],'-','LineWidth',4,'Color',clr_apoe4_hetero)
plot(ci_sex,[y-0.6 y-0.6],'-','LineWidth',4,'Color',clr_sex)
plot(ci_age,[y-0.9 y-0.9],'-','LineWidth',4,'Color',clr_age)
plot(ci_hba1c,[y-1.2 y-1.2],'-','LineWidth',4,'Color',clr_hba1c)
plot(ci_ldl,[y-1.5 y-1.5],'-','LineWidth',4,'Color',clr_ldl)
plot(ci_hypertension,[y-1.8 y-1.8],'-','LineWidth',4,'Color',clr_hypertension)
plot(ci_ihd,[y-2.1 y-2.1],'-','LineWidth',4,'Color',clr_ihd)
plot(ci_stroke,[y-2.4 y-2.4],'-','LineWidth',4,'Color',clr_stroke)
plot(ci_gfr,[y-2.7 y-2.7],'-','LineWidth',4,'Color',clr_gfr)
% plot(ci_b4240,[y-1.2 y-1.2],'-','LineWidth',4,'Color',clr_b4240)

plot(e_apoe4_homo,y,'d','MarkerSize',12,'LineWidth',4,'Color',clr_apoe4_homo,'markerfacecolor',clr_apoe4_homo);
plot(e_apoe4_hetero,[y-0.3 y-0.3],'x','MarkerSize',12,'LineWidth',4,'Color',clr_apoe4_hetero,'markerfacecolor',clr_apoe4_hetero);
plot(e_sex,[y-0.6 y-0.6],'o','MarkerSize',12,'LineWidth',4,'Color',clr_sex,'markerfacecolor',clr_sex);
plot(e_age,[y-0.9 y-0.9],'^','MarkerSize',12,'LineWidth',4,'Color',clr_age,'markerfacecolor',clr_age);
plot(e_hba1c,[y-1.2 y-1.2],'s','MarkerSize',12,'LineWidth',4,'Color',clr_hba1c,'markerfacecolor',clr_hba1c);
plot(e_ldl,[y-1.5 y-1.5],'s','MarkerSize',12,'LineWidth',4,'Color',clr_ldl,'markerfacecolor',clr_ldl);
plot(e_hypertension,[y-1.8 y-1.8],'>','MarkerSize',12,'LineWidth',4,'Color',clr_hypertension,'markerfacecolor',clr_hypertension);
plot(e_ihd,[y-2.1 y-2.1],'>','MarkerSize',12,'LineWidth',4,'Color',clr_ihd,'markerfacecolor',clr_ihd);
plot(e_stroke,[y-2.4 y-2.4],'>','MarkerSize',12,'LineWidth',4,'Color',clr_stroke,'markerfacecolor',clr_stroke);
plot(e_gfr,[y-2.7 y-2.7],'>','MarkerSize',12,'LineWidth',4,'Color',clr_gfr,'markerfacecolor',clr_gfr);
% plot(e_b4240,[y-1.2 y-1.2],'<','MarkerSize',12,'LineWidth',4,'Color',clr_b4240,'markerfacecolor',clr_b4240);


%% mdl2
mdl = mdl2;
ci = ci2;

e_apoe4_hetero = cell2mat(table2cell(mdl.Coefficients('APOE4_1','Estimate')));
e_apoe4_homo = cell2mat(table2cell(mdl.Coefficients('APOE4_2','Estimate')));
e_sex = cell2mat(table2cell(mdl.Coefficients('Sex_Male','Estimate')));
e_age = cell2mat(table2cell(mdl.Coefficients('Age','Estimate')));
e_hba1c = cell2mat(table2cell(mdl.Coefficients('HbA1C','Estimate')));
e_ldl = cell2mat(table2cell(mdl.Coefficients('LDL','Estimate')));
e_hypertension = cell2mat(table2cell(mdl.Coefficients('HTN_Yes','Estimate')));
e_ihd = cell2mat(table2cell(mdl.Coefficients('IHD_Yes','Estimate')));
e_stroke = cell2mat(table2cell(mdl.Coefficients('Stroke_Yes','Estimate')));
e_gfr = cell2mat(table2cell(mdl.Coefficients('GFR','Estimate')));
e_b4240 = cell2mat(table2cell(mdl.Coefficients('Abeta42/40','Estimate')));
ci_apoe4_hetero = ci(strcmp(mdl.CoefficientNames,'APOE4_1'),:);
ci_apoe4_homo = ci(strcmp(mdl.CoefficientNames,'APOE4_2'),:);
ci_sex = ci(strcmp(mdl.CoefficientNames,'Sex_Male'),:);
ci_age = ci(strcmp(mdl.CoefficientNames,'Age'),:);
ci_hba1c = ci(strcmp(mdl.CoefficientNames,'HbA1C'),:);
ci_ldl = ci(strcmp(mdl.CoefficientNames,'LDL'),:);
ci_hypertension = ci(strcmp(mdl.CoefficientNames,'HTN_Yes'),:);
ci_ihd = ci(strcmp(mdl.CoefficientNames,'IHD_Yes'),:);
ci_stroke = ci(strcmp(mdl.CoefficientNames,'Stroke_Yes'),:);
ci_gfr = ci(strcmp(mdl.CoefficientNames,'GFR'),:);
ci_b4240 = ci(strcmp(mdl.CoefficientNames,'Abeta42/40'),:);

cii = [cii; ci_apoe4_hetero; ci_apoe4_homo; ci_sex; ci_age; ...
    ci_hba1c; ci_ldl; ci_hypertension; ci_ihd; ci_stroke; ci_gfr; ci_b4240 ]; 
E_apoe4_hetero = [E_apoe4_hetero; e_apoe4_hetero];
E_apoe4_homo = [E_apoe4_homo; e_apoe4_homo];
E_sex = [E_sex; e_sex];
E_age = [E_age; e_age];
E_hba1c = [E_hba1c; e_hba1c];
E_ldl = [E_ldl; e_ldl];
E_hypertension = [E_hypertension; e_hypertension];
E_ihd = [E_ihd; e_ihd];
E_stroke = [E_stroke; e_stroke];
E_gfr = [E_gfr; e_gfr];
E_b4240 = [E_b4240; e_b4240];
y = ymax - 8.3;

plot(ci_apoe4_homo,[y y],'-','LineWidth',4,'Color',clr_apoe4_homo)
plot(ci_apoe4_hetero,[y-0.3 y-0.3],'-','LineWidth',4,'Color',clr_apoe4_hetero)
plot(ci_sex,[y-0.6 y-0.6],'-','LineWidth',4,'Color',clr_sex)
plot(ci_age,[y-0.9 y-0.9],'-','LineWidth',4,'Color',clr_age)
plot(ci_hba1c,[y-1.2 y-1.2],'-','LineWidth',4,'Color',clr_hba1c)
plot(ci_ldl,[y-1.5 y-1.5],'-','LineWidth',4,'Color',clr_ldl)
plot(ci_hypertension,[y-1.8 y-1.8],'-','LineWidth',4,'Color',clr_hypertension)
plot(ci_ihd,[y-2.1 y-2.1],'-','LineWidth',4,'Color',clr_ihd)
plot(ci_stroke,[y-2.4 y-2.4],'-','LineWidth',4,'Color',clr_stroke)
plot(ci_gfr,[y-2.7 y-2.7],'-','LineWidth',4,'Color',clr_gfr)
plot(ci_b4240,[y-3.0 y-3.0],'-','LineWidth',4,'Color',clr_b4240)

H1 = plot(e_apoe4_homo,y,'d','MarkerSize',12,'LineWidth',4,'Color',clr_apoe4_homo,'markerfacecolor',clr_apoe4_homo);
H2 = plot(e_apoe4_hetero,[y-0.3 y-0.3],'x','MarkerSize',12,'LineWidth',4,'Color',clr_apoe4_hetero,'markerfacecolor',clr_apoe4_hetero);
H3 = plot(e_sex,[y-0.6 y-0.6],'o','MarkerSize',12,'LineWidth',4,'Color',clr_sex,'markerfacecolor',clr_sex);
H4 = plot(e_age,[y-0.9 y-0.9],'^','MarkerSize',12,'LineWidth',4,'Color',clr_age,'markerfacecolor',clr_age);
H5 = plot(e_hba1c,[y-1.2 y-1.2],'s','MarkerSize',12,'LineWidth',4,'Color',clr_hba1c,'markerfacecolor',clr_hba1c);
H6 = plot(e_ldl,[y-1.5 y-1.5],'s','MarkerSize',12,'LineWidth',4,'Color',clr_ldl,'markerfacecolor',clr_ldl);
H7 = plot(e_hypertension,[y-1.8 y-1.8],'>','MarkerSize',12,'LineWidth',4,'Color',clr_hypertension,'markerfacecolor',clr_hypertension);
H8 = plot(e_ihd,[y-2.1 y-2.1],'>','MarkerSize',12,'LineWidth',4,'Color',clr_ihd,'markerfacecolor',clr_ihd);
H9 = plot(e_stroke,[y-2.4 y-2.4],'>','MarkerSize',12,'LineWidth',4,'Color',clr_stroke,'markerfacecolor',clr_stroke);
H10 = plot(e_gfr,[y-2.7 y-2.7],'>','MarkerSize',12,'LineWidth',4,'Color',clr_gfr,'markerfacecolor',clr_gfr);
H11 = plot(e_b4240,[y-3.0 y-3.0],'<','MarkerSize',12,'LineWidth',4,'Color',clr_b4240,'markerfacecolor',clr_b4240);


%%
hold off
grid on
ylim([-1.6 9.5])
% if max(abs(cii(:))) < 7
%     xlim([-1 7])
% else
%     xlim([0 1.05*max(abs(cii(:)))])
% end
xlim([ -1.05*(max(abs(cii(:)))) 1.05*(max(abs(cii(:)))) ])
xlabel({'Regression coeficients','Age and GFR divided by factor 10 before regression','Abeta42/40 multiplied by factor 10 before regression'})
legend([H1(1,1); H2(1,1); H3(1,1); H4(1,1); H5(1,1); H6(1,1); H7(1,1); H8(1,1); H9(1,1); H10(1,1); H11(1,1);],{
    'APOE4 homozygous'
    'APOE4 heterozygous'
    'Male sex'
    'Age'
    'HbA1C'
    'LDL'
    'Hypertension'
    'IHD'
    'Stroke'
    'GFR'
    'A\beta42/40'
    },'Location','West')
set(gca,'Linewidth',2,'FontSize',14,'YTick',[1.7 5 7 9],'YTickLabel',yticklbl) % 'xscale','log'
ytickangle(40)

%% Forest plot graphs by variable

h(2).fig = figure(2);
set(h(2).fig,'Position',[50 50 1000 1250])

subplot(5,1,[1 2])
plot([0 0],[-10 10],'k','LineWidth',2)
hold on

mdl = mdl3;
ci = ci3;
e1_apoe4_hetero = cell2mat(table2cell(mdl.Coefficients('APOE4_1','Estimate')));
e1_apoe4_homo = cell2mat(table2cell(mdl.Coefficients('APOE4_2','Estimate')));
e1_sex = cell2mat(table2cell(mdl.Coefficients('Sex_Male','Estimate')));
e1_age = cell2mat(table2cell(mdl.Coefficients('Age','Estimate')));
e1_gfap = cell2mat(table2cell(mdl.Coefficients('GFAP','Estimate')));
e1_nfl = cell2mat(table2cell(mdl.Coefficients('NfL','Estimate')));
ci1_apoe4_hetero = ci(strcmp(mdl.CoefficientNames,'APOE4_1'),:);
ci1_apoe4_homo = ci(strcmp(mdl.CoefficientNames,'APOE4_2'),:);
ci1_sex = ci(strcmp(mdl.CoefficientNames,'Sex_Male'),:);
ci1_age = ci(strcmp(mdl.CoefficientNames,'Age'),:);
ci1_gfap = ci(strcmp(mdl.CoefficientNames,'GFAP'),:);
ci1_nfl = ci(strcmp(mdl.CoefficientNames,'NfL'),:);

mdl = mdl1;
ci = ci1;
e2_apoe4_hetero = cell2mat(table2cell(mdl.Coefficients('APOE4_1','Estimate')));
e2_apoe4_homo = cell2mat(table2cell(mdl.Coefficients('APOE4_2','Estimate')));
e2_sex = cell2mat(table2cell(mdl.Coefficients('Sex_Male','Estimate')));
e2_age = cell2mat(table2cell(mdl.Coefficients('Age','Estimate')));
e2_gfap = cell2mat(table2cell(mdl.Coefficients('GFAP','Estimate')));
e2_nfl = cell2mat(table2cell(mdl.Coefficients('NfL','Estimate')));
e2_b4240 = cell2mat(table2cell(mdl.Coefficients('Abeta42/40','Estimate')));
ci2_apoe4_hetero = ci(strcmp(mdl.CoefficientNames,'APOE4_1'),:);
ci2_apoe4_homo = ci(strcmp(mdl.CoefficientNames,'APOE4_2'),:);
ci2_sex = ci(strcmp(mdl.CoefficientNames,'Sex_Male'),:);
ci2_age = ci(strcmp(mdl.CoefficientNames,'Age'),:);
ci2_gfap = ci(strcmp(mdl.CoefficientNames,'GFAP'),:);
ci2_nfl = ci(strcmp(mdl.CoefficientNames,'NfL'),:);
ci2_b4240 = ci(strcmp(mdl.CoefficientNames,'Abeta42/40'),:);

y = ymax - 1;
plot(ci1_apoe4_homo,[y y],'-','LineWidth',4,'Color',clr_apoe4_homo)
plot(ci1_apoe4_hetero,[y-0.3 y-0.3],'-','LineWidth',4,'Color',clr_apoe4_homo)
plot(ci1_sex,[y-0.6 y-0.6],'-','LineWidth',4,'Color',clr_apoe4_homo)
plot(ci1_age,[y-0.9 y-0.9],'-','LineWidth',4,'Color',clr_apoe4_homo)
plot(ci1_gfap,[y-1.2 y-1.2],'-','LineWidth',4,'Color',clr_apoe4_homo)
plot(ci1_nfl,[y-1.5 y-1.5],'-','LineWidth',4,'Color',clr_apoe4_homo)

H1=plot(e1_apoe4_homo,y,'d','MarkerSize',12,'LineWidth',4,'Color',clr_apoe4_homo,'markerfacecolor',clr_apoe4_homo);
plot(e1_apoe4_hetero,[y-0.3 y-0.3],'d','MarkerSize',12,'LineWidth',4,'Color',clr_apoe4_homo,'markerfacecolor',clr_apoe4_homo);
plot(e1_sex,[y-0.6 y-0.6],'d','MarkerSize',12,'LineWidth',4,'Color',clr_apoe4_homo,'markerfacecolor',clr_apoe4_homo);
plot(e1_age,[y-0.9 y-0.9],'d','MarkerSize',12,'LineWidth',4,'Color',clr_apoe4_homo,'markerfacecolor',clr_apoe4_homo);
plot(e1_gfap,y-1.2,'d','MarkerSize',12,'LineWidth',4,'Color',clr_apoe4_homo,'markerfacecolor',clr_apoe4_homo);
plot(e1_nfl,y-1.5,'d','MarkerSize',12,'LineWidth',4,'Color',clr_apoe4_homo,'markerfacecolor',clr_apoe4_homo);

plot(ci2_apoe4_homo,[y-0.15 y-0.15],'-','LineWidth',4,'Color',clr_sex)
plot(ci2_apoe4_hetero,[y-0.45 y-0.45],'-','LineWidth',4,'Color',clr_sex)
plot(ci2_sex,[y-0.75 y-0.75],'-','LineWidth',4,'Color',clr_sex)
plot(ci2_age,[y-1.05 y-1.05],'-','LineWidth',4,'Color',clr_sex)
plot(ci2_gfap,[y-1.35 y-1.35],'-','LineWidth',4,'Color',clr_sex)
plot(ci2_nfl,[y-1.65 y-1.65],'-','LineWidth',4,'Color',clr_sex)
plot(ci2_b4240,[y-1.95 y-1.95],'-','LineWidth',4,'Color',clr_sex)

H2=plot(e2_apoe4_homo,y-0.15,'>','MarkerSize',12,'LineWidth',4,'Color',clr_sex,'markerfacecolor',clr_sex);
plot(e2_apoe4_hetero,y-0.45,'>','MarkerSize',12,'LineWidth',4,'Color',clr_sex,'markerfacecolor',clr_sex);
plot(e2_sex,y-0.75,'>','MarkerSize',12,'LineWidth',4,'Color',clr_sex,'markerfacecolor',clr_sex);
plot(e2_age,y-1.05,'>','MarkerSize',12,'LineWidth',4,'Color',clr_sex,'markerfacecolor',clr_sex);
plot(e2_gfap,y-1.35,'>','MarkerSize',12,'LineWidth',4,'Color',clr_sex,'markerfacecolor',clr_sex);
plot(e2_nfl,y-1.65,'>','MarkerSize',12,'LineWidth',4,'Color',clr_sex,'markerfacecolor',clr_sex);
plot(e2_b4240,y-1.95,'>','MarkerSize',12,'LineWidth',4,'Color',clr_sex,'markerfacecolor',clr_sex);

text(-0.38,8.85,'MODEL 1','Fontsize',20,'FontWeight','bold')
hold off

axis([-0.55 0.55 6.9 9.2])
grid on
legend([H1 H2],{'Excluding A\beta_{42/40}','Including A\beta_{42/40}'},'Location','East')
set(gca,'FontSize',14,'LineWidth',2,...
    'YTick',y-1.8:0.3:y,'YtickLabel',flip({'APOE4_{Hom}','APOE4_{Het}','Sex_{Male}','Age','GFAP','NfL','A\beta_{42/40}'}),...
    'XTick',-1:0.1:1,'XTickLabel',' ')





subplot(5,1,[3 4 5])
plot([0 0],[-10 10],'k','LineWidth',2)
hold on

mdl = mdl4;
ci = ci4;
e1_apoe4_hetero = cell2mat(table2cell(mdl.Coefficients('APOE4_1','Estimate')));
e1_apoe4_homo = cell2mat(table2cell(mdl.Coefficients('APOE4_2','Estimate')));
e1_sex = cell2mat(table2cell(mdl.Coefficients('Sex_Male','Estimate')));
e1_age = cell2mat(table2cell(mdl.Coefficients('Age','Estimate')));
e1_gfap = cell2mat(table2cell(mdl.Coefficients('GFAP','Estimate')));
e1_nfl = cell2mat(table2cell(mdl.Coefficients('NfL','Estimate')));
e1_hba1c = cell2mat(table2cell(mdl.Coefficients('HbA1C','Estimate')));
e1_ldl = cell2mat(table2cell(mdl.Coefficients('LDL','Estimate')));
e1_hypertension = cell2mat(table2cell(mdl.Coefficients('HTN_Yes','Estimate')));
e1_ihd = cell2mat(table2cell(mdl.Coefficients('IHD_Yes','Estimate')));
e1_stroke = cell2mat(table2cell(mdl.Coefficients('Stroke_Yes','Estimate')));
e1_gfr = cell2mat(table2cell(mdl.Coefficients('GFR','Estimate')));

ci1_apoe4_hetero = ci(strcmp(mdl.CoefficientNames,'APOE4_1'),:);
ci1_apoe4_homo = ci(strcmp(mdl.CoefficientNames,'APOE4_2'),:);
ci1_sex = ci(strcmp(mdl.CoefficientNames,'Sex_Male'),:);
ci1_age = ci(strcmp(mdl.CoefficientNames,'Age'),:);
ci1_gfap = ci(strcmp(mdl.CoefficientNames,'GFAP'),:);
ci1_nfl = ci(strcmp(mdl.CoefficientNames,'NfL'),:);
ci1_hba1c = ci(strcmp(mdl.CoefficientNames,'HbA1C'),:);
ci1_ldl = ci(strcmp(mdl.CoefficientNames,'LDL'),:);
ci1_hypertension = ci(strcmp(mdl.CoefficientNames,'HTN_Yes'),:);
ci1_ihd = ci(strcmp(mdl.CoefficientNames,'IHD_Yes'),:);
ci1_stroke = ci(strcmp(mdl.CoefficientNames,'Stroke_Yes'),:);
ci1_gfr = ci(strcmp(mdl.CoefficientNames,'GFR'),:);

mdl = mdl2;
ci = ci2;
e2_apoe4_hetero = cell2mat(table2cell(mdl.Coefficients('APOE4_1','Estimate')));
e2_apoe4_homo = cell2mat(table2cell(mdl.Coefficients('APOE4_2','Estimate')));
e2_sex = cell2mat(table2cell(mdl.Coefficients('Sex_Male','Estimate')));
e2_age = cell2mat(table2cell(mdl.Coefficients('Age','Estimate')));
e2_gfap = cell2mat(table2cell(mdl.Coefficients('GFAP','Estimate')));
e2_nfl = cell2mat(table2cell(mdl.Coefficients('NfL','Estimate')));
e2_hba1c = cell2mat(table2cell(mdl.Coefficients('HbA1C','Estimate')));
e2_ldl = cell2mat(table2cell(mdl.Coefficients('LDL','Estimate')));
e2_hypertension = cell2mat(table2cell(mdl.Coefficients('HTN_Yes','Estimate')));
e2_ihd = cell2mat(table2cell(mdl.Coefficients('IHD_Yes','Estimate')));
e2_stroke = cell2mat(table2cell(mdl.Coefficients('Stroke_Yes','Estimate')));
e2_gfr = cell2mat(table2cell(mdl.Coefficients('GFR','Estimate')));
e2_b4240 = cell2mat(table2cell(mdl.Coefficients('Abeta42/40','Estimate')));

ci2_apoe4_hetero = ci(strcmp(mdl.CoefficientNames,'APOE4_1'),:);
ci2_apoe4_homo = ci(strcmp(mdl.CoefficientNames,'APOE4_2'),:);
ci2_sex = ci(strcmp(mdl.CoefficientNames,'Sex_Male'),:);
ci2_age = ci(strcmp(mdl.CoefficientNames,'Age'),:);
ci2_gfap = ci(strcmp(mdl.CoefficientNames,'GFAP'),:);
ci2_nfl = ci(strcmp(mdl.CoefficientNames,'NfL'),:);
ci2_hba1c = ci(strcmp(mdl.CoefficientNames,'HbA1C'),:);
ci2_ldl = ci(strcmp(mdl.CoefficientNames,'LDL'),:);
ci2_hypertension = ci(strcmp(mdl.CoefficientNames,'HTN_Yes'),:);
ci2_ihd = ci(strcmp(mdl.CoefficientNames,'IHD_Yes'),:);
ci2_stroke = ci(strcmp(mdl.CoefficientNames,'Stroke_Yes'),:);
ci2_gfr = ci(strcmp(mdl.CoefficientNames,'GFR'),:);
ci2_b4240 = ci(strcmp(mdl.CoefficientNames,'Abeta42/40'),:);

y = ymax - 1;
plot(ci1_apoe4_homo,[y y],'-','LineWidth',4,'Color',clr_apoe4_homo)
plot(ci1_apoe4_hetero,[y-0.3 y-0.3],'-','LineWidth',4,'Color',clr_apoe4_homo)
plot(ci1_sex,[y-0.6 y-0.6],'-','LineWidth',4,'Color',clr_apoe4_homo)
plot(ci1_age,[y-0.9 y-0.9],'-','LineWidth',4,'Color',clr_apoe4_homo)
plot(ci1_gfap,[y-1.2 y-1.2],'-','LineWidth',4,'Color',clr_apoe4_homo)
plot(ci1_nfl,[y-1.5 y-1.5],'-','LineWidth',4,'Color',clr_apoe4_homo)
plot(ci1_hba1c,[y-1.8 y-1.8],'-','LineWidth',4,'Color',clr_apoe4_homo)
plot(ci1_ldl,[y-2.1 y-2.1],'-','LineWidth',4,'Color',clr_apoe4_homo)
plot(ci1_hypertension,[y-2.4 y-2.4],'-','LineWidth',4,'Color',clr_apoe4_homo)
plot(ci1_ihd,[y-2.7 y-2.7],'-','LineWidth',4,'Color',clr_apoe4_homo)
plot(ci1_stroke,[y-3.0 y-3.0],'-','LineWidth',4,'Color',clr_apoe4_homo)
plot(ci1_gfr,[y-3.3 y-3.3],'-','LineWidth',4,'Color',clr_apoe4_homo)

plot(e1_apoe4_homo,y,'d','MarkerSize',12,'LineWidth',4,'Color',clr_apoe4_homo,'markerfacecolor',clr_apoe4_homo);
plot(e1_apoe4_hetero,[y-0.3 y-0.3],'d','MarkerSize',12,'LineWidth',4,'Color',clr_apoe4_homo,'markerfacecolor',clr_apoe4_homo);
plot(e1_sex,[y-0.6 y-0.6],'d','MarkerSize',12,'LineWidth',4,'Color',clr_apoe4_homo,'markerfacecolor',clr_apoe4_homo);
plot(e1_age,[y-0.9 y-0.9],'d','MarkerSize',12,'LineWidth',4,'Color',clr_apoe4_homo,'markerfacecolor',clr_apoe4_homo);
plot(e1_gfap,[y-1.2 y-1.2],'d','MarkerSize',12,'LineWidth',4,'Color',clr_apoe4_homo,'markerfacecolor',clr_apoe4_homo);
plot(e1_nfl,[y-1.5 y-1.5],'d','MarkerSize',12,'LineWidth',4,'Color',clr_apoe4_homo,'markerfacecolor',clr_apoe4_homo);
plot(e1_hba1c,y-1.8,'d','MarkerSize',12,'LineWidth',4,'Color',clr_apoe4_homo,'markerfacecolor',clr_apoe4_homo);
plot(e1_ldl,y-2.1,'d','MarkerSize',12,'LineWidth',4,'Color',clr_apoe4_homo,'markerfacecolor',clr_apoe4_homo);
plot(e1_hypertension,y-2.4,'d','MarkerSize',12,'LineWidth',4,'Color',clr_apoe4_homo,'markerfacecolor',clr_apoe4_homo);
plot(e1_ihd,y-2.7,'d','MarkerSize',12,'LineWidth',4,'Color',clr_apoe4_homo,'markerfacecolor',clr_apoe4_homo);
plot(e1_stroke,y-3.0,'d','MarkerSize',12,'LineWidth',4,'Color',clr_apoe4_homo,'markerfacecolor',clr_apoe4_homo);
plot(e1_gfr,y-3.3,'d','MarkerSize',12,'LineWidth',4,'Color',clr_apoe4_homo,'markerfacecolor',clr_apoe4_homo);

plot(ci2_apoe4_homo,[y-0.15 y-0.15],'-','LineWidth',4,'Color',clr_sex)
plot(ci2_apoe4_hetero,[y-0.45 y-0.45],'-','LineWidth',4,'Color',clr_sex)
plot(ci2_sex,[y-0.75 y-0.75],'-','LineWidth',4,'Color',clr_sex)
plot(ci2_age,[y-1.05 y-1.05],'-','LineWidth',4,'Color',clr_sex)
plot(ci2_gfap,[y-1.35 y-1.35],'-','LineWidth',4,'Color',clr_sex)
plot(ci2_nfl,[y-1.65 y-1.65],'-','LineWidth',4,'Color',clr_sex)
plot(ci2_hba1c,[y-1.95 y-1.95],'-','LineWidth',4,'Color',clr_sex)
plot(ci2_ldl,[y-2.25 y-2.25],'-','LineWidth',4,'Color',clr_sex)
plot(ci2_hypertension,[y-2.55 y-2.55],'-','LineWidth',4,'Color',clr_sex)
plot(ci2_ihd,[y-2.85 y-2.85],'-','LineWidth',4,'Color',clr_sex)
plot(ci2_stroke,[y-3.15 y-3.15],'-','LineWidth',4,'Color',clr_sex)
plot(ci2_gfr,[y-3.45 y-3.45],'-','LineWidth',4,'Color',clr_sex)
plot(ci2_b4240,[y-3.75 y-3.75],'-','LineWidth',4,'Color',clr_sex)

plot(e2_apoe4_homo,y-0.15,'>','MarkerSize',12,'LineWidth',4,'Color',clr_sex,'markerfacecolor',clr_sex);
plot(e2_apoe4_hetero,y-0.45,'>','MarkerSize',12,'LineWidth',4,'Color',clr_sex,'markerfacecolor',clr_sex);
plot(e2_sex,y-0.75,'>','MarkerSize',12,'LineWidth',4,'Color',clr_sex,'markerfacecolor',clr_sex);
plot(e2_age,y-1.05,'>','MarkerSize',12,'LineWidth',4,'Color',clr_sex,'markerfacecolor',clr_sex);
plot(e2_gfap,y-1.35,'>','MarkerSize',12,'LineWidth',4,'Color',clr_sex,'markerfacecolor',clr_sex);
plot(e2_nfl,y-1.65,'>','MarkerSize',12,'LineWidth',4,'Color',clr_sex,'markerfacecolor',clr_sex);
plot(e2_hba1c,y-1.95,'>','MarkerSize',12,'LineWidth',4,'Color',clr_sex,'markerfacecolor',clr_sex);
plot(e2_ldl,y-2.25,'>','MarkerSize',12,'LineWidth',4,'Color',clr_sex,'markerfacecolor',clr_sex);
plot(e2_hypertension,y-2.55,'>','MarkerSize',12,'LineWidth',4,'Color',clr_sex,'markerfacecolor',clr_sex);
plot(e2_ihd,y-2.85,'>','MarkerSize',12,'LineWidth',4,'Color',clr_sex,'markerfacecolor',clr_sex);
plot(e2_stroke,y-3.15,'>','MarkerSize',12,'LineWidth',4,'Color',clr_sex,'markerfacecolor',clr_sex);
plot(e2_gfr,y-3.45,'>','MarkerSize',12,'LineWidth',4,'Color',clr_sex,'markerfacecolor',clr_sex);
plot(e2_b4240,y-3.75,'>','MarkerSize',12,'LineWidth',4,'Color',clr_sex,'markerfacecolor',clr_sex);

text(-0.38,8.85,'MODEL 2','Fontsize',20,'FontWeight','bold')
hold off

axis([-0.55 0.55 5.1 9.2])

grid on
xlabel({'Regression coeficients',...
    'Age, HbA1c and GFR divided by factor 10 before regression',...
    'GFAP, NfL and LDL divided by factor 100 before regression',...
    'A\beta_{42/40} multiplied by factor 10 before regression'})
set(gca,'FontSize',14,'LineWidth',2,...
    'YTick',y-3.6:0.3:y,'YtickLabel',flip({'APOE4_{Hom}','APOE4_{Het}','Sex_{Male}','Age','GFAP','NfL','HbA1c','LDL','Hypertension','IHD','Stroke','GFR','A\beta_{42/40}'}))


%% Forest plot graphs by variable - MODEL3

h(3).fig = figure(3);
set(h(3).fig,'Position',[50 50 1000 1250])

subplot(5,1,[3 4 5])
plot([0 0],[-10 10],'k','LineWidth',2)
hold on

mdl = mdl6;
ci = ci6;
e1_apoe4_hetero = cell2mat(table2cell(mdl.Coefficients('APOE4_1','Estimate')));
e1_apoe4_homo = cell2mat(table2cell(mdl.Coefficients('APOE4_2','Estimate')));
e1_sex = cell2mat(table2cell(mdl.Coefficients('Sex_Male','Estimate')));
e1_age = cell2mat(table2cell(mdl.Coefficients('Age','Estimate')));
e1_gfap = cell2mat(table2cell(mdl.Coefficients('GFAP','Estimate')));
e1_nfl = cell2mat(table2cell(mdl.Coefficients('NfL','Estimate')));
e1_hba1c = cell2mat(table2cell(mdl.Coefficients('HbA1C','Estimate')));
e1_ldl = cell2mat(table2cell(mdl.Coefficients('LDL','Estimate')));
e1_hypertension = cell2mat(table2cell(mdl.Coefficients('HTN_Yes','Estimate')));
e1_ihd = cell2mat(table2cell(mdl.Coefficients('IHD_Yes','Estimate')));
e1_stroke = cell2mat(table2cell(mdl.Coefficients('Stroke_Yes','Estimate')));
e1_ckd = cell2mat(table2cell(mdl.Coefficients('CKD_Yes','Estimate')));

ci1_apoe4_hetero = ci(strcmp(mdl.CoefficientNames,'APOE4_1'),:);
ci1_apoe4_homo = ci(strcmp(mdl.CoefficientNames,'APOE4_2'),:);
ci1_sex = ci(strcmp(mdl.CoefficientNames,'Sex_Male'),:);
ci1_age = ci(strcmp(mdl.CoefficientNames,'Age'),:);
ci1_gfap = ci(strcmp(mdl.CoefficientNames,'GFAP'),:);
ci1_nfl = ci(strcmp(mdl.CoefficientNames,'NfL'),:);
ci1_hba1c = ci(strcmp(mdl.CoefficientNames,'HbA1C'),:);
ci1_ldl = ci(strcmp(mdl.CoefficientNames,'LDL'),:);
ci1_hypertension = ci(strcmp(mdl.CoefficientNames,'HTN_Yes'),:);
ci1_ihd = ci(strcmp(mdl.CoefficientNames,'IHD_Yes'),:);
ci1_stroke = ci(strcmp(mdl.CoefficientNames,'Stroke_Yes'),:);
ci1_ckd = ci(strcmp(mdl.CoefficientNames,'CKD_Yes'),:);

mdl = mdl5;
ci = ci5;
e2_apoe4_hetero = cell2mat(table2cell(mdl.Coefficients('APOE4_1','Estimate')));
e2_apoe4_homo = cell2mat(table2cell(mdl.Coefficients('APOE4_2','Estimate')));
e2_sex = cell2mat(table2cell(mdl.Coefficients('Sex_Male','Estimate')));
e2_age = cell2mat(table2cell(mdl.Coefficients('Age','Estimate')));
e2_gfap = cell2mat(table2cell(mdl.Coefficients('GFAP','Estimate')));
e2_nfl = cell2mat(table2cell(mdl.Coefficients('NfL','Estimate')));
e2_hba1c = cell2mat(table2cell(mdl.Coefficients('HbA1C','Estimate')));
e2_ldl = cell2mat(table2cell(mdl.Coefficients('LDL','Estimate')));
e2_hypertension = cell2mat(table2cell(mdl.Coefficients('HTN_Yes','Estimate')));
e2_ihd = cell2mat(table2cell(mdl.Coefficients('IHD_Yes','Estimate')));
e2_stroke = cell2mat(table2cell(mdl.Coefficients('Stroke_Yes','Estimate')));
e2_ckd = cell2mat(table2cell(mdl.Coefficients('CKD_Yes','Estimate')));
e2_b4240 = cell2mat(table2cell(mdl.Coefficients('Abeta42/40','Estimate')));

ci2_apoe4_hetero = ci(strcmp(mdl.CoefficientNames,'APOE4_1'),:);
ci2_apoe4_homo = ci(strcmp(mdl.CoefficientNames,'APOE4_2'),:);
ci2_sex = ci(strcmp(mdl.CoefficientNames,'Sex_Male'),:);
ci2_age = ci(strcmp(mdl.CoefficientNames,'Age'),:);
ci2_gfap = ci(strcmp(mdl.CoefficientNames,'GFAP'),:);
ci2_nfl = ci(strcmp(mdl.CoefficientNames,'NfL'),:);
ci2_hba1c = ci(strcmp(mdl.CoefficientNames,'HbA1C'),:);
ci2_ldl = ci(strcmp(mdl.CoefficientNames,'LDL'),:);
ci2_hypertension = ci(strcmp(mdl.CoefficientNames,'HTN_Yes'),:);
ci2_ihd = ci(strcmp(mdl.CoefficientNames,'IHD_Yes'),:);
ci2_stroke = ci(strcmp(mdl.CoefficientNames,'Stroke_Yes'),:);
ci2_ckd = ci(strcmp(mdl.CoefficientNames,'CKD_Yes'),:);
ci2_b4240 = ci(strcmp(mdl.CoefficientNames,'Abeta42/40'),:);

y = ymax - 1;
plot(ci1_apoe4_homo,[y y],'-','LineWidth',4,'Color',clr_apoe4_homo)
plot(ci1_apoe4_hetero,[y-0.3 y-0.3],'-','LineWidth',4,'Color',clr_apoe4_homo)
plot(ci1_sex,[y-0.6 y-0.6],'-','LineWidth',4,'Color',clr_apoe4_homo)
plot(ci1_age,[y-0.9 y-0.9],'-','LineWidth',4,'Color',clr_apoe4_homo)
plot(ci1_gfap,[y-1.2 y-1.2],'-','LineWidth',4,'Color',clr_apoe4_homo)
plot(ci1_nfl,[y-1.5 y-1.5],'-','LineWidth',4,'Color',clr_apoe4_homo)
plot(ci1_hba1c,[y-1.8 y-1.8],'-','LineWidth',4,'Color',clr_apoe4_homo)
plot(ci1_ldl,[y-2.1 y-2.1],'-','LineWidth',4,'Color',clr_apoe4_homo)
plot(ci1_hypertension,[y-2.4 y-2.4],'-','LineWidth',4,'Color',clr_apoe4_homo)
plot(ci1_ihd,[y-2.7 y-2.7],'-','LineWidth',4,'Color',clr_apoe4_homo)
plot(ci1_stroke,[y-3.0 y-3.0],'-','LineWidth',4,'Color',clr_apoe4_homo)
plot(ci1_ckd,[y-3.3 y-3.3],'-','LineWidth',4,'Color',clr_apoe4_homo)

plot(e1_apoe4_homo,y,'d','MarkerSize',12,'LineWidth',4,'Color',clr_apoe4_homo,'markerfacecolor',clr_apoe4_homo);
plot(e1_apoe4_hetero,[y-0.3 y-0.3],'d','MarkerSize',12,'LineWidth',4,'Color',clr_apoe4_homo,'markerfacecolor',clr_apoe4_homo);
plot(e1_sex,[y-0.6 y-0.6],'d','MarkerSize',12,'LineWidth',4,'Color',clr_apoe4_homo,'markerfacecolor',clr_apoe4_homo);
plot(e1_age,[y-0.9 y-0.9],'d','MarkerSize',12,'LineWidth',4,'Color',clr_apoe4_homo,'markerfacecolor',clr_apoe4_homo);
plot(e1_gfap,[y-1.2 y-1.2],'d','MarkerSize',12,'LineWidth',4,'Color',clr_apoe4_homo,'markerfacecolor',clr_apoe4_homo);
plot(e1_nfl,[y-1.5 y-1.5],'d','MarkerSize',12,'LineWidth',4,'Color',clr_apoe4_homo,'markerfacecolor',clr_apoe4_homo);
plot(e1_hba1c,y-1.8,'d','MarkerSize',12,'LineWidth',4,'Color',clr_apoe4_homo,'markerfacecolor',clr_apoe4_homo);
plot(e1_ldl,y-2.1,'d','MarkerSize',12,'LineWidth',4,'Color',clr_apoe4_homo,'markerfacecolor',clr_apoe4_homo);
plot(e1_hypertension,y-2.4,'d','MarkerSize',12,'LineWidth',4,'Color',clr_apoe4_homo,'markerfacecolor',clr_apoe4_homo);
plot(e1_ihd,y-2.7,'d','MarkerSize',12,'LineWidth',4,'Color',clr_apoe4_homo,'markerfacecolor',clr_apoe4_homo);
plot(e1_stroke,y-3.0,'d','MarkerSize',12,'LineWidth',4,'Color',clr_apoe4_homo,'markerfacecolor',clr_apoe4_homo);
plot(e1_ckd,y-3.3,'d','MarkerSize',12,'LineWidth',4,'Color',clr_apoe4_homo,'markerfacecolor',clr_apoe4_homo);

plot(ci2_apoe4_homo,[y-0.15 y-0.15],'-','LineWidth',4,'Color',clr_sex)
plot(ci2_apoe4_hetero,[y-0.45 y-0.45],'-','LineWidth',4,'Color',clr_sex)
plot(ci2_sex,[y-0.75 y-0.75],'-','LineWidth',4,'Color',clr_sex)
plot(ci2_age,[y-1.05 y-1.05],'-','LineWidth',4,'Color',clr_sex)
plot(ci2_gfap,[y-1.35 y-1.35],'-','LineWidth',4,'Color',clr_sex)
plot(ci2_nfl,[y-1.65 y-1.65],'-','LineWidth',4,'Color',clr_sex)
plot(ci2_hba1c,[y-1.95 y-1.95],'-','LineWidth',4,'Color',clr_sex)
plot(ci2_ldl,[y-2.25 y-2.25],'-','LineWidth',4,'Color',clr_sex)
plot(ci2_hypertension,[y-2.55 y-2.55],'-','LineWidth',4,'Color',clr_sex)
plot(ci2_ihd,[y-2.85 y-2.85],'-','LineWidth',4,'Color',clr_sex)
plot(ci2_stroke,[y-3.15 y-3.15],'-','LineWidth',4,'Color',clr_sex)
plot(ci2_ckd,[y-3.45 y-3.45],'-','LineWidth',4,'Color',clr_sex)
plot(ci2_b4240,[y-3.75 y-3.75],'-','LineWidth',4,'Color',clr_sex)

plot(e2_apoe4_homo,y-0.15,'>','MarkerSize',12,'LineWidth',4,'Color',clr_sex,'markerfacecolor',clr_sex);
plot(e2_apoe4_hetero,y-0.45,'>','MarkerSize',12,'LineWidth',4,'Color',clr_sex,'markerfacecolor',clr_sex);
plot(e2_sex,y-0.75,'>','MarkerSize',12,'LineWidth',4,'Color',clr_sex,'markerfacecolor',clr_sex);
plot(e2_age,y-1.05,'>','MarkerSize',12,'LineWidth',4,'Color',clr_sex,'markerfacecolor',clr_sex);
plot(e2_gfap,y-1.35,'>','MarkerSize',12,'LineWidth',4,'Color',clr_sex,'markerfacecolor',clr_sex);
plot(e2_nfl,y-1.65,'>','MarkerSize',12,'LineWidth',4,'Color',clr_sex,'markerfacecolor',clr_sex);
plot(e2_hba1c,y-1.95,'>','MarkerSize',12,'LineWidth',4,'Color',clr_sex,'markerfacecolor',clr_sex);
plot(e2_ldl,y-2.25,'>','MarkerSize',12,'LineWidth',4,'Color',clr_sex,'markerfacecolor',clr_sex);
plot(e2_hypertension,y-2.55,'>','MarkerSize',12,'LineWidth',4,'Color',clr_sex,'markerfacecolor',clr_sex);
plot(e2_ihd,y-2.85,'>','MarkerSize',12,'LineWidth',4,'Color',clr_sex,'markerfacecolor',clr_sex);
plot(e2_stroke,y-3.15,'>','MarkerSize',12,'LineWidth',4,'Color',clr_sex,'markerfacecolor',clr_sex);
plot(e2_ckd,y-3.45,'>','MarkerSize',12,'LineWidth',4,'Color',clr_sex,'markerfacecolor',clr_sex);
plot(e2_b4240,y-3.75,'>','MarkerSize',12,'LineWidth',4,'Color',clr_sex,'markerfacecolor',clr_sex);

text(-0.58,8.85,'MODEL 3','Fontsize',20,'FontWeight','bold')
hold off

axis([-0.70 0.70 5.1 9.2])

grid on
xlabel({'Regression coeficients',...
    'Age and HbA1c divided by factor 10 before regression',...
    'GFAP, NfL and LDL divided by factor 100 before regression',...
    'A\beta_{42/40} multiplied by factor 10 before regression'})
set(gca,'FontSize',14,'LineWidth',2,...
    'YTick',y-3.6:0.3:y,'YtickLabel',flip({'APOE4_{Hom}','APOE4_{Het}','Sex_{Male}','Age','GFAP','NfL','HbA1c','LDL','Hypertension','IHD','Stroke','CKD','A\beta_{42/40}'}))



