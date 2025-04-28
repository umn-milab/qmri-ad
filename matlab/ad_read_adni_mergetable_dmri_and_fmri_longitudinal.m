clear all;
close all;
% clc;

% sci='sci+mci';
sci='sci+cn';

time_gap = 75;

age_max_limit = 82;

csv_path = '/home/range1-raid1/labounek/data-on-porto/ADNI/StudyData';
csv_filename = 'ADNIMERGE_22Oct2024.csv';
adni_metadata_filename = 'ADSP_PHC_ADNI_T1_1.0_MetaData_05Aug2024.csv';
adni_medhist_filename = 'MEDHIST_05Aug2024.csv';
adni_modhach_filename = 'MODHACH_05Aug2024.csv';
% adai_filename = 'ADAI-ADAI.csv';

match_path = '/home/range1-raid1/labounek/data-on-porto/ADNI/ADNI_ADAI_match';
dmri_filename = 'idaSearch_8_05_2024.csv';
adai_filename = 'ADAI-ADAI.csv';

ida = readtable(fullfile(match_path,dmri_filename),'PreserveVariableNames',1);
dmri_pos = strcmp(table2cell(ida(:,'Modality')),'DTI') & strcmp(table2cell(ida(:,'Description')),'Axial MB DTI');
fmri_pos = strcmp(table2cell(ida(:,'Modality')),'fMRI') ; % & strcmp(table2cell(ida(:,'Description')),'Axial MB DTI')
dmri = ida(dmri_pos,:);
fmri = ida(fmri_pos,:);

tbl = readtable(fullfile(csv_path,csv_filename),'PreserveVariableNames',1);
adni_metadata = readtable(fullfile(csv_path,adni_metadata_filename),'PreserveVariableNames',1);
adni_medhist = readtable(fullfile(csv_path,adni_medhist_filename),'PreserveVariableNames',1);
adni_modhach = readtable(fullfile(csv_path,adni_modhach_filename),'PreserveVariableNames',1);

% bl_pos = strcmp(table2cell(tbl(:,'VISCODE')),'bl');
adni3_pos = strcmp(table2cell(tbl(:,'COLPROT')),'ADNI3');


% tbl_bl = tbl(bl_pos,:);
tbl_adni3 = tbl(adni3_pos,:);


for sbid = 1:size(dmri,1)
    sub = table2cell(dmri(sbid,'Subject ID'));
    dmri_date = table2cell(dmri(sbid,'Study Date'));
    
    subpos = strcmp(table2cell(tbl_adni3(:,'PTID')),sub);
    tbl_adni3_date = table2cell(tbl_adni3(subpos,'EXAMDATE'));
    
    if ~isempty(tbl_adni3_date)
        tbl_sub = tbl_adni3(subpos,:);

        for dateid = 1:size(tbl_adni3_date,1)
            NumDays(dateid,1) = abs( daysdif( tbl_adni3_date{dateid,1} , dmri_date{1,1} ) );
        end
        if min(NumDays) <= time_gap
            tbl_dmri(sbid,:) = table2cell(tbl_sub(NumDays<=time_gap,:));
        end
        clear NumDays
    end
end

tbl_dmri_names = tbl.Properties.VariableNames;
dmri_names = dmri.Properties.VariableNames;



%%
sublist = unique(table2cell(dmri(:,'Subject ID')));

dfmri_all = [];
tbl_dfmri_all = cell(0,0);
dfmri_v1 = [];
tbl_dfmri_v1 = cell(0,0);
ind2 = 1;
monitoring_time = [];
monitoring_sessions = [];
for ind = 1:size(sublist,1)
    if ind == 22
        disp('yes')
    end
    sb_dmri = dmri( strcmp( table2cell(dmri(:,'Subject ID')) , sublist{ind,1} ), : );
    sb_tbl_dmri = tbl_dmri( strcmp( table2cell(dmri(:,'Subject ID')) , sublist{ind,1} ), : );
    sb_fmri = fmri( strcmp( table2cell(fmri(:,'Subject ID')) , sublist{ind,1} ), : );
    
    dmrid2 = 1;
    match = 0;
    for dmrid = 1:size(sb_dmri,1)
        pos = strcmp(table2cell(sb_fmri(:,'Visit')),table2cell(sb_dmri(dmrid,'Visit')));
        if sum(pos) > 0
            dfmri(dmrid2,:) = sb_dmri(dmrid,:);
            tbl_dfmri(dmrid2,:) = sb_tbl_dmri(dmrid,:);
            match = match + 1;
            dmrid2 = dmrid2 + 1;
        end
    end    
    
    if match > 1
        dfmri_all = [dfmri_all; dfmri];
        tbl_dfmri_all = [tbl_dfmri_all; tbl_dfmri];

        dfmri_v1 = [dfmri_v1; dfmri(1,:)];
        tbl_dfmri_v1(ind2,:) = tbl_dfmri(1,:);
        
        if size(dfmri,1) > 1
            dt_age = cell2mat(table2cell(dfmri(:,'Age')));
            monitoring_time(ind2,1) = sum(diff(dt_age));
            monitoring_sessions(ind2,1) = size(dt_age,1);
        else
            monitoring_time(ind2,1) = 0;
            monitoring_sessions(ind2,1) = 1;
        end
        
        ind2 = ind2 + 1;
    end
    if match > 0
        clear dfmri tbl_dfmri
    end
end
monitoring_time = round(monitoring_time);

stat_monitoring_time = [mean(monitoring_time) std(monitoring_time)];
stat_monitoring_sessions(1,1) = sum(monitoring_sessions==2);
stat_monitoring_sessions(1,2) = sum(monitoring_sessions==3);
stat_monitoring_sessions(1,3) = sum(monitoring_sessions==4);
stat_monitoring_sessions(1,4) = sum(monitoring_sessions==5);
stat_monitoring_sessions(2,:) = 100 * stat_monitoring_sessions(1,:) / size(monitoring_sessions,1);

stat_sex(1,1) = sum(strcmp(table2cell(dfmri_v1(:,'Sex')),'F'));
stat_sex(1,2) = sum(strcmp(table2cell(dfmri_v1(:,'Sex')),'M'));
stat_sex(2,:) = 100 * stat_sex(1,:) / size(monitoring_sessions,1);

stat_age = [ mean(cell2mat(table2cell(dfmri_v1(:,'Age')))) std(cell2mat(table2cell(dfmri_v1(:,'Age')))) ];