%% Initiate
clear all;
clc;
close all;


% Make a table, divided into APOE4 carriers versus non-carriers.
% Include mean +/- standard deviation (for continuous variables) and number (%) for (binary variables).
% Can you also include how many of the APOE4 carriers are heterozygotes versus homozygotes?
% 
% You can perform a statistical test comparing the two groups. You can decide on what test is 
% best to use, but analysis of variance is suggested for continuous variables and Chi-squared 
% for categorical variables. You may need to use a Fischer exact test for variables that have 
% very low number of observations (e.g., less than 5 observations).
% 
% 
% Model 1:
% Ischemic heart disease = APOE4 (carrier = 1, non-carrier =0) + Sex + Age
% 
% Model 2:
% Ischemic heart disease = APOE4 (carrier = 1, non-carrier =0) + Sex + Sex*APOE4 + Age
% 
% Repeat Model 1 and Model 2, except replace Ischemic heart disease with 
% a) hypertension, b) hyperlipidemia, c) type 2 diabetes mellitus, d)
% HbA1c, e) BMI. f) cancer
% 
% Model 3:
% Ischemic heart disease = APOE4 (carrier = 1, non-carrier =0) + Sex + Age + hypertension + hyperlipidemia
% + type 2 diabetes mellitus + BMI + smoking
% 
% Model 4:
% Model 3 + sex*APOE4 interaction


data_folder='/home/range1-raid1/labounek/data-on-porto';
project_folder=fullfile(data_folder,'ADAI');
table_folder=fullfile(project_folder,'tables');

% xls_file = fullfile(project_folder,'HeartDataset','ADAI_HeartStats2.xlsx');
% xls_file = fullfile(project_folder,'HeartDataset','ADAI_HeartStats3.xlsx');
xls_file = fullfile(project_folder,'HeartDataset','MasterDataset1.xlsx');
[num, txt, raw] = xlsread(xls_file);
raw{1,strcmp(raw(1,:),'Please describe alcohol habits (what kind, how much, how often).')} = 'Alcohol habits';

apoe4_pos = ~isnan(cell2mat(raw(2:end,strcmp(raw(1,:),'APOE e4 mutations'))));

nat_am_prct = raw(2:end,strcmp(raw(1,:),'% Native '));
for ind = 1:size(nat_am_prct,1)
    if ~isnumeric(nat_am_prct{ind,1})
        nat_am_prct{ind,1} = NaN; 
    end
end
nat_am_prct = cell2mat(nat_am_prct(apoe4_pos,1));

tbl = cell2table(raw(2:end,:),'VariableNames',raw(1,:));
tbl = tbl(~isnan(cell2mat(table2cell(tbl(:,'APOE e4 mutations')))),:);
tbl(:,'NatAmOrigin') = num2cell(nat_am_prct);
% tbl.Sex = categorical(tbl.Sex);

%% Demographic Stats
stats_demography{1,2} = 'All';
stats_demography{1,3} = 'Males';
stats_demography{1,4} = 'Females';
stats_demography{1,5} = 'p';

stats_demography{2,1} = 'N subjects';
stats_demography{3,1} = 'Age [years]';
stats_demography{4,1} = 'Height [cm]';
stats_demography{5,1} = 'Weight [kg]';
stats_demography{6,1} = 'BMI [kg/m^2]';
stats_demography{7,1} = 'Education [years]';
stats_demography{8,1} = 'Native Am. origin [%]';
stats_demography{9,1} = 'HbA1C';

stats_demography{11,1} = 'APOE4';
stats_demography{12,1} = 'non-carrier';
stats_demography{13,1} = 'heterozygote';
stats_demography{14,1} = 'homozygote';

stats_demography{16,1} = 'APOE3';
stats_demography{17,1} = 'non-carrier';
stats_demography{18,1} = 'heterozygote';
stats_demography{19,1} = 'homozygote';

stats_demography{21,1} = 'APOE2';
stats_demography{22,1} = 'non-carrier';
stats_demography{23,1} = 'heterozygote';
stats_demography{24,1} = 'homozygote';

stats_demography{26,1} = 'Tobacco use';
stats_demography{27,1} = 'never';
stats_demography{28,1} = 'former';
stats_demography{29,1} = 'current'; 

stats_demography{31,1} = 'Alcohol use';
stats_demography{32,1} = 'never';
stats_demography{33,1} = 'former';
stats_demography{34,1} = 'current'; 

stats_demography{36,1} = 'Heart disease';
stats_demography{37,1} = 'no';
stats_demography{38,1} = 'ischemic';
stats_demography{39,1} = 'non-ischemic';

stats_demography{40,1} = 'HTN';
stats_demography{41,1} = 'no';
stats_demography{42,1} = 'yes';

stats_demography{44,1} = 'HLD';
stats_demography{45,1} = 'no';
stats_demography{46,1} = 'yes';

stats_demography{48,1} = 'CKD';
stats_demography{49,1} = 'no';
stats_demography{50,1} = 'yes';

stats_demography{52,1} = 'TIIDM';
stats_demography{53,1} = 'no';
stats_demography{54,1} = 'yes';

stats_demography{56,1} = 'Cancer history';
stats_demography{57,1} = 'no';
stats_demography{58,1} = 'yes';

stats_demography{60,1} = 'Stroke history';
stats_demography{61,1} = 'no';
stats_demography{62,1} = 'yes';

stats_demography{2,2} = size(tbl,1);
stats_demography{2,3} = [num2str(sum(strcmp(table2cell(tbl(:,'Sex')),'Male'))) ' (' num2str(100*sum(strcmp(table2cell(tbl(:,'Sex')),'Male'))/stats_demography{2,2},'%.1f') '%)' ];
stats_demography{2,4} = [num2str(sum(strcmp(table2cell(tbl(:,'Sex')),'Female'))) ' (' num2str(100*sum(strcmp(table2cell(tbl(:,'Sex')),'Female'))/stats_demography{2,2},'%.1f') '%)' ];

stats_demography{3,2} = [ num2str(mean(cell2mat(table2cell(tbl(:,'Age '))),'omitnan'),'%.1f') '±' num2str(std(cell2mat(table2cell(tbl(:,'Age '))),'omitnan'),'%.1f') ];
stats_demography{3,3} = [ num2str(mean(cell2mat(table2cell(tbl(strcmp(table2cell(tbl(:,'Sex')),'Male'),'Age '))),'omitnan'),'%.1f') '±' num2str(std(cell2mat(table2cell(tbl(strcmp(table2cell(tbl(:,'Sex')),'Male'),'Age '))),'omitnan'),'%.1f') ];
stats_demography{3,4} = [ num2str(mean(cell2mat(table2cell(tbl(strcmp(table2cell(tbl(:,'Sex')),'Female'),'Age '))),'omitnan'),'%.1f') '±' num2str(std(cell2mat(table2cell(tbl(strcmp(table2cell(tbl(:,'Sex')),'Female'),'Age '))),'omitnan'),'%.1f') ];
[~, stats_demography{3,5}] = ttest2( cell2mat(table2cell(tbl(strcmp(table2cell(tbl(:,'Sex')),'Male'),'Age '))) , cell2mat(table2cell(tbl(strcmp(table2cell(tbl(:,'Sex')),'Female'),'Age '))) );

stats_demography{4,2} = [ num2str(mean(cell2mat(table2cell(tbl(:,'Participant height (cm)'))),'omitnan'),'%.1f') '±' num2str(std(cell2mat(table2cell(tbl(:,'Participant height (cm)'))),'omitnan'),'%.1f') ];
stats_demography{4,3} = [ num2str(mean(cell2mat(table2cell(tbl(strcmp(table2cell(tbl(:,'Sex')),'Male'),'Participant height (cm)'))),'omitnan'),'%.1f') '±' num2str(std(cell2mat(table2cell(tbl(strcmp(table2cell(tbl(:,'Sex')),'Male'),'Participant height (cm)'))),'omitnan'),'%.1f') ];
stats_demography{4,4} = [ num2str(mean(cell2mat(table2cell(tbl(strcmp(table2cell(tbl(:,'Sex')),'Female'),'Participant height (cm)'))),'omitnan'),'%.1f') '±' num2str(std(cell2mat(table2cell(tbl(strcmp(table2cell(tbl(:,'Sex')),'Female'),'Participant height (cm)'))),'omitnan'),'%.1f') ];
[~, stats_demography{4,5}] = ttest2( cell2mat(table2cell(tbl(strcmp(table2cell(tbl(:,'Sex')),'Male'),'Participant height (cm)'))) , cell2mat(table2cell(tbl(strcmp(table2cell(tbl(:,'Sex')),'Female'),'Participant height (cm)'))) );

stats_demography{5,2} = [ num2str(mean(cell2mat(table2cell(tbl(:,'Participant weight (kg) '))),'omitnan'),'%.1f') '±' num2str(std(cell2mat(table2cell(tbl(:,'Participant weight (kg) '))),'omitnan'),'%.1f') ];
stats_demography{5,3} = [ num2str(mean(cell2mat(table2cell(tbl(strcmp(table2cell(tbl(:,'Sex')),'Male'),'Participant weight (kg) '))),'omitnan'),'%.1f') '±' num2str(std(cell2mat(table2cell(tbl(strcmp(table2cell(tbl(:,'Sex')),'Male'),'Participant weight (kg) '))),'omitnan'),'%.1f') ];
stats_demography{5,4} = [ num2str(mean(cell2mat(table2cell(tbl(strcmp(table2cell(tbl(:,'Sex')),'Female'),'Participant weight (kg) '))),'omitnan'),'%.1f') '±' num2str(std(cell2mat(table2cell(tbl(strcmp(table2cell(tbl(:,'Sex')),'Female'),'Participant weight (kg) '))),'omitnan'),'%.1f') ];
[~, stats_demography{5,5}] = ttest2( cell2mat(table2cell(tbl(strcmp(table2cell(tbl(:,'Sex')),'Male'),'Participant weight (kg) '))) , cell2mat(table2cell(tbl(strcmp(table2cell(tbl(:,'Sex')),'Female'),'Participant weight (kg) '))) );

stats_demography{6,2} = [ num2str(mean(cell2mat(table2cell(tbl(:,'BMI'))),'omitnan'),'%.1f') '±' num2str(std(cell2mat(table2cell(tbl(:,'BMI'))),'omitnan'),'%.1f') ];
stats_demography{6,3} = [ num2str(mean(cell2mat(table2cell(tbl(strcmp(table2cell(tbl(:,'Sex')),'Male'),'BMI'))),'omitnan'),'%.1f') '±' num2str(std(cell2mat(table2cell(tbl(strcmp(table2cell(tbl(:,'Sex')),'Male'),'BMI'))),'omitnan'),'%.1f') ];
stats_demography{6,4} = [ num2str(mean(cell2mat(table2cell(tbl(strcmp(table2cell(tbl(:,'Sex')),'Female'),'BMI'))),'omitnan'),'%.1f') '±' num2str(std(cell2mat(table2cell(tbl(strcmp(table2cell(tbl(:,'Sex')),'Female'),'BMI'))),'omitnan'),'%.1f') ];
[~, stats_demography{6,5}] = ttest2( cell2mat(table2cell(tbl(strcmp(table2cell(tbl(:,'Sex')),'Male'),'BMI'))) , cell2mat(table2cell(tbl(strcmp(table2cell(tbl(:,'Sex')),'Female'),'BMI'))) );

stats_demography{7,2} = [ num2str(mean(cell2mat(table2cell(tbl(:,'Years of formal schooling'))),'omitnan'),'%.1f') '±' num2str(std(cell2mat(table2cell(tbl(:,'Years of formal schooling'))),'omitnan'),'%.1f') ];
stats_demography{7,3} = [ num2str(mean(cell2mat(table2cell(tbl(strcmp(table2cell(tbl(:,'Sex')),'Male'),'Years of formal schooling'))),'omitnan'),'%.1f') '±' num2str(std(cell2mat(table2cell(tbl(strcmp(table2cell(tbl(:,'Sex')),'Male'),'Years of formal schooling'))),'omitnan'),'%.1f') ];
stats_demography{7,4} = [ num2str(mean(cell2mat(table2cell(tbl(strcmp(table2cell(tbl(:,'Sex')),'Female'),'Years of formal schooling'))),'omitnan'),'%.1f') '±' num2str(std(cell2mat(table2cell(tbl(strcmp(table2cell(tbl(:,'Sex')),'Female'),'Years of formal schooling'))),'omitnan'),'%.1f') ];
[~, stats_demography{7,5}] = ttest2( cell2mat(table2cell(tbl(strcmp(table2cell(tbl(:,'Sex')),'Male'),'Years of formal schooling'))) , cell2mat(table2cell(tbl(strcmp(table2cell(tbl(:,'Sex')),'Female'),'Years of formal schooling'))) );

stats_demography{8,2} = [ num2str(mean(cell2mat(table2cell(tbl(:,'NatAmOrigin'))),'omitnan'),'%.1f') '±' num2str(std(cell2mat(table2cell(tbl(:,'NatAmOrigin'))),'omitnan'),'%.1f') ];
stats_demography{8,3} = [ num2str(mean(cell2mat(table2cell(tbl(strcmp(table2cell(tbl(:,'Sex')),'Male'),'NatAmOrigin'))),'omitnan'),'%.1f') '±' num2str(std(cell2mat(table2cell(tbl(strcmp(table2cell(tbl(:,'Sex')),'Male'),'NatAmOrigin'))),'omitnan'),'%.1f') ];
stats_demography{8,4} = [ num2str(mean(cell2mat(table2cell(tbl(strcmp(table2cell(tbl(:,'Sex')),'Female'),'NatAmOrigin'))),'omitnan'),'%.1f') '±' num2str(std(cell2mat(table2cell(tbl(strcmp(table2cell(tbl(:,'Sex')),'Female'),'NatAmOrigin'))),'omitnan'),'%.1f') ];
[~, stats_demography{8,5}] = ttest2( cell2mat(table2cell(tbl(strcmp(table2cell(tbl(:,'Sex')),'Male'),'NatAmOrigin'))) , cell2mat(table2cell(tbl(strcmp(table2cell(tbl(:,'Sex')),'Female'),'NatAmOrigin'))) );

stats_demography{9,2} = [ num2str(mean(cell2mat(table2cell(tbl(:,'HbA1C'))),'omitnan'),'%.1f') '±' num2str(std(cell2mat(table2cell(tbl(:,'HbA1C'))),'omitnan'),'%.1f') ];
stats_demography{9,3} = [ num2str(mean(cell2mat(table2cell(tbl(strcmp(table2cell(tbl(:,'Sex')),'Male'),'HbA1C'))),'omitnan'),'%.1f') '±' num2str(std(cell2mat(table2cell(tbl(strcmp(table2cell(tbl(:,'Sex')),'Male'),'HbA1C'))),'omitnan'),'%.1f') ];
stats_demography{9,4} = [ num2str(mean(cell2mat(table2cell(tbl(strcmp(table2cell(tbl(:,'Sex')),'Female'),'HbA1C'))),'omitnan'),'%.1f') '±' num2str(std(cell2mat(table2cell(tbl(strcmp(table2cell(tbl(:,'Sex')),'Female'),'HbA1C'))),'omitnan'),'%.1f') ];
[~, stats_demography{9,5}] = ttest2( cell2mat(table2cell(tbl(strcmp(table2cell(tbl(:,'Sex')),'Male'),'HbA1C'))) , cell2mat(table2cell(tbl(strcmp(table2cell(tbl(:,'Sex')),'Female'),'HbA1C'))) );

stats_demography{12,2} = [ num2str(sum(cell2mat(table2cell(tbl(:,'APOE e4 mutations')))==0)) ' (' num2str(100*sum(cell2mat(table2cell(tbl(:,'APOE e4 mutations')))==0)/stats_demography{2,2},'%.1f') '%)' ];
stats_demography{12,3} = [ num2str(sum(cell2mat(table2cell(tbl(strcmp(table2cell(tbl(:,'Sex')),'Male'),'APOE e4 mutations')))==0)) ' (' num2str(100*sum(cell2mat(table2cell(tbl(strcmp(table2cell(tbl(:,'Sex')),'Male'),'APOE e4 mutations')))==0)/sum(strcmp(table2cell(tbl(:,'Sex')),'Male')),'%.1f') '%)' ];
stats_demography{12,4} = [ num2str(sum(cell2mat(table2cell(tbl(strcmp(table2cell(tbl(:,'Sex')),'Female'),'APOE e4 mutations')))==0)) ' (' num2str(100*sum(cell2mat(table2cell(tbl(strcmp(table2cell(tbl(:,'Sex')),'Female'),'APOE e4 mutations')))==0)/sum(strcmp(table2cell(tbl(:,'Sex')),'Female')),'%.1f') '%)' ];

stats_demography{13,2} = [ num2str(sum(cell2mat(table2cell(tbl(:,'APOE e4 mutations')))==1)) ' (' num2str(100*sum(cell2mat(table2cell(tbl(:,'APOE e4 mutations')))==1)/stats_demography{2,2},'%.1f') '%)' ];
stats_demography{13,3} = [ num2str(sum(cell2mat(table2cell(tbl(strcmp(table2cell(tbl(:,'Sex')),'Male'),'APOE e4 mutations')))==1)) ' (' num2str(100*sum(cell2mat(table2cell(tbl(strcmp(table2cell(tbl(:,'Sex')),'Male'),'APOE e4 mutations')))==1)/sum(strcmp(table2cell(tbl(:,'Sex')),'Male')),'%.1f') '%)' ];
stats_demography{13,4} = [ num2str(sum(cell2mat(table2cell(tbl(strcmp(table2cell(tbl(:,'Sex')),'Female'),'APOE e4 mutations')))==1)) ' (' num2str(100*sum(cell2mat(table2cell(tbl(strcmp(table2cell(tbl(:,'Sex')),'Female'),'APOE e4 mutations')))==1)/sum(strcmp(table2cell(tbl(:,'Sex')),'Female')),'%.1f') '%)' ];

stats_demography{14,2} = [ num2str(sum(cell2mat(table2cell(tbl(:,'APOE e4 mutations')))==2)) ' (' num2str(100*sum(cell2mat(table2cell(tbl(:,'APOE e4 mutations')))==2)/stats_demography{2,2},'%.1f') '%)' ];
stats_demography{14,3} = [ num2str(sum(cell2mat(table2cell(tbl(strcmp(table2cell(tbl(:,'Sex')),'Male'),'APOE e4 mutations')))==2)) ' (' num2str(100*sum(cell2mat(table2cell(tbl(strcmp(table2cell(tbl(:,'Sex')),'Male'),'APOE e4 mutations')))==2)/sum(strcmp(table2cell(tbl(:,'Sex')),'Male')),'%.1f') '%)' ];
stats_demography{14,4} = [ num2str(sum(cell2mat(table2cell(tbl(strcmp(table2cell(tbl(:,'Sex')),'Female'),'APOE e4 mutations')))==2)) ' (' num2str(100*sum(cell2mat(table2cell(tbl(strcmp(table2cell(tbl(:,'Sex')),'Female'),'APOE e4 mutations')))==2)/sum(strcmp(table2cell(tbl(:,'Sex')),'Female')),'%.1f') '%)' ];

stats_demography{17,2} = [ num2str(sum(cell2mat(table2cell(tbl(:,'APOE e3 mutations')))==0)) ' (' num2str(100*sum(cell2mat(table2cell(tbl(:,'APOE e3 mutations')))==0)/stats_demography{2,2},'%.1f') '%)' ];
stats_demography{17,3} = [ num2str(sum(cell2mat(table2cell(tbl(strcmp(table2cell(tbl(:,'Sex')),'Male'),'APOE e3 mutations')))==0)) ' (' num2str(100*sum(cell2mat(table2cell(tbl(strcmp(table2cell(tbl(:,'Sex')),'Male'),'APOE e3 mutations')))==0)/sum(strcmp(table2cell(tbl(:,'Sex')),'Male')),'%.1f') '%)' ];
stats_demography{17,4} = [ num2str(sum(cell2mat(table2cell(tbl(strcmp(table2cell(tbl(:,'Sex')),'Female'),'APOE e3 mutations')))==0)) ' (' num2str(100*sum(cell2mat(table2cell(tbl(strcmp(table2cell(tbl(:,'Sex')),'Female'),'APOE e3 mutations')))==0)/sum(strcmp(table2cell(tbl(:,'Sex')),'Female')),'%.1f') '%)' ];

stats_demography{18,2} = [ num2str(sum(cell2mat(table2cell(tbl(:,'APOE e3 mutations')))==1)) ' (' num2str(100*sum(cell2mat(table2cell(tbl(:,'APOE e3 mutations')))==1)/stats_demography{2,2},'%.1f') '%)' ];
stats_demography{18,3} = [ num2str(sum(cell2mat(table2cell(tbl(strcmp(table2cell(tbl(:,'Sex')),'Male'),'APOE e3 mutations')))==1)) ' (' num2str(100*sum(cell2mat(table2cell(tbl(strcmp(table2cell(tbl(:,'Sex')),'Male'),'APOE e3 mutations')))==1)/sum(strcmp(table2cell(tbl(:,'Sex')),'Male')),'%.1f') '%)' ];
stats_demography{18,4} = [ num2str(sum(cell2mat(table2cell(tbl(strcmp(table2cell(tbl(:,'Sex')),'Female'),'APOE e3 mutations')))==1)) ' (' num2str(100*sum(cell2mat(table2cell(tbl(strcmp(table2cell(tbl(:,'Sex')),'Female'),'APOE e3 mutations')))==1)/sum(strcmp(table2cell(tbl(:,'Sex')),'Female')),'%.1f') '%)' ];

stats_demography{19,2} = [ num2str(sum(cell2mat(table2cell(tbl(:,'APOE e3 mutations')))==2)) ' (' num2str(100*sum(cell2mat(table2cell(tbl(:,'APOE e3 mutations')))==2)/stats_demography{2,2},'%.1f') '%)' ];
stats_demography{19,3} = [ num2str(sum(cell2mat(table2cell(tbl(strcmp(table2cell(tbl(:,'Sex')),'Male'),'APOE e3 mutations')))==2)) ' (' num2str(100*sum(cell2mat(table2cell(tbl(strcmp(table2cell(tbl(:,'Sex')),'Male'),'APOE e3 mutations')))==2)/sum(strcmp(table2cell(tbl(:,'Sex')),'Male')),'%.1f') '%)' ];
stats_demography{19,4} = [ num2str(sum(cell2mat(table2cell(tbl(strcmp(table2cell(tbl(:,'Sex')),'Female'),'APOE e3 mutations')))==2)) ' (' num2str(100*sum(cell2mat(table2cell(tbl(strcmp(table2cell(tbl(:,'Sex')),'Female'),'APOE e3 mutations')))==2)/sum(strcmp(table2cell(tbl(:,'Sex')),'Female')),'%.1f') '%)' ];

stats_demography{22,2} = [ num2str(sum(cell2mat(table2cell(tbl(:,'APOE e2 mutations')))==0)) ' (' num2str(100*sum(cell2mat(table2cell(tbl(:,'APOE e2 mutations')))==0)/stats_demography{2,2},'%.1f') '%)' ];
stats_demography{22,3} = [ num2str(sum(cell2mat(table2cell(tbl(strcmp(table2cell(tbl(:,'Sex')),'Male'),'APOE e2 mutations')))==0)) ' (' num2str(100*sum(cell2mat(table2cell(tbl(strcmp(table2cell(tbl(:,'Sex')),'Male'),'APOE e2 mutations')))==0)/sum(strcmp(table2cell(tbl(:,'Sex')),'Male')),'%.1f') '%)' ];
stats_demography{22,4} = [ num2str(sum(cell2mat(table2cell(tbl(strcmp(table2cell(tbl(:,'Sex')),'Female'),'APOE e2 mutations')))==0)) ' (' num2str(100*sum(cell2mat(table2cell(tbl(strcmp(table2cell(tbl(:,'Sex')),'Female'),'APOE e2 mutations')))==0)/sum(strcmp(table2cell(tbl(:,'Sex')),'Female')),'%.1f') '%)' ];

stats_demography{23,2} = [ num2str(sum(cell2mat(table2cell(tbl(:,'APOE e2 mutations')))==1)) ' (' num2str(100*sum(cell2mat(table2cell(tbl(:,'APOE e2 mutations')))==1)/stats_demography{2,2},'%.1f') '%)' ];
stats_demography{23,3} = [ num2str(sum(cell2mat(table2cell(tbl(strcmp(table2cell(tbl(:,'Sex')),'Male'),'APOE e2 mutations')))==1)) ' (' num2str(100*sum(cell2mat(table2cell(tbl(strcmp(table2cell(tbl(:,'Sex')),'Male'),'APOE e2 mutations')))==1)/sum(strcmp(table2cell(tbl(:,'Sex')),'Male')),'%.1f') '%)' ];
stats_demography{23,4} = [ num2str(sum(cell2mat(table2cell(tbl(strcmp(table2cell(tbl(:,'Sex')),'Female'),'APOE e2 mutations')))==1)) ' (' num2str(100*sum(cell2mat(table2cell(tbl(strcmp(table2cell(tbl(:,'Sex')),'Female'),'APOE e2 mutations')))==1)/sum(strcmp(table2cell(tbl(:,'Sex')),'Female')),'%.1f') '%)' ];

stats_demography{24,2} = [ num2str(sum(cell2mat(table2cell(tbl(:,'APOE e2 mutations')))==2)) ' (' num2str(100*sum(cell2mat(table2cell(tbl(:,'APOE e2 mutations')))==2)/stats_demography{2,2},'%.1f') '%)' ];
stats_demography{24,3} = [ num2str(sum(cell2mat(table2cell(tbl(strcmp(table2cell(tbl(:,'Sex')),'Male'),'APOE e2 mutations')))==2)) ' (' num2str(100*sum(cell2mat(table2cell(tbl(strcmp(table2cell(tbl(:,'Sex')),'Male'),'APOE e2 mutations')))==2)/sum(strcmp(table2cell(tbl(:,'Sex')),'Male')),'%.1f') '%)' ];
stats_demography{24,4} = [ num2str(sum(cell2mat(table2cell(tbl(strcmp(table2cell(tbl(:,'Sex')),'Female'),'APOE e2 mutations')))==2)) ' (' num2str(100*sum(cell2mat(table2cell(tbl(strcmp(table2cell(tbl(:,'Sex')),'Female'),'APOE e2 mutations')))==2)/sum(strcmp(table2cell(tbl(:,'Sex')),'Female')),'%.1f') '%)' ];

stats_demography{27,2} = [ num2str(sum(strcmp(table2cell(tbl(:,'Tobacco use (Current, former use, never) ')),'Never'))) ' (' num2str(100*sum(strcmp(table2cell(tbl(:,'Tobacco use (Current, former use, never) ')),'Never'))/stats_demography{2,2},'%.1f') '%)' ];
stats_demography{27,3} = [ num2str(sum(strcmp(table2cell(tbl(strcmp(table2cell(tbl(:,'Sex')),'Male'),'Tobacco use (Current, former use, never) ')),'Never'))) ' (' num2str(100*sum(strcmp(table2cell(tbl(strcmp(table2cell(tbl(:,'Sex')),'Male'),'Tobacco use (Current, former use, never) ')),'Never'))/sum(strcmp(table2cell(tbl(:,'Sex')),'Male')),'%.1f') '%)' ];
stats_demography{27,4} = [ num2str(sum(strcmp(table2cell(tbl(strcmp(table2cell(tbl(:,'Sex')),'Female'),'Tobacco use (Current, former use, never) ')),'Never'))) ' (' num2str(100*sum(strcmp(table2cell(tbl(strcmp(table2cell(tbl(:,'Sex')),'Female'),'Tobacco use (Current, former use, never) ')),'Never'))/sum(strcmp(table2cell(tbl(:,'Sex')),'Female')),'%.1f') '%)' ];

stats_demography{28,2} = [ num2str(sum(strcmp(table2cell(tbl(:,'Tobacco use (Current, former use, never) ')),'Former'))) ' (' num2str(100*sum(strcmp(table2cell(tbl(:,'Tobacco use (Current, former use, never) ')),'Former'))/stats_demography{2,2},'%.1f') '%)' ];
stats_demography{28,3} = [ num2str(sum(strcmp(table2cell(tbl(strcmp(table2cell(tbl(:,'Sex')),'Male'),'Tobacco use (Current, former use, never) ')),'Former'))) ' (' num2str(100*sum(strcmp(table2cell(tbl(strcmp(table2cell(tbl(:,'Sex')),'Male'),'Tobacco use (Current, former use, never) ')),'Former'))/sum(strcmp(table2cell(tbl(:,'Sex')),'Male')),'%.1f') '%)' ];
stats_demography{28,4} = [ num2str(sum(strcmp(table2cell(tbl(strcmp(table2cell(tbl(:,'Sex')),'Female'),'Tobacco use (Current, former use, never) ')),'Former'))) ' (' num2str(100*sum(strcmp(table2cell(tbl(strcmp(table2cell(tbl(:,'Sex')),'Female'),'Tobacco use (Current, former use, never) ')),'Former'))/sum(strcmp(table2cell(tbl(:,'Sex')),'Female')),'%.1f') '%)' ];

stats_demography{29,2} = [ num2str(sum(strcmp(table2cell(tbl(:,'Tobacco use (Current, former use, never) ')),'Current'))) ' (' num2str(100*sum(strcmp(table2cell(tbl(:,'Tobacco use (Current, former use, never) ')),'Current'))/stats_demography{2,2},'%.1f') '%)' ];
stats_demography{29,3} = [ num2str(sum(strcmp(table2cell(tbl(strcmp(table2cell(tbl(:,'Sex')),'Male'),'Tobacco use (Current, former use, never) ')),'Current'))) ' (' num2str(100*sum(strcmp(table2cell(tbl(strcmp(table2cell(tbl(:,'Sex')),'Male'),'Tobacco use (Current, former use, never) ')),'Current'))/sum(strcmp(table2cell(tbl(:,'Sex')),'Male')),'%.1f') '%)' ];
stats_demography{29,4} = [ num2str(sum(strcmp(table2cell(tbl(strcmp(table2cell(tbl(:,'Sex')),'Female'),'Tobacco use (Current, former use, never) ')),'Current'))) ' (' num2str(100*sum(strcmp(table2cell(tbl(strcmp(table2cell(tbl(:,'Sex')),'Female'),'Tobacco use (Current, former use, never) ')),'Current'))/sum(strcmp(table2cell(tbl(:,'Sex')),'Female')),'%.1f') '%)' ];

stats_demography{32,2} = [ num2str(sum(strcmp(table2cell(tbl(:,'EtOH use (Current, former use, never)')),'Never'))) ' (' num2str(100*sum(strcmp(table2cell(tbl(:,'EtOH use (Current, former use, never)')),'Never'))/stats_demography{2,2},'%.1f') '%)' ];
stats_demography{32,3} = [ num2str(sum(strcmp(table2cell(tbl(strcmp(table2cell(tbl(:,'Sex')),'Male'),'EtOH use (Current, former use, never)')),'Never'))) ' (' num2str(100*sum(strcmp(table2cell(tbl(strcmp(table2cell(tbl(:,'Sex')),'Male'),'EtOH use (Current, former use, never)')),'Never'))/sum(strcmp(table2cell(tbl(:,'Sex')),'Male')),'%.1f') '%)' ];
stats_demography{32,4} = [ num2str(sum(strcmp(table2cell(tbl(strcmp(table2cell(tbl(:,'Sex')),'Female'),'EtOH use (Current, former use, never)')),'Never'))) ' (' num2str(100*sum(strcmp(table2cell(tbl(strcmp(table2cell(tbl(:,'Sex')),'Female'),'EtOH use (Current, former use, never)')),'Never'))/sum(strcmp(table2cell(tbl(:,'Sex')),'Female')),'%.1f') '%)' ];

stats_demography{33,2} = [ num2str(sum(strcmp(table2cell(tbl(:,'EtOH use (Current, former use, never)')),'Former'))) ' (' num2str(100*sum(strcmp(table2cell(tbl(:,'EtOH use (Current, former use, never)')),'Former'))/stats_demography{2,2},'%.1f') '%)' ];
stats_demography{33,3} = [ num2str(sum(strcmp(table2cell(tbl(strcmp(table2cell(tbl(:,'Sex')),'Male'),'EtOH use (Current, former use, never)')),'Former'))) ' (' num2str(100*sum(strcmp(table2cell(tbl(strcmp(table2cell(tbl(:,'Sex')),'Male'),'EtOH use (Current, former use, never)')),'Former'))/sum(strcmp(table2cell(tbl(:,'Sex')),'Male')),'%.1f') '%)' ];
stats_demography{33,4} = [ num2str(sum(strcmp(table2cell(tbl(strcmp(table2cell(tbl(:,'Sex')),'Female'),'EtOH use (Current, former use, never)')),'Former'))) ' (' num2str(100*sum(strcmp(table2cell(tbl(strcmp(table2cell(tbl(:,'Sex')),'Female'),'EtOH use (Current, former use, never)')),'Former'))/sum(strcmp(table2cell(tbl(:,'Sex')),'Female')),'%.1f') '%)' ];

stats_demography{34,2} = [ num2str(sum(strcmp(table2cell(tbl(:,'EtOH use (Current, former use, never)')),'Current'))) ' (' num2str(100*sum(strcmp(table2cell(tbl(:,'EtOH use (Current, former use, never)')),'Current'))/stats_demography{2,2},'%.1f') '%)' ];
stats_demography{34,3} = [ num2str(sum(strcmp(table2cell(tbl(strcmp(table2cell(tbl(:,'Sex')),'Male'),'EtOH use (Current, former use, never)')),'Current'))) ' (' num2str(100*sum(strcmp(table2cell(tbl(strcmp(table2cell(tbl(:,'Sex')),'Male'),'EtOH use (Current, former use, never)')),'Current'))/sum(strcmp(table2cell(tbl(:,'Sex')),'Male')),'%.1f') '%)' ];
stats_demography{34,4} = [ num2str(sum(strcmp(table2cell(tbl(strcmp(table2cell(tbl(:,'Sex')),'Female'),'EtOH use (Current, former use, never)')),'Current'))) ' (' num2str(100*sum(strcmp(table2cell(tbl(strcmp(table2cell(tbl(:,'Sex')),'Female'),'EtOH use (Current, former use, never)')),'Current'))/sum(strcmp(table2cell(tbl(:,'Sex')),'Female')),'%.1f') '%)' ];

stats_demography{37,2} = [ num2str(sum(strcmp(table2cell(tbl(:,'Heart Issues')),'No'))) ' (' num2str(100*sum(strcmp(table2cell(tbl(:,'Heart Issues')),'No'))/stats_demography{2,2},'%.1f') '%)' ];
stats_demography{37,3} = [ num2str(sum(strcmp(table2cell(tbl(strcmp(table2cell(tbl(:,'Sex')),'Male'),'Heart Issues')),'No'))) ' (' num2str(100*sum(strcmp(table2cell(tbl(strcmp(table2cell(tbl(:,'Sex')),'Male'),'Heart Issues')),'No'))/sum(strcmp(table2cell(tbl(:,'Sex')),'Male')),'%.1f') '%)' ];
stats_demography{37,4} = [ num2str(sum(strcmp(table2cell(tbl(strcmp(table2cell(tbl(:,'Sex')),'Female'),'Heart Issues')),'No'))) ' (' num2str(100*sum(strcmp(table2cell(tbl(strcmp(table2cell(tbl(:,'Sex')),'Female'),'Heart Issues')),'No'))/sum(strcmp(table2cell(tbl(:,'Sex')),'Female')),'%.1f') '%)' ];

% stats_demography{38,2} = [ num2str(sum(strcmp(table2cell(tbl(:,'Heart Issues')),'Yes'))) ' (' num2str(100*sum(strcmp(table2cell(tbl(:,'Heart Issues')),'Yes'))/stats_demography{2,2},'%.1f') '%)' ];
% stats_demography{38,3} = [ num2str(sum(strcmp(table2cell(tbl(strcmp(table2cell(tbl(:,'Sex')),'Male'),'Heart Issues')),'Yes'))) ' (' num2str(100*sum(strcmp(table2cell(tbl(strcmp(table2cell(tbl(:,'Sex')),'Male'),'Heart Issues')),'Yes'))/sum(strcmp(table2cell(tbl(:,'Sex')),'Male')),'%.1f') '%)' ];
% stats_demography{38,4} = [ num2str(sum(strcmp(table2cell(tbl(strcmp(table2cell(tbl(:,'Sex')),'Female'),'Heart Issues')),'Yes'))) ' (' num2str(100*sum(strcmp(table2cell(tbl(strcmp(table2cell(tbl(:,'Sex')),'Female'),'Heart Issues')),'Yes'))/sum(strcmp(table2cell(tbl(:,'Sex')),'Female')),'%.1f') '%)' ];

stats_demography{38,2} = [ num2str( sum(strcmp(table2cell(tbl(:,'Heart Issues')),'Yes') & ( strcmp(table2cell(tbl(:,'Ischemic vs non-ischemic heart disease ')),'Ischemic') | strcmp(table2cell(tbl(:,'Ischemic vs non-ischemic heart disease ')),'Ischemic ') )) ) ' (' num2str(100*sum(strcmp(table2cell(tbl(:,'Heart Issues')),'Yes') & ( strcmp(table2cell(tbl(:,'Ischemic vs non-ischemic heart disease ')),'Ischemic') | strcmp(table2cell(tbl(:,'Ischemic vs non-ischemic heart disease ')),'Ischemic ') ))/stats_demography{2,2},'%.1f') '%)' ];
stats_demography{38,3} = [ num2str( sum(strcmp(table2cell(tbl(strcmp(table2cell(tbl(:,'Sex')),'Male'),'Heart Issues')),'Yes') & ( strcmp(table2cell(tbl(strcmp(table2cell(tbl(:,'Sex')),'Male'),'Ischemic vs non-ischemic heart disease ')),'Ischemic') | strcmp(table2cell(tbl(strcmp(table2cell(tbl(:,'Sex')),'Male'),'Ischemic vs non-ischemic heart disease ')),'Ischemic ') )) ) ' (' num2str(100* sum(strcmp(table2cell(tbl(strcmp(table2cell(tbl(:,'Sex')),'Male'),'Heart Issues')),'Yes') & ( strcmp(table2cell(tbl(strcmp(table2cell(tbl(:,'Sex')),'Male'),'Ischemic vs non-ischemic heart disease ')),'Ischemic') | strcmp(table2cell(tbl(strcmp(table2cell(tbl(:,'Sex')),'Male'),'Ischemic vs non-ischemic heart disease ')),'Ischemic ') )) /sum(strcmp(table2cell(tbl(:,'Sex')),'Male')),'%.1f' ) '%)' ];
stats_demography{38,4} = [ num2str( sum(strcmp(table2cell(tbl(strcmp(table2cell(tbl(:,'Sex')),'Female'),'Heart Issues')),'Yes') & ( strcmp(table2cell(tbl(strcmp(table2cell(tbl(:,'Sex')),'Female'),'Ischemic vs non-ischemic heart disease ')),'Ischemic') | strcmp(table2cell(tbl(strcmp(table2cell(tbl(:,'Sex')),'Female'),'Ischemic vs non-ischemic heart disease ')),'Ischemic ') )) ) ' (' num2str(100* sum(strcmp(table2cell(tbl(strcmp(table2cell(tbl(:,'Sex')),'Female'),'Heart Issues')),'Yes') & ( strcmp(table2cell(tbl(strcmp(table2cell(tbl(:,'Sex')),'Female'),'Ischemic vs non-ischemic heart disease ')),'Ischemic') | strcmp(table2cell(tbl(strcmp(table2cell(tbl(:,'Sex')),'Female'),'Ischemic vs non-ischemic heart disease ')),'Ischemic ') )) /sum(strcmp(table2cell(tbl(:,'Sex')),'Female')),'%.1f' ) '%)' ];

stats_demography{39,2} = [ num2str( sum(strcmp(table2cell(tbl(:,'Heart Issues')),'Yes') & ~( strcmp(table2cell(tbl(:,'Ischemic vs non-ischemic heart disease ')),'Ischemic') | strcmp(table2cell(tbl(:,'Ischemic vs non-ischemic heart disease ')),'Ischemic ') )) ) ' (' num2str(100*sum(strcmp(table2cell(tbl(:,'Heart Issues')),'Yes') & ~( strcmp(table2cell(tbl(:,'Ischemic vs non-ischemic heart disease ')),'Ischemic') | strcmp(table2cell(tbl(:,'Ischemic vs non-ischemic heart disease ')),'Ischemic ') ))/stats_demography{2,2},'%.1f') '%)' ];
stats_demography{39,3} = [ num2str( sum(strcmp(table2cell(tbl(strcmp(table2cell(tbl(:,'Sex')),'Male'),'Heart Issues')),'Yes') & ~( strcmp(table2cell(tbl(strcmp(table2cell(tbl(:,'Sex')),'Male'),'Ischemic vs non-ischemic heart disease ')),'Ischemic') | strcmp(table2cell(tbl(strcmp(table2cell(tbl(:,'Sex')),'Male'),'Ischemic vs non-ischemic heart disease ')),'Ischemic ') )) ) ' (' num2str(100* sum(strcmp(table2cell(tbl(strcmp(table2cell(tbl(:,'Sex')),'Male'),'Heart Issues')),'Yes') & ~( strcmp(table2cell(tbl(strcmp(table2cell(tbl(:,'Sex')),'Male'),'Ischemic vs non-ischemic heart disease ')),'Ischemic') | strcmp(table2cell(tbl(strcmp(table2cell(tbl(:,'Sex')),'Male'),'Ischemic vs non-ischemic heart disease ')),'Ischemic ') )) /sum(strcmp(table2cell(tbl(:,'Sex')),'Male')),'%.1f' ) '%)' ];
stats_demography{39,4} = [ num2str( sum(strcmp(table2cell(tbl(strcmp(table2cell(tbl(:,'Sex')),'Female'),'Heart Issues')),'Yes') & ~( strcmp(table2cell(tbl(strcmp(table2cell(tbl(:,'Sex')),'Female'),'Ischemic vs non-ischemic heart disease ')),'Ischemic') | strcmp(table2cell(tbl(strcmp(table2cell(tbl(:,'Sex')),'Female'),'Ischemic vs non-ischemic heart disease ')),'Ischemic ') )) ) ' (' num2str(100* sum(strcmp(table2cell(tbl(strcmp(table2cell(tbl(:,'Sex')),'Female'),'Heart Issues')),'Yes') & ~( strcmp(table2cell(tbl(strcmp(table2cell(tbl(:,'Sex')),'Female'),'Ischemic vs non-ischemic heart disease ')),'Ischemic') | strcmp(table2cell(tbl(strcmp(table2cell(tbl(:,'Sex')),'Female'),'Ischemic vs non-ischemic heart disease ')),'Ischemic ') )) /sum(strcmp(table2cell(tbl(:,'Sex')),'Female')),'%.1f' ) '%)' ];

stats_demography{41,2} = [ num2str(sum(strcmp(table2cell(tbl(:,'HTN ')),'No'))) ' (' num2str(100*sum(strcmp(table2cell(tbl(:,'HTN ')),'No'))/stats_demography{2,2},'%.1f') '%)' ];
stats_demography{41,3} = [ num2str(sum(strcmp(table2cell(tbl(strcmp(table2cell(tbl(:,'Sex')),'Male'),'HTN ')),'No'))) ' (' num2str(100*sum(strcmp(table2cell(tbl(strcmp(table2cell(tbl(:,'Sex')),'Male'),'HTN ')),'No'))/sum(strcmp(table2cell(tbl(:,'Sex')),'Male')),'%.1f') '%)' ];
stats_demography{41,4} = [ num2str(sum(strcmp(table2cell(tbl(strcmp(table2cell(tbl(:,'Sex')),'Female'),'HTN ')),'No'))) ' (' num2str(100*sum(strcmp(table2cell(tbl(strcmp(table2cell(tbl(:,'Sex')),'Female'),'HTN ')),'No'))/sum(strcmp(table2cell(tbl(:,'Sex')),'Female')),'%.1f') '%)' ];

stats_demography{42,2} = [ num2str(sum(strcmp(table2cell(tbl(:,'HTN ')),'Yes'))) ' (' num2str(100*sum(strcmp(table2cell(tbl(:,'HTN ')),'Yes'))/stats_demography{2,2},'%.1f') '%)' ];
stats_demography{42,3} = [ num2str(sum(strcmp(table2cell(tbl(strcmp(table2cell(tbl(:,'Sex')),'Male'),'HTN ')),'Yes'))) ' (' num2str(100*sum(strcmp(table2cell(tbl(strcmp(table2cell(tbl(:,'Sex')),'Male'),'HTN ')),'Yes'))/sum(strcmp(table2cell(tbl(:,'Sex')),'Male')),'%.1f') '%)' ];
stats_demography{42,4} = [ num2str(sum(strcmp(table2cell(tbl(strcmp(table2cell(tbl(:,'Sex')),'Female'),'HTN ')),'Yes'))) ' (' num2str(100*sum(strcmp(table2cell(tbl(strcmp(table2cell(tbl(:,'Sex')),'Female'),'HTN ')),'Yes'))/sum(strcmp(table2cell(tbl(:,'Sex')),'Female')),'%.1f') '%)' ];

stats_demography{45,2} = [ num2str(sum(strcmp(table2cell(tbl(:,'HLD')),'No'))) ' (' num2str(100*sum(strcmp(table2cell(tbl(:,'HLD')),'No'))/stats_demography{2,2},'%.1f') '%)' ];
stats_demography{45,3} = [ num2str(sum(strcmp(table2cell(tbl(strcmp(table2cell(tbl(:,'Sex')),'Male'),'HLD')),'No'))) ' (' num2str(100*sum(strcmp(table2cell(tbl(strcmp(table2cell(tbl(:,'Sex')),'Male'),'HLD')),'No'))/sum(strcmp(table2cell(tbl(:,'Sex')),'Male')),'%.1f') '%)' ];
stats_demography{45,4} = [ num2str(sum(strcmp(table2cell(tbl(strcmp(table2cell(tbl(:,'Sex')),'Female'),'HLD')),'No'))) ' (' num2str(100*sum(strcmp(table2cell(tbl(strcmp(table2cell(tbl(:,'Sex')),'Female'),'HLD')),'No'))/sum(strcmp(table2cell(tbl(:,'Sex')),'Female')),'%.1f') '%)' ];

stats_demography{46,2} = [ num2str(sum(strcmp(table2cell(tbl(:,'HLD')),'Yes'))) ' (' num2str(100*sum(strcmp(table2cell(tbl(:,'HLD')),'Yes'))/stats_demography{2,2},'%.1f') '%)' ];
stats_demography{46,3} = [ num2str(sum(strcmp(table2cell(tbl(strcmp(table2cell(tbl(:,'Sex')),'Male'),'HLD')),'Yes'))) ' (' num2str(100*sum(strcmp(table2cell(tbl(strcmp(table2cell(tbl(:,'Sex')),'Male'),'HLD')),'Yes'))/sum(strcmp(table2cell(tbl(:,'Sex')),'Male')),'%.1f') '%)' ];
stats_demography{46,4} = [ num2str(sum(strcmp(table2cell(tbl(strcmp(table2cell(tbl(:,'Sex')),'Female'),'HLD')),'Yes'))) ' (' num2str(100*sum(strcmp(table2cell(tbl(strcmp(table2cell(tbl(:,'Sex')),'Female'),'HLD')),'Yes'))/sum(strcmp(table2cell(tbl(:,'Sex')),'Female')),'%.1f') '%)' ];

stats_demography{49,2} = [ num2str(sum(strcmp(table2cell(tbl(:,'CKD')),'No'))) ' (' num2str(100*sum(strcmp(table2cell(tbl(:,'CKD')),'No'))/stats_demography{2,2},'%.1f') '%)' ];
stats_demography{49,3} = [ num2str(sum(strcmp(table2cell(tbl(strcmp(table2cell(tbl(:,'Sex')),'Male'),'CKD')),'No'))) ' (' num2str(100*sum(strcmp(table2cell(tbl(strcmp(table2cell(tbl(:,'Sex')),'Male'),'CKD')),'No'))/sum(strcmp(table2cell(tbl(:,'Sex')),'Male')),'%.1f') '%)' ];
stats_demography{49,4} = [ num2str(sum(strcmp(table2cell(tbl(strcmp(table2cell(tbl(:,'Sex')),'Female'),'CKD')),'No'))) ' (' num2str(100*sum(strcmp(table2cell(tbl(strcmp(table2cell(tbl(:,'Sex')),'Female'),'CKD')),'No'))/sum(strcmp(table2cell(tbl(:,'Sex')),'Female')),'%.1f') '%)' ];

stats_demography{50,2} = [ num2str(sum(strcmp(table2cell(tbl(:,'CKD')),'Yes'))) ' (' num2str(100*sum(strcmp(table2cell(tbl(:,'CKD')),'Yes'))/stats_demography{2,2},'%.1f') '%)' ];
stats_demography{50,3} = [ num2str(sum(strcmp(table2cell(tbl(strcmp(table2cell(tbl(:,'Sex')),'Male'),'CKD')),'Yes'))) ' (' num2str(100*sum(strcmp(table2cell(tbl(strcmp(table2cell(tbl(:,'Sex')),'Male'),'CKD')),'Yes'))/sum(strcmp(table2cell(tbl(:,'Sex')),'Male')),'%.1f') '%)' ];
stats_demography{50,4} = [ num2str(sum(strcmp(table2cell(tbl(strcmp(table2cell(tbl(:,'Sex')),'Female'),'CKD')),'Yes'))) ' (' num2str(100*sum(strcmp(table2cell(tbl(strcmp(table2cell(tbl(:,'Sex')),'Female'),'CKD')),'Yes'))/sum(strcmp(table2cell(tbl(:,'Sex')),'Female')),'%.1f') '%)' ];

stats_demography{53,2} = [ num2str(sum(strcmp(table2cell(tbl(:,'TIIDM')),'No'))) ' (' num2str(100*sum(strcmp(table2cell(tbl(:,'TIIDM')),'No'))/stats_demography{2,2},'%.1f') '%)' ];
stats_demography{53,3} = [ num2str(sum(strcmp(table2cell(tbl(strcmp(table2cell(tbl(:,'Sex')),'Male'),'TIIDM')),'No'))) ' (' num2str(100*sum(strcmp(table2cell(tbl(strcmp(table2cell(tbl(:,'Sex')),'Male'),'TIIDM')),'No'))/sum(strcmp(table2cell(tbl(:,'Sex')),'Male')),'%.1f') '%)' ];
stats_demography{53,4} = [ num2str(sum(strcmp(table2cell(tbl(strcmp(table2cell(tbl(:,'Sex')),'Female'),'TIIDM')),'No'))) ' (' num2str(100*sum(strcmp(table2cell(tbl(strcmp(table2cell(tbl(:,'Sex')),'Female'),'TIIDM')),'No'))/sum(strcmp(table2cell(tbl(:,'Sex')),'Female')),'%.1f') '%)' ];

stats_demography{54,2} = [ num2str(sum(strcmp(table2cell(tbl(:,'TIIDM')),'Yes'))) ' (' num2str(100*sum(strcmp(table2cell(tbl(:,'TIIDM')),'Yes'))/stats_demography{2,2},'%.1f') '%)' ];
stats_demography{54,3} = [ num2str(sum(strcmp(table2cell(tbl(strcmp(table2cell(tbl(:,'Sex')),'Male'),'TIIDM')),'Yes'))) ' (' num2str(100*sum(strcmp(table2cell(tbl(strcmp(table2cell(tbl(:,'Sex')),'Male'),'TIIDM')),'Yes'))/sum(strcmp(table2cell(tbl(:,'Sex')),'Male')),'%.1f') '%)' ];
stats_demography{54,4} = [ num2str(sum(strcmp(table2cell(tbl(strcmp(table2cell(tbl(:,'Sex')),'Female'),'TIIDM')),'Yes'))) ' (' num2str(100*sum(strcmp(table2cell(tbl(strcmp(table2cell(tbl(:,'Sex')),'Female'),'TIIDM')),'Yes'))/sum(strcmp(table2cell(tbl(:,'Sex')),'Female')),'%.1f') '%)' ];

stats_demography{57,2} = [ num2str(sum(strcmp(table2cell(tbl(:,'Cancer Hx')),'No'))) ' (' num2str(100*sum(strcmp(table2cell(tbl(:,'Cancer Hx')),'No'))/stats_demography{2,2},'%.1f') '%)' ];
stats_demography{57,3} = [ num2str(sum(strcmp(table2cell(tbl(strcmp(table2cell(tbl(:,'Sex')),'Male'),'Cancer Hx')),'No'))) ' (' num2str(100*sum(strcmp(table2cell(tbl(strcmp(table2cell(tbl(:,'Sex')),'Male'),'Cancer Hx')),'No'))/sum(strcmp(table2cell(tbl(:,'Sex')),'Male')),'%.1f') '%)' ];
stats_demography{57,4} = [ num2str(sum(strcmp(table2cell(tbl(strcmp(table2cell(tbl(:,'Sex')),'Female'),'Cancer Hx')),'No'))) ' (' num2str(100*sum(strcmp(table2cell(tbl(strcmp(table2cell(tbl(:,'Sex')),'Female'),'Cancer Hx')),'No'))/sum(strcmp(table2cell(tbl(:,'Sex')),'Female')),'%.1f') '%)' ];

stats_demography{58,2} = [ num2str(sum(strcmp(table2cell(tbl(:,'Cancer Hx')),'Yes'))) ' (' num2str(100*sum(strcmp(table2cell(tbl(:,'Cancer Hx')),'Yes'))/stats_demography{2,2},'%.1f') '%)' ];
stats_demography{58,3} = [ num2str(sum(strcmp(table2cell(tbl(strcmp(table2cell(tbl(:,'Sex')),'Male'),'Cancer Hx')),'Yes'))) ' (' num2str(100*sum(strcmp(table2cell(tbl(strcmp(table2cell(tbl(:,'Sex')),'Male'),'Cancer Hx')),'Yes'))/sum(strcmp(table2cell(tbl(:,'Sex')),'Male')),'%.1f') '%)' ];
stats_demography{58,4} = [ num2str(sum(strcmp(table2cell(tbl(strcmp(table2cell(tbl(:,'Sex')),'Female'),'Cancer Hx')),'Yes'))) ' (' num2str(100*sum(strcmp(table2cell(tbl(strcmp(table2cell(tbl(:,'Sex')),'Female'),'Cancer Hx')),'Yes'))/sum(strcmp(table2cell(tbl(:,'Sex')),'Female')),'%.1f') '%)' ];

stats_demography{61,2} = [ num2str(sum(strcmp(table2cell(tbl(:,'Stroke Hx')),'No'))) ' (' num2str(100*sum(strcmp(table2cell(tbl(:,'Stroke Hx')),'No'))/stats_demography{2,2},'%.1f') '%)' ];
stats_demography{61,3} = [ num2str(sum(strcmp(table2cell(tbl(strcmp(table2cell(tbl(:,'Sex')),'Male'),'Stroke Hx')),'No'))) ' (' num2str(100*sum(strcmp(table2cell(tbl(strcmp(table2cell(tbl(:,'Sex')),'Male'),'Stroke Hx')),'No'))/sum(strcmp(table2cell(tbl(:,'Sex')),'Male')),'%.1f') '%)' ];
stats_demography{61,4} = [ num2str(sum(strcmp(table2cell(tbl(strcmp(table2cell(tbl(:,'Sex')),'Female'),'Stroke Hx')),'No'))) ' (' num2str(100*sum(strcmp(table2cell(tbl(strcmp(table2cell(tbl(:,'Sex')),'Female'),'Stroke Hx')),'No'))/sum(strcmp(table2cell(tbl(:,'Sex')),'Female')),'%.1f') '%)' ];

stats_demography{62,2} = [ num2str(sum(strcmp(table2cell(tbl(:,'Stroke Hx')),'Yes'))) ' (' num2str(100*sum(strcmp(table2cell(tbl(:,'Stroke Hx')),'Yes'))/stats_demography{2,2},'%.1f') '%)' ];
stats_demography{62,3} = [ num2str(sum(strcmp(table2cell(tbl(strcmp(table2cell(tbl(:,'Sex')),'Male'),'Stroke Hx')),'Yes'))) ' (' num2str(100*sum(strcmp(table2cell(tbl(strcmp(table2cell(tbl(:,'Sex')),'Male'),'Stroke Hx')),'Yes'))/sum(strcmp(table2cell(tbl(:,'Sex')),'Male')),'%.1f') '%)' ];
stats_demography{62,4} = [ num2str(sum(strcmp(table2cell(tbl(strcmp(table2cell(tbl(:,'Sex')),'Female'),'Stroke Hx')),'Yes'))) ' (' num2str(100*sum(strcmp(table2cell(tbl(strcmp(table2cell(tbl(:,'Sex')),'Female'),'Stroke Hx')),'Yes'))/sum(strcmp(table2cell(tbl(:,'Sex')),'Female')),'%.1f') '%)' ];

%% Sex as categorical variable
tbl.Sex = categorical(tbl.Sex);

%% Model 1
% apoe4_bin = cell2mat(table2cell(tbl(:,'APOE e4 mutations')))>0;
apoe4_bin = categorical(cell2mat(table2cell(tbl(:,'APOE e4 mutations'))));
ischemic_heart_disease = strcmp(table2cell(tbl(:,'Heart Issues')),'Yes') & ( strcmp(table2cell(tbl(:,'Ischemic vs non-ischemic heart disease ')),'Ischemic') | strcmp(table2cell(tbl(:,'Ischemic vs non-ischemic heart disease ')),'Ischemic ') );
age = cell2mat(table2cell(tbl(:,'Age ')));
bmi = cell2mat(table2cell(tbl(:,'BMI')));
hba1c = cell2mat(table2cell(tbl(:,'HbA1C')));
hypertension = strcmp(table2cell(tbl(:,'HTN ')),'Yes');
hyperlipidemia = strcmp(table2cell(tbl(:,'HLD')),'Yes');
cancer = strcmp(table2cell(tbl(:,'Cancer Hx')),'Yes');
diabetes2 = strcmp(table2cell(tbl(:,'TIIDM')),'Yes');
tobacco = table2cell(tbl(:,'Tobacco use (Current, former use, never) '));
tobacco(cellfun(@isnumeric, tobacco)) = {'Unknown'};

T1 = [
    0 0 0 0
    0 1 0 0
    0 0 1 0
    0 0 0 1
    ];

T1b = [
    0 0 0 0 0
    0 1 0 0 0
    0 0 1 0 0
    0 0 0 1 0
    0 0 0 0 1
    ];

T1b_int = [
    0 0 0 0 0
    0 1 0 0 0
    0 0 1 0 0
    0 0 0 1 0
    0 0 0 0 1
    0 1 0 0 1
    ];


T1c = [
    0 0 0 0 0 0
    0 1 0 0 0 0
    0 0 1 0 0 0
    0 0 0 1 0 0
    0 0 0 0 1 0
    0 0 0 0 0 1
    ];

T1c_int = [
    0 0 0 0 0 0
    0 1 0 0 0 0
    0 0 1 0 0 0
    0 0 0 1 0 0
    0 0 0 0 1 0
    0 0 0 0 0 1
    0 1 0 0 0 1
    ];

T1d = [
    0 0 0 0 0 0 0
    0 1 0 0 0 0 0
    0 0 1 0 0 0 0
    0 0 0 1 0 0 0
    0 0 0 0 1 0 0
    0 0 0 0 0 1 0
    0 0 0 0 0 0 1
    ];

T1d_int = [
    0 0 0 0 0 0 0
    0 1 0 0 0 0 0
    0 0 1 0 0 0 0
    0 0 0 1 0 0 0
    0 0 0 0 1 0 0
    0 0 0 0 0 1 0
    0 0 0 0 0 0 1
    0 1 0 0 0 0 1
    ];

T2 = [
    0 0 0 0
    0 1 0 0
    0 0 1 0
    0 0 0 1
    0 1 0 1
    ];

T2b = [
    0 0 0 0 0
    0 1 0 0 0
    0 0 1 0 0
    0 0 0 1 0
    0 0 0 0 1
    0 1 0 0 1
    ];

T3 = [
    0 0 0 0 0 0 0 0 0
    0 1 0 0 0 0 0 0 0
    0 0 1 0 0 0 0 0 0
    0 0 0 1 0 0 0 0 0
    0 0 0 0 1 0 0 0 0
    0 0 0 0 0 1 0 0 0
    0 0 0 0 0 0 1 0 0
    0 0 0 0 0 0 0 1 0
    0 0 0 0 0 0 0 0 1
    ];

T4 = [
    0 0 0 0 0 0 0 0 0
    0 1 0 0 0 0 0 0 0
    0 0 1 0 0 0 0 0 0
    0 0 0 1 0 0 0 0 0
    0 0 0 0 1 0 0 0 0
    0 0 0 0 0 1 0 0 0
    0 0 0 0 0 0 1 0 0
    0 0 0 0 0 0 0 1 0
    0 0 0 0 0 0 0 0 1
    0 1 0 0 0 0 0 0 1
    ];

T5 = [
    0 0 0 0 0 0 0 0
    0 1 0 0 0 0 0 0
    0 0 1 0 0 0 0 0
    0 0 0 1 0 0 0 0
    0 0 0 0 1 0 0 0
    0 0 0 0 0 1 0 0
    0 0 0 0 0 0 1 0
    0 0 0 0 0 0 0 1
    ];

T6 = [
    0 0 0 0 0 0 0 0
    0 1 0 0 0 0 0 0
    0 0 1 0 0 0 0 0
    0 0 0 1 0 0 0 0
    0 0 0 0 1 0 0 0
    0 0 0 0 0 1 0 0
    0 0 0 0 0 0 1 0
    0 0 0 0 0 0 0 1
    0 1 0 0 0 0 0 1
    ];

T7 = [
    0 0 0 0 0 0 0 0 0 0 0
    0 1 0 0 0 0 0 0 0 0 0
    0 0 1 0 0 0 0 0 0 0 0
    0 0 0 1 0 0 0 0 0 0 0
    0 0 0 0 1 0 0 0 0 0 0
    0 0 0 0 0 1 0 0 0 0 0
    0 0 0 0 0 0 1 0 0 0 0
    0 0 0 0 0 0 0 1 0 0 0
    0 0 0 0 0 0 0 0 1 0 0
    0 0 0 0 0 0 0 0 0 1 0
    0 0 0 0 0 0 0 0 0 0 1
    ];

% T8 = [
%     0 0 0 0 0 0 0 0 0 0
%     0 1 0 0 0 0 0 0 0 0
%     0 0 1 0 0 0 0 0 0 0
%     0 0 0 1 0 0 0 0 0 0
%     0 0 0 0 1 0 0 0 0 0
%     0 0 0 0 0 1 0 0 0 0
%     0 0 0 0 0 0 1 0 0 0
%     0 0 0 0 0 0 0 1 0 0
%     0 0 0 0 0 0 0 0 1 0
%     0 0 0 0 0 0 0 0 0 1
%     ];

T8 = [
    0 0 0 0 0 0 0 0 0
    0 1 0 0 0 0 0 0 0
    0 0 1 0 0 0 0 0 0
    0 0 0 1 0 0 0 0 0
    0 0 0 0 1 0 0 0 0
    0 0 0 0 0 1 0 0 0
    0 0 0 0 0 0 1 0 0
    0 0 0 0 0 0 0 1 0
    0 0 0 0 0 0 0 0 1
    0 0 0 0 0 0 0 0 0
    ];

tbl2 = [table(ischemic_heart_disease,apoe4_bin,age/10,'VariableNames',{'IschemicHeartDisease', 'APOE4', 'Age'}) tbl(:,'Sex') ];
% tbl3 = [table(ischemic_heart_disease,~apoe4_bin,age/10,'VariableNames',{'IschemicHeartDisease', 'APOE4', 'Age'}) tbl(:,'Sex') ];
tbl2b = [table(ischemic_heart_disease,apoe4_bin,age/10,hypertension,'VariableNames',{'IschemicHeartDisease', 'APOE4','Age', 'Hypertension'}) tbl(:,'Sex') ];
tbl4 = [table(ischemic_heart_disease,apoe4_bin,age/10,bmi,hypertension,hyperlipidemia,diabetes2,tobacco,'VariableNames',{'IschemicHeartDisease', 'APOE4', 'Age','BMI','Hypertension','Hyperlipidemia','Diabetes2','Tobacco'}) tbl(:,'Sex') ];
tbl4(strcmp(table2cell(tbl4(:,'Tobacco')),'Unknown'),:) = [];
tbl4.Tobacco = categorical(tbl4.Tobacco);

tbl5 = [table(double(ischemic_heart_disease),apoe4_bin,age/10,bmi,hypertension,hyperlipidemia,diabetes2,'VariableNames',{'IschemicHeartDisease', 'APOE4', 'Age','BMI','Hypertension','Hyperlipidemia','Diabetes2'}) tbl(:,'Sex') ];

%  and hemoglobin A1c 

tbl6 = [table(double(ischemic_heart_disease),apoe4_bin,age/10,bmi,hypertension,hyperlipidemia,diabetes2,tobacco,cancer,hba1c,'VariableNames',{'IschemicHeartDisease', 'APOE4', 'Age','BMI','Hypertension','Hyperlipidemia','Diabetes2','Tobacco','Cancer','HbA1c'}) tbl(:,'Sex') ];
tbl6(strcmp(table2cell(tbl6(:,'Tobacco')),'Unknown'),:) = [];
tbl6.Tobacco = categorical(tbl6.Tobacco);

tbl7 = [table(ischemic_heart_disease,apoe4_bin,age/10,hyperlipidemia,'VariableNames',{'IschemicHeartDisease', 'APOE4', 'Age','Hyperlipidemia'}) tbl(:,'Sex') ];
tbl8 = [table(ischemic_heart_disease,apoe4_bin,age/10,hyperlipidemia,hypertension,'VariableNames',{'IschemicHeartDisease', 'APOE4', 'Age','Hyperlipidemia','Hypertension'}) tbl(:,'Sex') ];
tbl9 = [table(ischemic_heart_disease,apoe4_bin,age/10,hyperlipidemia,hypertension,hba1c,'VariableNames',{'IschemicHeartDisease', 'APOE4', 'Age','Hyperlipidemia','Hypertension','HbA1c'}) tbl(:,'Sex') ];

% tbl10 = [table(double(ischemic_heart_disease),apoe4_bin,age/10,hyperlipidemia,hypertension,diabetes2,tobacco,cancer,hba1c,'VariableNames',{'IschemicHeartDisease', 'APOE4', 'Age','Hyperlipidemia','Hypertension','Diabetes2','Tobacco','Cancer','HbA1c'}) tbl(:,'Sex') ];
tbl10 = [table(double(ischemic_heart_disease),apoe4_bin,age/10,hyperlipidemia,hypertension,diabetes2,tobacco,hba1c,'VariableNames',{'IschemicHeartDisease', 'APOE4', 'Age','Hyperlipidemia','Hypertension','Diabetes2','Tobacco','HbA1c'}) tbl(:,'Sex') ];
tbl10(strcmp(table2cell(tbl10(:,'Tobacco')),'Unknown'),:) = [];
tbl10.Tobacco = categorical(tbl10.Tobacco);


tbl11 = [table(ischemic_heart_disease,apoe4_bin,hyperlipidemia,hypertension,'VariableNames',{'IschemicHeartDisease', 'APOE4','Hyperlipidemia','Hypertension'}) tbl(:,'Sex') ];

mdl1_ischHeartDis = fitglm(tbl2,T1,'distribution','binomial'); % originally used fitlm
mdl1b_ischHeartDis = fitglm(tbl2b,T1b,'distribution','binomial'); % originally used fitlm
mdl2_ischHeartDis = fitglm(tbl2,T2,'distribution','binomial');
mdl2b_ischHeartDis = fitglm(tbl2b,T2b,'distribution','binomial');
mdl3_ischHeartDis = fitglm(tbl4,T3,'distribution','binomial');
mdl4_ischHeartDis = fitglm(tbl4,T4,'distribution','binomial');
mdl5_ischHeartDis = fitglm(tbl5,T5,'distribution','binomial');
mdl6_ischHeartDis = fitglm(tbl5,T6,'distribution','binomial');
mdl7_ischHeartDis = fitglm(tbl6,T7,'distribution','binomial');

mdl8_ischHeartDis = fitglm(tbl7,T1b,'distribution','binomial');
mdl9_ischHeartDis = fitglm(tbl8,T1c,'distribution','binomial');
mdl10_ischHeartDis = fitglm(tbl9,T1d,'distribution','binomial');

mdl8int_ischHeartDis = fitglm(tbl7,T1b_int,'distribution','binomial');
mdl9int_ischHeartDis = fitglm(tbl8,T1c_int,'distribution','binomial');
mdl10int_ischHeartDis = fitglm(tbl9,T1d_int,'distribution','binomial');

% tbl6.IschemicHeartDisease = categorical(tbl6.IschemicHeartDisease);
% mdl11_ischHeartDis = stepwiseglm(tbl10,'IschemicHeartDisease ~ 1 + APOE4 + Age + Hypertension + Hyperlipidemia + Diabetes2 + Tobacco + Cancer + HbA1c + Sex','distribution','binomial');
mdl11_ischHeartDis = stepwiseglm(tbl10,T8,'Upper','linear','distribution','binomial');
% mdl11_ischHeartDis = stepwiseglm(tbl9,T1d,'Upper','linear','distribution','binomial');

mdl11int_ischHeartDis = fitglm(tbl11,T2b,'distribution','binomial');

ci2b_ischHeartDis = coefCI(mdl2b_ischHeartDis);

ci1_ischHeartDis = coefCI(mdl1_ischHeartDis);
ci8_ischHeartDis = coefCI(mdl8_ischHeartDis);
ci9_ischHeartDis = coefCI(mdl9_ischHeartDis);
ci10_ischHeartDis = coefCI(mdl10_ischHeartDis);
ci11_ischHeartDis = coefCI(mdl11_ischHeartDis);

ci8int_ischHeartDis = coefCI(mdl8int_ischHeartDis);
ci9int_ischHeartDis = coefCI(mdl9int_ischHeartDis);
ci10int_ischHeartDis = coefCI(mdl10int_ischHeartDis);

odds_mdl9int_ischHeartDis = exp(cell2mat(table2cell(mdl9int_ischHeartDis.Coefficients(:,'Estimate'))));
odds_mdl10int_ischHeartDis = exp(cell2mat(table2cell(mdl10int_ischHeartDis.Coefficients(:,'Estimate'))));

odds_ci9int_ischHeartDis = exp(ci9int_ischHeartDis);
odds_ci10int_ischHeartDis = exp(ci10int_ischHeartDis);


tbl2 = [table(hypertension,apoe4_bin,age/10,'VariableNames',{'Hypertension', 'APOE4', 'Age'}) tbl(:,'Sex') ];
% tbl3 = [table(hypertension,~apoe4_bin,age/10,'VariableNames',{'Hypertension', 'APOE4', 'Age'}) tbl(:,'Sex') ];

mdl1_hypertension = fitglm(tbl2,T1,'distribution','binomial');
mdl2_hypertension = fitglm(tbl2,T2,'distribution','binomial');

tbl2 = [table(hyperlipidemia,apoe4_bin,age/10,'VariableNames',{'Hyperlipidemia', 'APOE4', 'Age'}) tbl(:,'Sex') ];
% tbl3 = [table(hyperlipidemia,~apoe4_bin,age/10,'VariableNames',{'Hyperlipidemia', 'APOE4', 'Age'}) tbl(:,'Sex') ];

mdl1_hyperlipidemia = fitglm(tbl2,T1,'distribution','binomial');
mdl2_hyperlipidemia = fitglm(tbl2,T2,'distribution','binomial');

tbl2 = [table(cancer,apoe4_bin,age/10,'VariableNames',{'Cancer', 'APOE4', 'Age'}) tbl(:,'Sex') ];
% tbl3 = [table(cancer,~apoe4_bin,age/10,'VariableNames',{'Cancer', 'APOE4', 'Age'}) tbl(:,'Sex') ];

mdl1_cancer = fitglm(tbl2,T1,'distribution','binomial');
mdl2_cancer = fitglm(tbl2,T2,'distribution','binomial');

tbl2 = [table(diabetes2,apoe4_bin,age/10,'VariableNames',{'Diabetes2', 'APOE4', 'Age'}) tbl(:,'Sex') ];
% tbl3 = [table(diabetes2,~apoe4_bin,age/10,'VariableNames',{'Diabetes2', 'APOE4', 'Age'}) tbl(:,'Sex') ];

mdl1_diabetes2 = fitglm(tbl2,T1,'distribution','binomial');
mdl2_diabetes2 = fitglm(tbl2,T2,'distribution','binomial');

tbl2 = [table(bmi,apoe4_bin,age/10,'VariableNames',{'BMI', 'APOE4', 'Age'}) tbl(:,'Sex') ];
% tbl3 = [table(bmi,~apoe4_bin,age/10,'VariableNames',{'BMI', 'APOE4', 'Age'}) tbl(:,'Sex') ];

mdl1_bmi = fitglm(tbl2,T1);
mdl2_bmi = fitglm(tbl2,T2);

tbl2 = [table(hba1c,apoe4_bin,age/10,'VariableNames',{'HgbA1c', 'APOE4', 'Age'}) tbl(:,'Sex') ];
% tbl3 = [table(hba1c,~apoe4_bin,age/10,'VariableNames',{'HgbA1c', 'APOE4', 'Age'}) tbl(:,'Sex') ];

mdl1_hba1c = fitglm(tbl2,T1);
mdl2_hba1c = fitglm(tbl2,T2);

%% Visualization

ymax = 10;
% yticklbl = {
%     ['IHD ∝ ' mdl11_ischHeartDis.Formula.LinearPredictor]
%     ['IHD ∝ ' mdl10_ischHeartDis.Formula.LinearPredictor]
%     ['IHD ∝ ' mdl9_ischHeartDis.Formula.LinearPredictor]
%     ['IHD ∝ ' mdl8_ischHeartDis.Formula.LinearPredictor]
%     ['IHD ∝ ' mdl1_ischHeartDis.Formula.LinearPredictor]
%     };
% yticklbl = strrep(yticklbl,'1 +','x_0 +');

yticklbl = {
    'Stepwise log. regression'
    'HbA1c added'
    'Hypertension added'
    'Hyperlipidemia added'
    'Base Model: APOE4, Age, Sex'
    };

clr_apoe4_homo = [1 0 0];
clr_apoe4_hetero = [1 0 1];
clr_sex = [0 0 1];
clr_age = [0 1 0];
clr_hyperlipidemia = [0.3 0.3 0.3];
clr_hypertension = [0 1 1];
clr_hba1c = [0.7 0.7 0];
clr_cancer = [0.75 0.75 0.75];

h(1).fig = figure(1);
set(h(1).fig,'Position',[600 50 1200 1100])

mdl = mdl1_ischHeartDis;
ci = ci1_ischHeartDis;
cii = [];
plot([0 0],[-10 10],'k','LineWidth',2)
hold on

e_apoe4_hetero = exp(cell2mat(table2cell(mdl.Coefficients('APOE4_1','Estimate'))));
e_apoe4_homo = exp(cell2mat(table2cell(mdl.Coefficients('APOE4_2','Estimate'))));
e_sex = exp(cell2mat(table2cell(mdl.Coefficients('Sex_Male','Estimate'))));
e_age = exp(cell2mat(table2cell(mdl.Coefficients('Age','Estimate'))));
ci_apoe4_hetero = exp(ci(strcmp(mdl.CoefficientNames,'APOE4_1'),:));
ci_apoe4_homo = exp(ci(strcmp(mdl.CoefficientNames,'APOE4_2'),:));
ci_sex = exp(ci(strcmp(mdl.CoefficientNames,'Sex_Male'),:));
ci_age = exp(ci(strcmp(mdl.CoefficientNames,'Age'),:));

%%
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

plot(e_apoe4_homo,y,'d','MarkerSize',14,'LineWidth',4,'Color',clr_apoe4_homo,'markerfacecolor',clr_apoe4_homo);
plot(e_apoe4_hetero,[y-0.3 y-0.3],'x','MarkerSize',14,'LineWidth',4,'Color',clr_apoe4_hetero,'markerfacecolor',clr_apoe4_hetero);
plot(e_sex,[y-0.6 y-0.6],'o','MarkerSize',14,'LineWidth',4,'Color',clr_sex,'markerfacecolor',clr_sex);
plot(e_age,[y-0.9 y-0.9],'^','MarkerSize',14,'LineWidth',4,'Color',clr_age,'markerfacecolor',clr_age);

%%
mdl = mdl8_ischHeartDis;
ci = ci8_ischHeartDis;
e_apoe4_hetero = exp(cell2mat(table2cell(mdl.Coefficients('APOE4_1','Estimate'))));
e_apoe4_homo = exp(cell2mat(table2cell(mdl.Coefficients('APOE4_2','Estimate'))));
e_sex = exp(cell2mat(table2cell(mdl.Coefficients('Sex_Male','Estimate'))));
e_age = exp(cell2mat(table2cell(mdl.Coefficients('Age','Estimate'))));
e_hyperlipidemia = exp(cell2mat(table2cell(mdl.Coefficients('Hyperlipidemia_1','Estimate'))));
ci_apoe4_hetero = exp(ci(strcmp(mdl.CoefficientNames,'APOE4_1'),:));
ci_apoe4_homo = exp(ci(strcmp(mdl.CoefficientNames,'APOE4_2'),:));
ci_sex = exp(ci(strcmp(mdl.CoefficientNames,'Sex_Male'),:));
ci_age = exp(ci(strcmp(mdl.CoefficientNames,'Age'),:));
ci_hyperlipidemia = exp(ci(strcmp(mdl.CoefficientNames,'Hyperlipidemia_1'),:));

cii = [cii; ci_apoe4_hetero; ci_apoe4_homo; ci_sex; ci_age; ci_hyperlipidemia];
E_apoe4_hetero = [E_apoe4_hetero; e_apoe4_hetero];
E_apoe4_homo = [E_apoe4_homo; e_apoe4_homo];
E_hyperlipidemia = e_hyperlipidemia;
E_sex = [E_sex; e_sex];
E_age = [E_age; e_age];
y = ymax - 3;
plot(ci_apoe4_homo,[y y],'-','LineWidth',4,'Color',clr_apoe4_homo)
plot(ci_apoe4_hetero,[y-0.3 y-0.3],'-','LineWidth',4,'Color',clr_apoe4_hetero)
plot(ci_sex,[y-0.6 y-0.6],'-','LineWidth',4,'Color',clr_sex)
plot(ci_age,[y-0.9 y-0.9],'-','LineWidth',4,'Color',clr_age)
plot(ci_hyperlipidemia,[y-1.2 y-1.2],'-','LineWidth',4,'Color',clr_hyperlipidemia)

plot(e_apoe4_homo,y,'d','MarkerSize',14,'LineWidth',4,'Color',clr_apoe4_homo,'markerfacecolor',clr_apoe4_homo);
plot(e_apoe4_hetero,[y-0.3 y-0.3],'x','MarkerSize',14,'LineWidth',4,'Color',clr_apoe4_hetero,'markerfacecolor',clr_apoe4_hetero);
plot(e_sex,[y-0.6 y-0.6],'o','MarkerSize',14,'LineWidth',4,'Color',clr_sex,'markerfacecolor',clr_sex);
plot(e_age,[y-0.9 y-0.9],'^','MarkerSize',14,'LineWidth',4,'Color',clr_age,'markerfacecolor',clr_age);
plot(e_hyperlipidemia,[y-1.2 y-1.2],'v','MarkerSize',14,'LineWidth',4,'Color',clr_hyperlipidemia,'markerfacecolor',clr_hyperlipidemia);

%%
mdl = mdl9_ischHeartDis;
ci = ci9_ischHeartDis;
e_apoe4_hetero = exp(cell2mat(table2cell(mdl.Coefficients('APOE4_1','Estimate'))));
e_apoe4_homo = exp(cell2mat(table2cell(mdl.Coefficients('APOE4_2','Estimate'))));
e_sex = exp(cell2mat(table2cell(mdl.Coefficients('Sex_Male','Estimate'))));
e_age = exp(cell2mat(table2cell(mdl.Coefficients('Age','Estimate'))));
e_hyperlipidemia = exp(cell2mat(table2cell(mdl.Coefficients('Hyperlipidemia_1','Estimate'))));
e_hypertension = exp(cell2mat(table2cell(mdl.Coefficients('Hypertension_1','Estimate'))));
ci_apoe4_hetero = exp(ci(strcmp(mdl.CoefficientNames,'APOE4_1'),:));
ci_apoe4_homo = exp(ci(strcmp(mdl.CoefficientNames,'APOE4_2'),:));
ci_sex = exp(ci(strcmp(mdl.CoefficientNames,'Sex_Male'),:));
ci_age = exp(ci(strcmp(mdl.CoefficientNames,'Age'),:));
ci_hyperlipidemia = exp(ci(strcmp(mdl.CoefficientNames,'Hyperlipidemia_1'),:));
ci_hypertension = exp(ci(strcmp(mdl.CoefficientNames,'Hypertension_1'),:));

cii = [cii; ci_apoe4_hetero; ci_apoe4_homo; ci_sex; ci_age; ci_hyperlipidemia; ci_hypertension];
E_apoe4_hetero = [E_apoe4_hetero; e_apoe4_hetero];
E_apoe4_homo = [E_apoe4_homo; e_apoe4_homo];
E_hyperlipidemia = [E_hyperlipidemia; e_hyperlipidemia];
E_hypertension = e_hypertension;
E_sex = [E_sex; e_sex];
E_age = [E_age; e_age];
y = ymax - 5;
plot(ci_apoe4_homo,[y y],'-','LineWidth',4,'Color',clr_apoe4_homo)
plot(ci_apoe4_hetero,[y-0.3 y-0.3],'-','LineWidth',4,'Color',clr_apoe4_hetero)
plot(ci_sex,[y-0.6 y-0.6],'-','LineWidth',4,'Color',clr_sex)
plot(ci_age,[y-0.9 y-0.9],'-','LineWidth',4,'Color',clr_age)
plot(ci_hyperlipidemia,[y-1.2 y-1.2],'-','LineWidth',4,'Color',clr_hyperlipidemia)
plot(ci_hypertension,[y-1.5 y-1.5],'-','LineWidth',4,'Color',clr_hypertension)


plot(e_apoe4_homo,y,'d','MarkerSize',14,'LineWidth',4,'Color',clr_apoe4_homo,'markerfacecolor',clr_apoe4_homo);
plot(e_apoe4_hetero,[y-0.3 y-0.3],'x','MarkerSize',14,'LineWidth',4,'Color',clr_apoe4_hetero,'markerfacecolor',clr_apoe4_hetero);
plot(e_sex,[y-0.6 y-0.6],'o','MarkerSize',14,'LineWidth',4,'Color',clr_sex,'markerfacecolor',clr_sex);
plot(e_age,[y-0.9 y-0.9],'^','MarkerSize',14,'LineWidth',4,'Color',clr_age,'markerfacecolor',clr_age);
plot(e_hyperlipidemia,[y-1.2 y-1.2],'v','MarkerSize',14,'LineWidth',4,'Color',clr_hyperlipidemia,'markerfacecolor',clr_hyperlipidemia);
plot(e_hypertension,[y-1.5 y-1.5],'>','MarkerSize',14,'LineWidth',4,'Color',clr_hypertension,'markerfacecolor',clr_hypertension);

%%
mdl = mdl10_ischHeartDis;
ci = ci10_ischHeartDis;
e_apoe4_hetero = exp(cell2mat(table2cell(mdl.Coefficients('APOE4_1','Estimate'))));
e_apoe4_homo = exp(cell2mat(table2cell(mdl.Coefficients('APOE4_2','Estimate'))));
e_sex = exp(cell2mat(table2cell(mdl.Coefficients('Sex_Male','Estimate'))));
e_age = exp(cell2mat(table2cell(mdl.Coefficients('Age','Estimate'))));
e_hyperlipidemia = exp(cell2mat(table2cell(mdl.Coefficients('Hyperlipidemia_1','Estimate'))));
e_hypertension = exp(cell2mat(table2cell(mdl.Coefficients('Hypertension_1','Estimate'))));
e_hba1c = exp(cell2mat(table2cell(mdl.Coefficients('HbA1c','Estimate'))));
ci_apoe4_hetero = exp(ci(strcmp(mdl.CoefficientNames,'APOE4_1'),:));
ci_apoe4_homo = exp(ci(strcmp(mdl.CoefficientNames,'APOE4_2'),:));
ci_sex = exp(ci(strcmp(mdl.CoefficientNames,'Sex_Male'),:));
ci_age = exp(ci(strcmp(mdl.CoefficientNames,'Age'),:));
ci_hyperlipidemia = exp(ci(strcmp(mdl.CoefficientNames,'Hyperlipidemia_1'),:));
ci_hypertension = exp(ci(strcmp(mdl.CoefficientNames,'Hypertension_1'),:));
ci_hba1c = exp(ci(strcmp(mdl.CoefficientNames,'HbA1c'),:));

cii = [cii; ci_apoe4_hetero; ci_apoe4_homo; ci_sex; ci_age; ci_hyperlipidemia; ci_hypertension; ci_hba1c];
E_apoe4_hetero = [E_apoe4_hetero; e_apoe4_hetero];
E_apoe4_homo = [E_apoe4_homo; e_apoe4_homo];
E_hyperlipidemia = [E_hyperlipidemia; e_hyperlipidemia];
E_hypertension = [E_hypertension; e_hypertension];
E_sex = [E_sex; e_sex];
E_age = [E_age; e_age];
y = ymax - 7;
plot(ci_apoe4_homo,[y y],'-','LineWidth',4,'Color',clr_apoe4_homo)
plot(ci_apoe4_hetero,[y-0.3 y-0.3],'-','LineWidth',4,'Color',clr_apoe4_hetero)
plot(ci_sex,[y-0.6 y-0.6],'-','LineWidth',4,'Color',clr_sex)
plot(ci_age,[y-0.9 y-0.9],'-','LineWidth',4,'Color',clr_age)
plot(ci_hyperlipidemia,[y-1.2 y-1.2],'-','LineWidth',4,'Color',clr_hyperlipidemia)
plot(ci_hypertension,[y-1.5 y-1.5],'-','LineWidth',4,'Color',clr_hypertension)
plot(ci_hba1c,[y-1.8 y-1.8],'-','LineWidth',4,'Color',clr_hba1c)

H1 = plot(e_apoe4_homo,y,'d','MarkerSize',14,'LineWidth',4,'Color',clr_apoe4_homo,'markerfacecolor',clr_apoe4_homo);
H2 = plot(e_apoe4_hetero,[y-0.3 y-0.3],'x','MarkerSize',14,'LineWidth',4,'Color',clr_apoe4_hetero,'markerfacecolor',clr_apoe4_hetero);
H3 = plot(e_sex,[y-0.6 y-0.6],'o','MarkerSize',14,'LineWidth',4,'Color',clr_sex,'markerfacecolor',clr_sex);
H4 = plot(e_age,[y-0.9 y-0.9],'^','MarkerSize',14,'LineWidth',4,'Color',clr_age,'markerfacecolor',clr_age);
H5 = plot(e_hyperlipidemia,[y-1.2 y-1.2],'v','MarkerSize',14,'LineWidth',4,'Color',clr_hyperlipidemia,'markerfacecolor',clr_hyperlipidemia);
H6 = plot(e_hypertension,[y-1.5 y-1.5],'>','MarkerSize',14,'LineWidth',4,'Color',clr_hypertension,'markerfacecolor',clr_hypertension);
H7 = plot(e_hba1c,[y-1.8 y-1.8],'s','MarkerSize',14,'LineWidth',4,'Color',clr_hba1c,'markerfacecolor',clr_hba1c);


%%
mdl = mdl11_ischHeartDis;
ci = ci11_ischHeartDis;
e_apoe4_hetero = exp(cell2mat(table2cell(mdl.Coefficients('APOE4_1','Estimate'))));
e_apoe4_homo = exp(cell2mat(table2cell(mdl.Coefficients('APOE4_2','Estimate'))));
% e_sex = exp(cell2mat(table2cell(mdl.Coefficients('Sex_Male','Estimate'))));
e_hyperlipidemia = exp(cell2mat(table2cell(mdl.Coefficients('Hyperlipidemia_1','Estimate'))));
e_hypertension = exp(cell2mat(table2cell(mdl.Coefficients('Hypertension_1','Estimate'))));
% e_cancer = exp(cell2mat(table2cell(mdl.Coefficients('Cancer_1','Estimate'))));
ci_apoe4_hetero = exp(ci(strcmp(mdl.CoefficientNames,'APOE4_1'),:));
ci_apoe4_homo = exp(ci(strcmp(mdl.CoefficientNames,'APOE4_2'),:));
% ci_sex = ci(strcmp(mdl.CoefficientNames,'Sex_Male'),:);
ci_hyperlipidemia = exp(ci(strcmp(mdl.CoefficientNames,'Hyperlipidemia_1'),:));
ci_hypertension = exp(ci(strcmp(mdl.CoefficientNames,'Hypertension_1'),:));
% ci_cancer = exp(ci(strcmp(mdl.CoefficientNames,'Cancer_1'),:));

cii = [cii; ci_apoe4_hetero; ci_apoe4_homo; ci_hyperlipidemia; ci_hypertension];
E_apoe4_hetero = [E_apoe4_hetero; e_apoe4_hetero];
E_apoe4_homo = [E_apoe4_homo; e_apoe4_homo];
E_hyperlipidemia = [E_hyperlipidemia; e_hyperlipidemia];
E_hypertension = [E_hypertension; e_hypertension];
y = ymax - 9.3;
plot(ci_apoe4_homo,[y y],'-','LineWidth',4,'Color',clr_apoe4_homo)
plot(ci_apoe4_hetero,[y-0.3 y-0.3],'-','LineWidth',4,'Color',clr_apoe4_hetero)
% plot(ci_sex,[y-0.6 y-0.6],'-','LineWidth',4,'Color',clr_sex)
plot(ci_hyperlipidemia,[y-0.6 y-0.6],'-','LineWidth',4,'Color',clr_hyperlipidemia)
plot(ci_hypertension,[y-0.9 y-0.9],'-','LineWidth',4,'Color',clr_hypertension)
% plot(ci_cancer,[y-1.5 y-1.5],'-','LineWidth',4,'Color',clr_cancer)

plot(e_apoe4_homo,y,'d','MarkerSize',14,'LineWidth',4,'Color',clr_apoe4_homo,'markerfacecolor',clr_apoe4_homo);
plot(e_apoe4_hetero,[y-0.3 y-0.3],'x','MarkerSize',14,'LineWidth',4,'Color',clr_apoe4_hetero,'markerfacecolor',clr_apoe4_hetero);
% plot(e_sex,[y-0.6 y-0.6],'o','MarkerSize',14,'LineWidth',4,'Color',clr_sex,'markerfacecolor',clr_sex);
plot(e_hyperlipidemia,[y-0.6 y-0.6],'v','MarkerSize',14,'LineWidth',4,'Color',clr_hyperlipidemia,'markerfacecolor',clr_hyperlipidemia);
plot(e_hypertension,[y-0.9 y-0.9],'>','MarkerSize',14,'LineWidth',4,'Color',clr_hypertension,'markerfacecolor',clr_hypertension);
% H8 = plot(e_cancer,[y-1.5 y-1.5],'|','MarkerSize',14,'LineWidth',4,'Color',clr_cancer,'markerfacecolor',clr_cancer);
%%

hold off
grid on
ylim([-0.55 9.5])
% if max(abs(cii(:))) < 7
%     xlim([-1 7])
% else
%     xlim([0 1.05*max(abs(cii(:)))])
% end
xlim([0 round(max(abs(cii(:)))/100)*100+100])
xlabel('Odds ratio')
% ylabel('Model')
% legend([H1(1,1); H2(1,1); H3(1,1); H4(1,1); H5(1,1); H6(1,1); H7(1,1); H8(1,1)],{
%     'APOE4 homozygous'
%     'APOE4 heterozygous'
%     'Male sex'
%     'Age'
%     'Hyperlipidemia'
%     'Hypertension'
%     'HbA1c'
%     'Cancer'
%     },'Location','West')
legend([H1(1,1); H2(1,1); H3(1,1); H4(1,1); H5(1,1); H6(1,1); H7(1,1);],{
    'APOE4 homozygous'
    'APOE4 heterozygous'
    'Male sex'
    'Age'
    'Hyperlipidemia'
    'Hypertension'
    'HbA1c'
    },'Location','West')
set(gca,'Linewidth',2,'FontSize',18,'YTick',[0.7 3 5 7 9],'YTickLabel',yticklbl,'xscale','log')
ytickangle(40)


%% Stats
state_e_apoe4_hetero = [mean(E_apoe4_hetero) std(E_apoe4_hetero)];
state_e_apoe4_homo = [mean(E_apoe4_homo) std(E_apoe4_homo)];
state_e_hyperlipidemia = [mean(E_hyperlipidemia) std(E_hyperlipidemia)];
state_e_hypertension = [mean(E_hypertension) std(E_hypertension)];
state_e_sex = [mean(E_sex) std(E_sex)];
state_e_age = [mean(E_age) std(E_age)];