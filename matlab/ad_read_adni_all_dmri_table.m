clear all;
close all; clc;

time_gap = 75;

csv_path = '/home/labounek/data/ADNI/StudyData';
brightfocus_path = '/home/labounek/data/ADNI/BrightFocus';
dmri_filename = 'idaSearch_9_17_2025.csv';

csv_filename = 'ADNIMERGE_07Jul2025.csv';
plasma_filename = 'UPENN_PLASMA_FUJIREBIO_QUANTERIX_30Jun2025.csv';
adni_metadata_filename = 'ADSP_PHC_ADNI_T1_1.0_MetaData_05Aug2024.csv';
adni_medhist_filename = 'MEDHIST_07Jul2025.csv';
adni_modhach_filename = 'MODHACH_07Jul2025.csv';
adni_labdata_filename = 'All_Subjects_LABDATA_08Jul2025.csv';
adni_vitals_filename = 'VITALS_08Sep2025.csv';

ida = readtable(fullfile(brightfocus_path,dmri_filename),'PreserveVariableNames',1);
dmri_pos = ~( ...
    contains(table2cell(ida(:,'Description')),'Localizer') | ...
    contains(table2cell(ida(:,'Description')),'Average') | ...
    contains(table2cell(ida(:,'Description')),'Apparent') | ...
    contains(table2cell(ida(:,'Description')),'FA') | ...
    contains(table2cell(ida(:,'Description')),'Fractional') | ...
    contains(table2cell(ida(:,'Description')),'b0') | ...
    contains(table2cell(ida(:,'Description')),'B0') | ...
    contains(table2cell(ida(:,'Description')),'TRACE') | ...
    contains(table2cell(ida(:,'Description')),'HighResHippo') | ...
    contains(table2cell(ida(:,'Description')),'Trace') | ...
    contains(table2cell(ida(:,'Description')),'ADC') | ...
    contains(table2cell(ida(:,'Imaging Protocol')),'Directions=0.0') | ...
    contains(table2cell(ida(:,'Imaging Protocol')),'Directions=6.0') ...
    );
% dmri_pos = strcmp(table2cell(tbl(:,'Modality')),'DTI') & strcmp(table2cell(tbl(:,'Description')),'Axial MB DTI');
dmri = ida(dmri_pos,:);

tbl = readtable(fullfile(csv_path,csv_filename),'PreserveVariableNames',1);
plasma = readtable(fullfile(csv_path,plasma_filename),'PreserveVariableNames',1);
adni_metadata = readtable(fullfile(csv_path,adni_metadata_filename),'PreserveVariableNames',1);
adni_medhist = readtable(fullfile(csv_path,adni_medhist_filename),'PreserveVariableNames',1);
adni_modhach = readtable(fullfile(csv_path,adni_modhach_filename),'PreserveVariableNames',1);
adni_labdata = readtable(fullfile(csv_path,adni_labdata_filename),'PreserveVariableNames',1);
adni_vitals = readtable(fullfile(csv_path,adni_vitals_filename),'PreserveVariableNames',1);

females = strcmp(table2cell(dmri(:,'Sex')),'F');
age = cell2mat(table2cell(dmri(:,'Age')));
weight = cell2mat(table2cell(dmri(:,'Weight')));
grp = table2cell(dmri(:,'Research Group'));
visit = table2cell(dmri(:,'Visit'));
imaging_protocol = table2cell(dmri(:,'Imaging Protocol'));
phase = table2cell(dmri(:,'Phase'));

subid = table2cell(dmri(:,'Subject ID'));

sub = unique(subid);

tbl0 = cell(size(sub,1),size(dmri,2));
tbl0(:,1) = sub;
tbl0_grp_match = zeros(size(sub,1),1);
for ind = 1:size(sub,1)  
    
    if strcmp(sub(ind,1),'002_S_6652')
        disp('yes')
    end
    
    ps = strcmp(subid,sub{ind,1});
    
    sub_age = age(ps==1);
    
    tbl0_nvisits(ind,1) = sum(ps);
    if sum(ps) > 1
        tbl0_distvisit(ind,1) = 12*median(abs(diff(sort(sub_age))));
    else
        tbl0_distvisit(ind,1) = NaN;
    end
    
    sub_grp = grp(ps,1);
    sub_grp_match = strcmp(sub_grp,sub_grp(1,1));
    
    if sum(sub_grp_match) == size(sub_grp_match,1)
        tbl0_grp_match(ind,1) = 1;
    end
    
    psage = age;
    psage(ps==0) = 350;
    
    ps = find(psage==min(psage),1);
    
    tbl0(ind,2) = table2cell(dmri(ps,'Project'));
    tbl0(ind,3) = table2cell(dmri(ps,'Phase'));
    tbl0(ind,4) = table2cell(dmri(ps,'Sex'));
    tbl0(ind,5) = table2cell(dmri(ps,'Weight'));
    tbl0(ind,6) = table2cell(dmri(ps,'Research Group'));
    tbl0(ind,7) = table2cell(dmri(ps,'Visit'));
    tbl0(ind,8) = table2cell(dmri(ps,'Study Date'));
    tbl0(ind,9) = table2cell(dmri(ps,'Archive Date'));
    tbl0(ind,10) = table2cell(dmri(ps,'Age'));
    tbl0(ind,11) = table2cell(dmri(ps,'Modality'));
    tbl0(ind,12) = table2cell(dmri(ps,'Description'));
    tbl0(ind,13) = table2cell(dmri(ps,'Imaging Protocol'));
    tbl0(ind,14) = table2cell(dmri(ps,'Image ID'));
end

tbl0_females = strcmp(tbl0(:,4),'F');
tbl0_age = cell2mat(tbl0(:,10));
tbl0_weight = cell2mat(tbl0(:,5));
tbl0_grp = tbl0(:,6);
tbl0_visit = tbl0(:,7);
tbl0_imaging_protocol = tbl0(:,13);
tbl0_phase = tbl0(:,3);

stats0_age = [mean(tbl0_age) std(tbl0_age)];
stats0_grp = {'CN' 'SMC' 'MCI' 'AD'};
stats0_grp(2,:) = num2cell([ sum(strcmp(tbl0_grp,'CN')) sum(strcmp(tbl0_grp,'SMC')) sum(contains(tbl0_grp,'MCI')) sum(strcmp(tbl0_grp,'AD')) ]);
stats0_grp(3,:) = num2cell(100*[ sum(strcmp(tbl0_grp,'CN'))/size(tbl0_grp,1) sum(strcmp(tbl0_grp,'SMC'))/size(tbl0_grp,1) sum(contains(tbl0_grp,'MCI'))/size(tbl0_grp,1) sum(strcmp(tbl0_grp,'AD'))/size(tbl0_grp,1) ]);

%% Data digging and matching to dMRI scan visits
for sbid = 1:size(dmri,1)
    sub = table2cell(dmri(sbid,'Subject ID'));
    dmri_date = table2cell(dmri(sbid,'Study Date'));
    
    subpos = strcmp(table2cell(tbl(:,'PTID')),sub);
    tbl_date = table2cell(tbl(subpos,'EXAMDATE'));
    
    if ~isempty(tbl_date)
        tbl_sub = tbl(subpos,:);

        for dateid = 1:size(tbl_date,1)
            NumDays(dateid,1) = abs( daysdif( tbl_date{dateid,1} , dmri_date{1,1} ) );
        end
        if min(NumDays) <= time_gap
            tbl_dmri(sbid,:) = table2cell(tbl_sub(NumDays<=time_gap,:));
        end
        clear NumDays
    end
end


%% Data visualization
h(1).fig = figure(1);
set(h(1).fig,'Position',[50 50 650 950])

subplot(3,2,1)
histogram(tbl0_age,15)
ylabel('Counts')
xlabel('Age [years]')
set(gca,'FontSize',14,'LineWidth',2)

subplot(3,2,2)
histogram(tbl0_weight,25)
xlabel('Weight [kg]')
xlim([40 150])
set(gca,'FontSize',14,'LineWidth',2,...
    'XTick',(0:25:200)-2,'XTickLabel',0:25:200)

subplot(3,2,3)
histogram(tbl0_nvisits,18)
ylabel('Counts')
xlabel('Number of visits')
xlim([0.5 9.5])
set(gca,'FontSize',14,'LineWidth',2,...
    'XTick',[1.2 3 4.9 6.7 8.5 11],'XTickLabel',1:2:11)

subplot(3,2,4)
histogram(tbl0_distvisit,'BinEdges',1:6:100)
xlabel('Time between visits [months]')
xlim([0 50])
set(gca,'FontSize',14,'LineWidth',2,...
    'XTick',(6:6:150)-2,'XTickLabel',6:6:150)