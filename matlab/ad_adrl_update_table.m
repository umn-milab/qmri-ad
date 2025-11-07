%% Initiate
clear all;
clc;
close all;

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

data_folder='/home/range1-raid1/labounek/data-on-porto';
project_folder=fullfile(data_folder,'ADAI');
table_folder=fullfile(project_folder,'tables');

xls_file = fullfile(project_folder,'HeartDataset','MasterDataset_April25.xlsx');
[~, ~, raw] = xlsread(xls_file);
raw{1,strcmp(raw(1,:),'Please describe alcohol habits (what kind, how much, how often).')} = 'Alcohol habits';

xls2_file = fullfile(project_folder,'HeartDataset','ADAI Quanterix results.xlsx');
[~, ~, raw2] = xlsread(xls2_file);
[~, ~, raw3] = xlsread(xls2_file,'pTau181');
[~, ~, raw4] = xlsread(xls2_file,'pTau217');
[~, ~, raw5] = xlsread(xls2_file,'Tau');

[rw,cl] = size(raw);

raw{1,cl+1} = 'Position';
raw{1,cl+2} = 'Quanterix Plate #';
raw{1,cl+3} = 'Plate Pos';
raw{1,cl+4} = 'Abeta 40';
raw{1,cl+5} = 'Abeta 42';
raw{1,cl+6} = 'GFAP';
raw{1,cl+7} = 'NF-light';
raw{1,cl+8} = 'pTau181';
raw{1,cl+9} = 'pTau217';
raw{1,cl+10} = 'Tau';

pidn = raw(:,strcmp(raw(1,:),'PIDN'));
pidn{1,1} = NaN;
pidn = cell2mat(pidn);

for ind = 2:size(raw2,1)
    data = raw2;    
    pos = pidn == data{ind,strcmp(data(1,:),'PIDN')};
    if sum(pos) == 0
        pidn(end+1,1) = data{ind,strcmp(data(1,:),'PIDN')};
        pos = pidn == data{ind,strcmp(data(1,:),'PIDN')};
        raw{pos,strcmp(raw(1,:),'PIDN')} = data{ind,strcmp(data(1,:),'PIDN')};
    end
    raw{pos,strcmp(raw(1,:),'Position')} = data{ind,strcmp(data(1,:),'Position')};
    raw{pos,strcmp(raw(1,:),'Quanterix Plate #')} = data{ind,strcmp(data(1,:),'Quanterix Plate #')};
    raw{pos,strcmp(raw(1,:),'Plate Pos')} = data{ind,strcmp(data(1,:),'Plate Pos')};
    raw{pos,strcmp(raw(1,:),'Abeta 40')} = data{ind,strcmp(data(1,:),'Abeta 40')};
    raw{pos,strcmp(raw(1,:),'Abeta 42')} = data{ind,strcmp(data(1,:),'Abeta 42')};
    raw{pos,strcmp(raw(1,:),'GFAP')} = data{ind,strcmp(data(1,:),'GFAP')};
    raw{pos,strcmp(raw(1,:),'NF-light')} = data{ind,strcmp(data(1,:),'NF-light')};
end

for ind = 2:size(raw3,1)
    data = raw3;    
    pos = pidn == data{ind,strcmp(data(1,:),'PIDN')};    
    raw{pos,strcmp(raw(1,:),'pTau181')} = data{ind,strcmp(data(1,:),'pTau181')};
end

for ind = 2:size(raw4,1)
    data = raw4;    
    pos = pidn == data{ind,strcmp(data(1,:),'PIDN')};    
    raw{pos,strcmp(raw(1,:),'pTau217')} = data{ind,strcmp(data(1,:),'pTau217')};
end

for ind = 2:size(raw5,1)
    data = raw5;    
    pos = pidn == data{ind,strcmp(data(1,:),'PIDN')};    
    raw{pos,strcmp(raw(1,:),'Tau')} = data{ind,strcmp(data(1,:),'Tau')};
end

raw(2:end,:) = sortrows(raw(2:end,:),find(strcmp(raw(1,:),'PIDN')==1));