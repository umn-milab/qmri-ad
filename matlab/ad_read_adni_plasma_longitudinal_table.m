clear all;
close all;
% clc;

% sci='sci+mci';
sci='sci+cn';

time_gap = 75;

age_max_limit = 82;

csv_path = '/home/range1-raid1/labounek/data-on-porto/ADNI/StudyData';
save_path = '/home/range1-raid1/labounek/data-on-porto/ADAI/HeartDataset';
csv_filename = 'ADNIMERGE_29Jan2026.csv';
plasma_filename = 'UPENN_PLASMA_FUJIREBIO_QUANTERIX_27Jan2026.csv';
adni_metadata_filename = 'ADSP_PHC_ADNI_T1_1.0_MetaData_29Jan2026.csv';
adni_medhist_filename = 'MEDHIST_29Jan2026.csv';
adni_modhach_filename = 'MODHACH_29Jan2026.csv';
% adni_labdata_filename = 'All_Subjects_LABDATA_08Jul2025.csv';
adni_labdata_filename = 'All_Subjects_My_Table_29Jan2026.csv';
adni_vitals_filename = 'VITALS_29Jan2026.csv';



tbl = readtable(fullfile(csv_path,csv_filename),'PreserveVariableNames',1);
plasma = readtable(fullfile(csv_path,plasma_filename),'PreserveVariableNames',1);
adni_metadata = readtable(fullfile(csv_path,adni_metadata_filename),'PreserveVariableNames',1);
adni_medhist = readtable(fullfile(csv_path,adni_medhist_filename),'PreserveVariableNames',1);
adni_modhach = readtable(fullfile(csv_path,adni_modhach_filename),'PreserveVariableNames',1);
adni_labdata = readtable(fullfile(csv_path,adni_labdata_filename),'PreserveVariableNames',1);
adni_vitals = readtable(fullfile(csv_path,adni_vitals_filename),'PreserveVariableNames',1);

ptid = table2cell(unique(plasma(:,'PTID')));

for ind = 1:size(plasma,1)
    sub_ptid = table2cell(plasma(ind,'PTID'));
    sub_viscode = table2cell(plasma(ind,'VISCODE'));
    sub_rid = table2cell(plasma(ind,'RID'));
    
    tbl_subvis_pos = strcmp(table2cell(tbl(:,'PTID')),sub_ptid) & strcmp(table2cell(tbl(:,'VISCODE')),sub_viscode);
    if sum(tbl_subvis_pos)==0
        sub_viscode = table2cell(plasma(ind,'VISCODE2'));
        tbl_subvis_pos = strcmp(table2cell(tbl(:,'PTID')),sub_ptid) & strcmp(table2cell(tbl(:,'VISCODE')),sub_viscode);
    elseif sum(tbl_subvis_pos)>1
        disp(ind)
        exit
    end
    
    mtdt_subvis_pos = cell2mat(table2cell(adni_metadata(:,'RID')))==cell2mat(sub_rid) & strcmp(table2cell(adni_metadata(:,'LONI_VISCODE2')),sub_viscode);
    if sum(mtdt_subvis_pos)==0
        mtdt_subvis_pos = cell2mat(table2cell(adni_metadata(:,'RID')))==cell2mat(sub_rid) & strcmp(table2cell(adni_metadata(:,'COG_VISCODE2')),sub_viscode);
    end
    
    labdata_subvis_pos = strcmp(table2cell(adni_labdata(:,'subject_id')),sub_ptid); % & strcmp(table2cell(adni_labdata(:,'VISCODE')),sub_viscode);
    
    if sum(tbl_subvis_pos) ~= 0
        adnimerge (ind,:) = tbl(tbl_subvis_pos,:);
    else
        tmp = tbl(strcmp(table2cell(tbl(:,'PTID')),sub_ptid),:);
   
        adnimerge(ind,'PTID') = sub_ptid;
        adnimerge(ind,'VISCODE') = sub_viscode;
        adnimerge(ind,'RID') = sub_rid;
        adnimerge(ind,'SITE') = {str2double(sub_ptid{1,1}(1:3))};
        if ~isempty(tmp)
            adnimerge(ind,'ORIGPROT') = tmp(1,'ORIGPROT');
            
            adnimerge(ind,find(strcmp(tmp.Properties.VariableNames,'DX_bl')==1):find(strcmp(tmp.Properties.VariableNames,'APOE4')==1)) = ...
                tmp(1,find(strcmp(tmp.Properties.VariableNames,'DX_bl')==1):find(strcmp(tmp.Properties.VariableNames,'APOE4')==1));
            adnimerge(ind,find(strcmp(tmp.Properties.VariableNames,'CDRSB_bl')==1):find(strcmp(tmp.Properties.VariableNames,'Month_bl')==1)) = ...
                tmp(1,find(strcmp(tmp.Properties.VariableNames,'CDRSB_bl')==1):find(strcmp(tmp.Properties.VariableNames,'Month_bl')==1));
        else
            adnimerge(ind,'AGE') = {NaN};
            adnimerge(ind,'PTEDUCAT') = {NaN};
            adnimerge(ind,'APOE4') = {NaN};
            adnimerge(ind,find(strcmp(tmp.Properties.VariableNames,'CDRSB_bl')==1):find(strcmp(tmp.Properties.VariableNames,'mPACCtrailsB_bl')==1)) = {NaN};
            adnimerge(ind,find(strcmp(tmp.Properties.VariableNames,'IMAGEUID_bl')==1):find(strcmp(tmp.Properties.VariableNames,'Month_bl')==1)) = {NaN};
            
            adnimerge(ind,'COLPROT') = plasma(ind,'PHASE');
        end
        
        adnimerge(ind,find(strcmp(tmp.Properties.VariableNames,'FDG')==1):find(strcmp(tmp.Properties.VariableNames,'EcogSPTotal')==1)) = {NaN};
        adnimerge(ind,find(strcmp(tmp.Properties.VariableNames,'IMAGEUID')==1):find(strcmp(tmp.Properties.VariableNames,'ICV')==1)) = {NaN};
        adnimerge(ind,find(strcmp(tmp.Properties.VariableNames,'mPACCdigit')==1):find(strcmp(tmp.Properties.VariableNames,'mPACCtrailsB')==1)) = {NaN};
        if strcmp(sub_viscode,'bl')
            m = 0;
        else
            m = str2double(sub_viscode{1,1}(2:end));
        end
        adnimerge(ind,'Month') = {m};
        adnimerge(ind,'M') = {m};
        
        adnimerge(ind,'COLPROT') = plasma(ind,'PHASE');
        if isempty(cell2mat(table2cell(adnimerge(ind,'ORIGPROT')))) && strcmp(table2cell(adnimerge(ind,'VISCODE')),'bl')
            adnimerge(ind,'ORIGPROT') = plasma(ind,'PHASE');
        end
    end
    
    if sum(mtdt_subvis_pos) ~= 0
        mtdt(ind,:) = adni_metadata(mtdt_subvis_pos,find(strcmp(adni_metadata.Properties.VariableNames,'MEM')==1):find(strcmp(adni_metadata.Properties.VariableNames,'APOE3COUNT')==1));
    else
        mtdt(ind,:) = {NaN};
    end
    
    if sum(labdata_subvis_pos) ~= 0
        tmp = adni_labdata(labdata_subvis_pos,:);
        tmp = tmp(~isnan(cell2mat(table2cell(tmp(:,'RCT392')))),:);
        tmp_pos = find(cell2mat(table2cell(tmp(:,'RCT392')))==max(cell2mat(table2cell(tmp(:,'RCT392')))));
        if ~isempty(tmp_pos)
            tmp = tmp(tmp_pos,:);

            SCr = cell2mat(table2cell(tmp(1,'RCT392')));
            if isnan(SCr)
                egfr = NaN;
            else
                if strcmp(table2cell(adnimerge(ind,'PTGENDER')),'Female')
                    c = 1.012;
                    kappa = 0.7;
                    alpha = -0.248;
                else
                    c = 1;
                    kappa = 0.9;
                    alpha = -0.207;
                end
                ag = cell2mat(table2cell(adnimerge(ind,'AGE')));
                if ~strcmp(table2cell(tmp(1,'visit')),'sc') && ~strcmp(table2cell(tmp(1,'visit')),'bl') && ~strcmp(table2cell(tmp(1,'visit')),'nv')
                    disp(tmp)
                    disp('Age needs to be adjusted to correctly estimate eGFR')
                end

                egfr = 142 * min([SCr/kappa, 1])^alpha * max([SCr/kappa, 1])^-1.200 * 0.9938^ag * c;
            end
            egfr = array2table(egfr,'VariableNames',{'eGFR'});

            labdata(ind,:) = [tmp(1,'RCT392') egfr];
        else
            labdata(ind,:) = {NaN};
        end
    else
        labdata(ind,:) = {NaN};
    end

end

adni = [plasma( :, find(strcmp(plasma.Properties.VariableNames,'Primary')==1):find(strcmp(plasma.Properties.VariableNames,'GFAP_Q')==1) ) ...
    labdata adnimerge mtdt];
writetable(adni,fullfile(save_path,'adni_plasma_table_longitudinal_20260129.csv'))