clear all;
close all; clc;

csv_path = '/home/range1-raid1/labounek/data-on-porto/ADNI/StudyData';
csv_filename = 'ADNIMERGE_05Aug2024.csv';
% adai_filename = 'ADAI-ADAI.csv';

pet_path = '/home/range1-raid1/labounek/data-on-porto/ADNI/PET';
pet_filename = 'PET_idaSearch_9_24_2024.csv';

tbl = readtable(fullfile(csv_path,csv_filename),'PreserveVariableNames',1);

pet = readtable(fullfile(pet_path,pet_filename),'PreserveVariableNames',1);

bl_pos = strcmp(table2cell(tbl(:,'VISCODE')),'bl');
adni3_pos = strcmp(table2cell(tbl(:,'COLPROT')),'ADNI3');
% dmri_pos = strcmp(table2cell(tbl(:,'Modality')),'DTI') & strcmp(table2cell(tbl(:,'Description')),'Axial MB DTI');

tbl_bl = tbl(bl_pos,:);
tbl_adni3 = tbl(adni3_pos,:);

adni3_sub = cell2mat(table2cell(tbl_adni3(:,'RID')));
adni3_sub_unique = unique(adni3_sub);

for ind = 1:size(adni3_sub_unique,1)
    x = find(adni3_sub==adni3_sub_unique(ind,1),1,'first');
    tbl_adni3_bl(ind,:) = tbl_adni3(x,:);
end

tbl_stat_bl = make_tbl_stat(tbl_bl);
tbl_stat_adni3 = make_tbl_stat(tbl_adni3_bl);

[tbl_pet, sub_ai] = filter_pet(pet,tbl_bl);

function [tbl_pet, sub_ai] = filter_pet(pet,tbl)
    race = table2cell(tbl(:,'PTRACCAT'));
    race_ai = strcmp(race,'Am Indian/Alaskan');
    sub_ai = table2cell(tbl(race_ai,'PTID'));
    
    phase = table2cell(pet(:,'Phase'));
    phase_adni3 = strcmp(phase,'ADNI 3');
    sub_adni3 = unique(table2cell(pet(phase_adni3,'Subject ID')));
    sub_adni3_count = size(sub_adni3,1);
    
    description_adni3 = table2cell(pet(phase_adni3,'Description'));
    description_adni3_unique = unique(description_adni3);
    
    adni3_av45 = sum(contains(description_adni3,'AV45') | ...
        contains(description_adni3,'AV-45') | ...
        contains(description_adni3,'FLORBETAPIR') | ...
        contains(description_adni3,'lorbetapir') );
    adni3_fbb = sum(contains(description_adni3,'FBB') | contains(description_adni3,'florbetaben') );
    adni3_fdg = sum(contains(description_adni3,'FDG'));
    adni3_tau = sum(contains(description_adni3,'Tau') | ...
        contains(description_adni3,'TAU') | ...
        contains(description_adni3,'Flortau') );
        
    
    adni3_count_diff = size(description_adni3,1) - (adni3_av45 + adni3_fbb + adni3_fdg + adni3_tau);
    
    tmp = description_adni3( ~contains(description_adni3,'AV45') & ...
        ~contains(description_adni3,'AV-45') & ...
        ~contains(description_adni3,'FLORBETAPIR') & ...
        ~contains(description_adni3,'lorbetapir') & ...
        ~contains(description_adni3,'FBB') & ...
        ~contains(description_adni3,'florbetaben') & ...
        ~contains(description_adni3,'FDG') & ...
        ~contains(description_adni3,'Tau') & ...
        ~contains(description_adni3,'TAU') & ...
        ~contains(description_adni3,'Flortau') , 1);
    %         ~contains(description_adni3,'AV-1451') &
        
    
    rw = 1;
    for ind = 1:size(sub_ai,1)
        pet_ai_pos = strcmp( table2cell(pet(:,'Subject ID')) , sub_ai{ind,1}  );
        if sum(pet_ai_pos)>0
            tbl_pet(rw:rw+sum(pet_ai_pos)-1,:) = pet( pet_ai_pos, :);
            rw = rw + sum(pet_ai_pos);
        end
    end
end


function tbl_stat = make_tbl_stat(tbl_bl)

    females = strcmp(table2cell(tbl_bl(:,'PTGENDER')),'Female');
    males = strcmp(table2cell(tbl_bl(:,'PTGENDER')),'Male');

    age = cell2mat(table2cell(tbl_bl(:,'AGE')));
    race = table2cell(tbl_bl(:,'PTRACCAT'));
    ethnicity = table2cell(tbl_bl(:,'PTETHCAT'));
    grp = table2cell(tbl_bl(:,'DX_bl'));
    protocol = table2cell(tbl_bl(:,'COLPROT'));
    apoe4 = cell2mat(table2cell(tbl_bl(:,'APOE4')));

    age_stat(1,1) = mean(age,'omitnan');
    age_stat(1,2) = std(age,0,'omitnan');
    age_stat(2,1) = mean(age(females),'omitnan');
    age_stat(2,2) = std(age(females),0,'omitnan');
    age_stat(3,1) = mean(age(males),'omitnan');
    age_stat(3,2) = std(age(males),0,'omitnan');

    tbl_stat{1,2} = 'All';
    tbl_stat{1,3} = 'Females';
    tbl_stat{1,4} = 'Males';
    tbl_stat{2,1} = 'Number of subjects';
    tbl_stat{3,1} = 'Age [y.o.]';
    tbl_stat{4,1} = 'Race';
    tbl_stat{5,1} = 'Am Indian/Alaskan';
    tbl_stat{6,1} = 'Asian';
    tbl_stat{7,1} = 'Black';
    tbl_stat{8,1} = 'Hawaiian/Other PI';
    tbl_stat{9,1} = 'White';
    tbl_stat{10,1} = 'More than one';
    tbl_stat{11,1} = 'Unknown';
    tbl_stat{12,1} = 'Ethnicity';
    tbl_stat{13,1} = 'Hisp/Latino';
    tbl_stat{14,1} = 'Not Hisp/Latino';
    tbl_stat{15,1} = 'Unknown';
    tbl_stat{16,1} = 'Group (baseline)';
    tbl_stat{17,1} = 'AD';
    tbl_stat{18,1} = 'CN';
    tbl_stat{19,1} = 'EMCI';
    tbl_stat{20,1} = 'LMCI';
    tbl_stat{21,1} = 'SMC';
    tbl_stat{22,1} = 'No Class';
    tbl_stat{23,1} = 'ADNI protocol (baseline)';
    tbl_stat{24,1} = 'ADNI1';
    tbl_stat{25,1} = 'ADNI2';
    tbl_stat{26,1} = 'ADNIGO';
    tbl_stat{27,1} = 'ADNI3';
    tbl_stat{28,1} = 'APOE4';
    tbl_stat{29,1} = 0;
    tbl_stat{30,1} = 1;
    tbl_stat{31,1} = 2;
    tbl_stat{32,1} = 'No Class';


    nsub = size(tbl_bl,1);
    nfemales = sum(females);
    nmales = sum(males);

    race_ai = strcmp(race,'Am Indian/Alaskan');
    race_asian = strcmp(race,'Asian');
    race_black = strcmp(race,'Black');
    race_hawai = strcmp(race,'Hawaiian/Other PI');
    race_white = strcmp(race,'White');
    race_more = strcmp(race,'More than one');
    race_unknown = strcmp(race,'Unknown');

    ethnicity_hisp = strcmp(ethnicity,'Hisp/Latino');
    ethnicity_nothisp = strcmp(ethnicity,'Not Hisp/Latino');
    ethnicity_unknown = strcmp(ethnicity,'Unknown');

    grp_ad = strcmp(grp,'AD');
    grp_cn = strcmp(grp,'CN');
    grp_emci = strcmp(grp,'EMCI');
    grp_lmci = strcmp(grp,'LMCI');
    grp_smc = strcmp(grp,'SMC');
    grp_noclass = strcmp(grp,'');

    protocol_adni1 = strcmp(protocol,'ADNI1');
    protocol_adni2 = strcmp(protocol,'ADNI2');
    protocol_adnigo = strcmp(protocol,'ADNIGO');
    protocol_adni3 = strcmp(protocol,'ADNI3');

    apoe4_0 = apoe4 == 0;
    apoe4_1 = apoe4 == 1;
    apoe4_2 = apoe4 == 2;
    apoe4_noclass = isnan(apoe4);

    tbl_stat{2,2} = nsub;
    tbl_stat{2,3} = [num2str(nfemales) ' (' num2str(round(1000*nfemales/nsub)/10) '%)'];
    tbl_stat{2,4} = [num2str(nmales) ' (' num2str(round(1000*nmales/nsub)/10) '%)'];

    for ind = 1:3
        tbl_stat{3,ind+1} = [ num2str(age_stat(ind,1),'%.1f') '±' num2str(age_stat(ind,2),'%.1f') ];
    end


    tbl_stat{5,2} = [num2str(sum(race_ai)) ' (' num2str(100*sum(race_ai)/nsub,'%.1f') '%)'];
    tbl_stat{5,3} = [num2str(sum(race_ai & females)) ' (' num2str(100*sum(race_ai & females)/nfemales,'%.1f') '%)'];
    tbl_stat{5,4} = [num2str(sum(race_ai & males)) ' (' num2str(100*sum(race_ai & males)/nmales,'%.1f') '%)'];

    tbl_stat{6,2} = [num2str(sum(race_asian)) ' (' num2str(100*sum(race_asian)/nsub,'%.1f') '%)'];
    tbl_stat{6,3} = [num2str(sum(race_asian & females)) ' (' num2str(100*sum(race_asian & females)/nfemales,'%.1f') '%)'];
    tbl_stat{6,4} = [num2str(sum(race_asian & males)) ' (' num2str(100*sum(race_asian & males)/nmales,'%.1f') '%)'];

    tbl_stat{7,2} = [num2str(sum(race_black)) ' (' num2str(100*sum(race_black)/nsub,'%.1f') '%)'];
    tbl_stat{7,3} = [num2str(sum(race_black & females)) ' (' num2str(100*sum(race_black & females)/nfemales,'%.1f') '%)'];
    tbl_stat{7,4} = [num2str(sum(race_black & males)) ' (' num2str(100*sum(race_black & males)/nmales,'%.1f') '%)'];

    tbl_stat{8,2} = [num2str(sum(race_hawai)) ' (' num2str(100*sum(race_hawai)/nsub,'%.1f') '%)'];
    tbl_stat{8,3} = [num2str(sum(race_hawai & females)) ' (' num2str(100*sum(race_hawai & females)/nfemales,'%.1f') '%)'];
    tbl_stat{8,4} = [num2str(sum(race_hawai & males)) ' (' num2str(100*sum(race_hawai & males)/nmales,'%.1f') '%)'];

    tbl_stat{9,2} = [num2str(sum(race_white)) ' (' num2str(100*sum(race_white)/nsub,'%.1f') '%)'];
    tbl_stat{9,3} = [num2str(sum(race_white & females)) ' (' num2str(100*sum(race_white & females)/nfemales,'%.1f') '%)'];
    tbl_stat{9,4} = [num2str(sum(race_white & males)) ' (' num2str(100*sum(race_white & males)/nmales,'%.1f') '%)'];

    tbl_stat{10,2} = [num2str(sum(race_more)) ' (' num2str(100*sum(race_more)/nsub,'%.1f') '%)'];
    tbl_stat{10,3} = [num2str(sum(race_more & females)) ' (' num2str(100*sum(race_more & females)/nfemales,'%.1f') '%)'];
    tbl_stat{10,4} = [num2str(sum(race_more & males)) ' (' num2str(100*sum(race_more & males)/nmales,'%.1f') '%)'];

    tbl_stat{11,2} = [num2str(sum(race_unknown)) ' (' num2str(100*sum(race_unknown)/nsub,'%.1f') '%)'];
    tbl_stat{11,3} = [num2str(sum(race_unknown & females)) ' (' num2str(100*sum(race_unknown & females)/nfemales,'%.1f') '%)'];
    tbl_stat{11,4} = [num2str(sum(race_unknown & males)) ' (' num2str(100*sum(race_unknown & males)/nmales,'%.1f') '%)'];

    tbl_stat{13,2} = [num2str(sum(ethnicity_hisp)) ' (' num2str(100*sum(ethnicity_hisp)/nsub,'%.1f') '%)'];
    tbl_stat{13,3} = [num2str(sum(ethnicity_hisp & females)) ' (' num2str(100*sum(ethnicity_hisp & females)/nfemales,'%.1f') '%)'];
    tbl_stat{13,4} = [num2str(sum(ethnicity_hisp & males)) ' (' num2str(100*sum(ethnicity_hisp & males)/nmales,'%.1f') '%)'];

    tbl_stat{14,2} = [num2str(sum(ethnicity_nothisp)) ' (' num2str(100*sum(ethnicity_nothisp)/nsub,'%.1f') '%)'];
    tbl_stat{14,3} = [num2str(sum(ethnicity_nothisp & females)) ' (' num2str(100*sum(ethnicity_nothisp & females)/nfemales,'%.1f') '%)'];
    tbl_stat{14,4} = [num2str(sum(ethnicity_nothisp & males)) ' (' num2str(100*sum(ethnicity_nothisp & males)/nmales,'%.1f') '%)'];

    tbl_stat{15,2} = [num2str(sum(ethnicity_unknown)) ' (' num2str(100*sum(ethnicity_unknown)/nsub,'%.1f') '%)'];
    tbl_stat{15,3} = [num2str(sum(ethnicity_unknown & females)) ' (' num2str(100*sum(ethnicity_unknown & females)/nfemales,'%.1f') '%)'];
    tbl_stat{15,4} = [num2str(sum(ethnicity_unknown & males)) ' (' num2str(100*sum(ethnicity_unknown & males)/nmales,'%.1f') '%)'];

    tbl_stat{17,2} = [num2str(sum(grp_ad)) ' (' num2str(100*sum(grp_ad)/nsub,'%.1f') '%)'];
    tbl_stat{17,3} = [num2str(sum(grp_ad & females)) ' (' num2str(100*sum(grp_ad & females)/nfemales,'%.1f') '%)'];
    tbl_stat{17,4} = [num2str(sum(grp_ad & males)) ' (' num2str(100*sum(grp_ad & males)/nmales,'%.1f') '%)'];

    tbl_stat{18,2} = [num2str(sum(grp_cn)) ' (' num2str(100*sum(grp_cn)/nsub,'%.1f') '%)'];
    tbl_stat{18,3} = [num2str(sum(grp_cn & females)) ' (' num2str(100*sum(grp_cn & females)/nfemales,'%.1f') '%)'];
    tbl_stat{18,4} = [num2str(sum(grp_cn & males)) ' (' num2str(100*sum(grp_cn & males)/nmales,'%.1f') '%)'];

    tbl_stat{19,2} = [num2str(sum(grp_emci)) ' (' num2str(100*sum(grp_emci)/nsub,'%.1f') '%)'];
    tbl_stat{19,3} = [num2str(sum(grp_emci & females)) ' (' num2str(100*sum(grp_emci & females)/nfemales,'%.1f') '%)'];
    tbl_stat{19,4} = [num2str(sum(grp_emci & males)) ' (' num2str(100*sum(grp_emci & males)/nmales,'%.1f') '%)'];

    tbl_stat{20,2} = [num2str(sum(grp_lmci)) ' (' num2str(100*sum(grp_lmci)/nsub,'%.1f') '%)'];
    tbl_stat{20,3} = [num2str(sum(grp_lmci & females)) ' (' num2str(100*sum(grp_lmci & females)/nfemales,'%.1f') '%)'];
    tbl_stat{20,4} = [num2str(sum(grp_lmci & males)) ' (' num2str(100*sum(grp_lmci & males)/nmales,'%.1f') '%)'];

    tbl_stat{21,2} = [num2str(sum(grp_smc)) ' (' num2str(100*sum(grp_smc)/nsub,'%.1f') '%)'];
    tbl_stat{21,3} = [num2str(sum(grp_smc & females)) ' (' num2str(100*sum(grp_smc & females)/nfemales,'%.1f') '%)'];
    tbl_stat{21,4} = [num2str(sum(grp_smc & males)) ' (' num2str(100*sum(grp_smc & males)/nmales,'%.1f') '%)'];

    tbl_stat{22,2} = [num2str(sum(grp_noclass)) ' (' num2str(100*sum(grp_noclass)/nsub,'%.1f') '%)'];
    tbl_stat{22,3} = [num2str(sum(grp_noclass & females)) ' (' num2str(100*sum(grp_noclass & females)/nfemales,'%.1f') '%)'];
    tbl_stat{22,4} = [num2str(sum(grp_noclass & males)) ' (' num2str(100*sum(grp_noclass & males)/nmales,'%.1f') '%)'];

    tbl_stat{24,2} = [num2str(sum(protocol_adni1)) ' (' num2str(100*sum(protocol_adni1)/nsub,'%.1f') '%)'];
    tbl_stat{24,3} = [num2str(sum(protocol_adni1 & females)) ' (' num2str(100*sum(protocol_adni1 & females)/nfemales,'%.1f') '%)'];
    tbl_stat{24,4} = [num2str(sum(protocol_adni1 & males)) ' (' num2str(100*sum(protocol_adni1 & males)/nmales,'%.1f') '%)'];

    tbl_stat{25,2} = [num2str(sum(protocol_adni2)) ' (' num2str(100*sum(protocol_adni2)/nsub,'%.1f') '%)'];
    tbl_stat{25,3} = [num2str(sum(protocol_adni2 & females)) ' (' num2str(100*sum(protocol_adni2 & females)/nfemales,'%.1f') '%)'];
    tbl_stat{25,4} = [num2str(sum(protocol_adni2 & males)) ' (' num2str(100*sum(protocol_adni2 & males)/nmales,'%.1f') '%)'];

    tbl_stat{26,2} = [num2str(sum(protocol_adnigo)) ' (' num2str(100*sum(protocol_adnigo)/nsub,'%.1f') '%)'];
    tbl_stat{26,3} = [num2str(sum(protocol_adnigo & females)) ' (' num2str(100*sum(protocol_adnigo & females)/nfemales,'%.1f') '%)'];
    tbl_stat{26,4} = [num2str(sum(protocol_adnigo & males)) ' (' num2str(100*sum(protocol_adnigo & males)/nmales,'%.1f') '%)'];

    tbl_stat{27,2} = [num2str(sum(protocol_adni3)) ' (' num2str(100*sum(protocol_adni3)/nsub,'%.1f') '%)'];
    tbl_stat{27,3} = [num2str(sum(protocol_adni3 & females)) ' (' num2str(100*sum(protocol_adni3 & females)/nfemales,'%.1f') '%)'];
    tbl_stat{27,4} = [num2str(sum(protocol_adni3 & males)) ' (' num2str(100*sum(protocol_adni3 & males)/nmales,'%.1f') '%)'];

    tbl_stat{29,2} = [num2str(sum(apoe4_0)) ' (' num2str(100*sum(apoe4_0)/nsub,'%.1f') '%)'];
    tbl_stat{29,3} = [num2str(sum(apoe4_0 & females)) ' (' num2str(100*sum(apoe4_0 & females)/nfemales,'%.1f') '%)'];
    tbl_stat{29,4} = [num2str(sum(apoe4_0 & males)) ' (' num2str(100*sum(apoe4_0 & males)/nmales,'%.1f') '%)'];

    tbl_stat{30,2} = [num2str(sum(apoe4_1)) ' (' num2str(100*sum(apoe4_1)/nsub,'%.1f') '%)'];
    tbl_stat{30,3} = [num2str(sum(apoe4_1 & females)) ' (' num2str(100*sum(apoe4_1 & females)/nfemales,'%.1f') '%)'];
    tbl_stat{30,4} = [num2str(sum(apoe4_1 & males)) ' (' num2str(100*sum(apoe4_1 & males)/nmales,'%.1f') '%)'];

    tbl_stat{31,2} = [num2str(sum(apoe4_2)) ' (' num2str(100*sum(apoe4_2)/nsub,'%.1f') '%)'];
    tbl_stat{31,3} = [num2str(sum(apoe4_2 & females)) ' (' num2str(100*sum(apoe4_2 & females)/nfemales,'%.1f') '%)'];
    tbl_stat{31,4} = [num2str(sum(apoe4_2 & males)) ' (' num2str(100*sum(apoe4_2 & males)/nmales,'%.1f') '%)'];

    tbl_stat{32,2} = [num2str(sum(apoe4_noclass)) ' (' num2str(100*sum(apoe4_noclass)/nsub,'%.1f') '%)'];
    tbl_stat{32,3} = [num2str(sum(apoe4_noclass & females)) ' (' num2str(100*sum(apoe4_noclass & females)/nfemales,'%.1f') '%)'];
    tbl_stat{32,4} = [num2str(sum(apoe4_noclass & males)) ' (' num2str(100*sum(apoe4_noclass & males)/nmales,'%.1f') '%)'];
end