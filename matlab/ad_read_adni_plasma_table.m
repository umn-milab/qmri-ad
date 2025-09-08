clear all;
close all;
% clc;

% sci='sci+mci';
sci='sci+cn';

time_gap = 75;

age_max_limit = 82;

csv_path = '/home/range1-raid1/labounek/data-on-porto/ADNI/StudyData';
save_path = '/home/range1-raid1/labounek/data-on-porto/ADAI/HeartDataset';
csv_filename = 'ADNIMERGE_07Jul2025.csv';
plasma_filename = 'UPENN_PLASMA_FUJIREBIO_QUANTERIX_30Jun2025.csv';
adni_metadata_filename = 'ADSP_PHC_ADNI_T1_1.0_MetaData_05Aug2024.csv';
adni_medhist_filename = 'MEDHIST_07Jul2025.csv';
adni_modhach_filename = 'MODHACH_07Jul2025.csv';
adni_labdata_filename = 'All_Subjects_LABDATA_08Jul2025.csv';

tbl = readtable(fullfile(csv_path,csv_filename),'PreserveVariableNames',1);
plasma = readtable(fullfile(csv_path,plasma_filename),'PreserveVariableNames',1);
adni_metadata = readtable(fullfile(csv_path,adni_metadata_filename),'PreserveVariableNames',1);
adni_medhist = readtable(fullfile(csv_path,adni_medhist_filename),'PreserveVariableNames',1);
adni_modhach = readtable(fullfile(csv_path,adni_modhach_filename),'PreserveVariableNames',1);
adni_labdata = readtable(fullfile(csv_path,adni_labdata_filename),'PreserveVariableNames',1);

ptid = table2cell(unique(plasma(:,'PTID')));

sbid = 1;
for ind = 1:size(ptid,1)
    ptid_pos = strcmp( table2cell(plasma(:,'PTID')) , ptid{ind,1} ) ;
    
    plasma_pick = plasma(ptid_pos,:);
    plasma_pick = plasma_pick(1,:);
    
    tbl_pos =  strcmp( table2cell(tbl(:,'PTID')) , ptid{ind,1} ) & ...
        ( strcmp( table2cell(tbl(:,'VISCODE')) , table2cell(plasma_pick(:,'VISCODE2')) ) | ...
          strcmp( table2cell(tbl(:,'VISCODE')) , table2cell(plasma_pick(:,'VISCODE')) ) );
    
    if sum(tbl_pos) ~= 0
        adni(sbid,:) = [ tbl(tbl_pos,:) plasma_pick(1,{'pT217_F','AB42_F','AB40_F','AB42_AB40_F','pT217_AB42_F','NfL_Q','GFAP_Q'}) ];
        sbid = sbid + 1;
    end
end

%%
adni_names = adni.Properties.VariableNames;
count_irregular = 0;
for ind = 1:size(adni,1)
    rid = cell2mat(table2cell( adni(ind,strcmp(adni_names,'RID')) ));
    viscode = table2cell( adni(ind,strcmp(adni_names,'VISCODE')) );
    if strcmp(viscode,'bl')
        vis0 = 0;
    else
        vis0 = str2double(viscode{1,1}(2:end));
    end
    age(ind,1) = cell2mat(table2cell(adni(ind,'AGE'))) + vis0/12;
    
    %% METADATA DIGGING
    rid_pos = cell2mat(table2cell( adni_metadata( : , strcmp(adni_metadata.Properties.VariableNames,'RID')) )) == rid;
    viscode_pos = strcmp( table2cell( adni_metadata( : , strcmp(adni_metadata.Properties.VariableNames,'LONI_VISCODE2')) ), viscode);
    if sum(rid_pos & viscode_pos) == 0
        count_irregular = count_irregular + 1;
        if sum(rid_pos) == 1
            mtdt(ind,:) = adni_metadata(rid_pos,find(strcmp(adni_metadata.Properties.VariableNames,'MEM')==1):find(strcmp(adni_metadata.Properties.VariableNames,'APOE3COUNT')==1));
        elseif sum(rid_pos) > 1
            tmp = adni_metadata(rid_pos,find(strcmp(adni_metadata.Properties.VariableNames,'MEM')==1):find(strcmp(adni_metadata.Properties.VariableNames,'APOE3COUNT')==1));
            vis = table2cell( adni_metadata( rid_pos , strcmp(adni_metadata.Properties.VariableNames,'LONI_VISCODE2')) );
            vis_num = zeros(size(vis));
            for vs = 1:size(vis,1)
                if ~strcmp(vis{vs,1},'bl')
                    vis_num(vs,1) = str2double(vis{vs,1}(2:end));
                end
            end
            vis_num = abs(vis_num - vis0);
            vis_pos = find(vis_num==min(vis_num));
            if size(vis_pos,1) == 2
                vis_pos = vis_pos(1,1);
            end
            mtdt(ind,:) = tmp(vis_pos,:);
        end
    else
        mtdt(ind,:) = adni_metadata(rid_pos & viscode_pos,find(strcmp(adni_metadata.Properties.VariableNames,'MEM')==1):find(strcmp(adni_metadata.Properties.VariableNames,'APOE3COUNT')==1));
    end
    
    %% MEDHIST DIGGING
    rid_pos = cell2mat(table2cell( adni_medhist( : , strcmp(adni_medhist.Properties.VariableNames,'RID')) )) == rid;
    tmp = adni_medhist( rid_pos, ...
        strcmp(adni_medhist.Properties.VariableNames,'MHPSYCH') | ...
        strcmp(adni_medhist.Properties.VariableNames,'MH2NEURL') | ...
        strcmp(adni_medhist.Properties.VariableNames,'MH12RENA') | ...
        strcmp(adni_medhist.Properties.VariableNames,'MH14ALCH') | ...
        strcmp(adni_medhist.Properties.VariableNames,'MH16SMOK') ...
        );
    if sum(rid_pos) == 1
        mdhst(ind,:) = tmp;
    elseif sum(rid_pos) > 1
        vis = table2cell( adni_medhist( rid_pos , strcmp(adni_medhist.Properties.VariableNames,'VISCODE2')) );
        vis_num = zeros(size(vis));
        for vs = 1:size(vis,1)
            if ~strcmp(vis{vs,1},'bl') && ~strcmp(vis{vs,1},'sc')
                vis_num(vs,1) = str2double(vis{vs,1}(2:end));
            end
        end
        vis_num = abs(vis_num - vis0);
        vis_pos = find(vis_num==min(vis_num));
        if size(vis_pos,1) == 2
            vis_pos = vis_pos(1,1);
        end
        mdhst(ind,:) = tmp(vis_pos,:);
    else
        mdhst(ind,:) = {NaN};
    end
    
    %% MODHACH DIGGING
    rid_pos = cell2mat(table2cell( adni_modhach( : , strcmp(adni_modhach.Properties.VariableNames,'RID')) )) == rid;
    tmp = adni_modhach( rid_pos, ...
        strcmp(adni_modhach.Properties.VariableNames,'HMONSET') | ...
        strcmp(adni_modhach.Properties.VariableNames,'HMSTEPWS') | ...
        strcmp(adni_modhach.Properties.VariableNames,'HMSOMATC') | ...
        strcmp(adni_modhach.Properties.VariableNames,'HMEMOTIO') | ...
        strcmp(adni_modhach.Properties.VariableNames,'HMHYPERT') | ...
        strcmp(adni_modhach.Properties.VariableNames,'HMSTROKE') | ...
        strcmp(adni_modhach.Properties.VariableNames,'HMNEURSM') | ...
        strcmp(adni_modhach.Properties.VariableNames,'HMNEURSG') | ...
        strcmp(adni_modhach.Properties.VariableNames,'HMSCORE') ...
        );		
    if sum(rid_pos) == 1
        modhach(ind,:) = tmp;
    elseif sum(rid_pos) > 1
        disp(['Code FIX NEEDED: MODHACH multiple records for RID ' num2str(rid)])
    else
        modhach(ind,:) = {NaN};
    end
    
    %% LABDATA DIGGING
    rid_pos = cell2mat(table2cell( adni_labdata( : , strcmp(adni_labdata.Properties.VariableNames,'RID')) )) == rid;
    tmp = adni_labdata( rid_pos, ...
        strcmp(adni_labdata.Properties.VariableNames,'RCT392') ...
        );		
    if sum(rid_pos) == 1
        labdata(ind,:) = tmp;
    elseif sum(rid_pos) > 1
%         disp(['Code FIX NEEDED: labdata multiple records for RID ' num2str(rid)])
        tmp_pos = strcmp(table2cell(adni_labdata( rid_pos,'VISCODE')),'sc') | strcmp(table2cell(adni_labdata( rid_pos,'VISCODE2')),'sc');
        tmp = tmp(tmp_pos,:);
        if size(tmp,1) > 1
            tmp = tmp(1,:);
        end
        labdata(ind,:) = tmp;
    else
        labdata(ind,:) = {NaN};
    end
end

age = array2table(age,'VariableNames',{'Age-At-Visit'});

adni = [adni mtdt mdhst modhach labdata age];
adni_names = [adni_names mtdt.Properties.VariableNames mdhst.Properties.VariableNames modhach.Properties.VariableNames labdata.Properties.VariableNames age.Properties.VariableNames];

egfr = zeros(size(adni,1),1);
for ind = 1:size(adni,1)
    SCr = cell2mat(table2cell(adni(ind,'RCT392')));
    if isnan(SCr)
        egfr(ind,1) = NaN;
    else
        if strcmp(table2cell(adni(ind,'PTGENDER')),'Female')
            c = 1.012;
            kappa = 0.7;
            alpha = -0.248;
        else
            c = 1;
            kappa = 0.9;
            alpha = -0.207;
        end
        ag = cell2mat(table2cell(adni(ind,'AGE')));
        egfr(ind,1) = 142 * min([SCr/kappa, 1])^alpha * max([SCr/kappa, 1])^-1.200 * 0.9938^ag * c;
    end
end
% egfr(egfr==Inf) = NaN;
egfr = array2table(egfr,'VariableNames',{'eGFR'});

adni = [adni egfr];
adni_names = [adni_names  egfr.Properties.VariableNames];

%% Pick not-Hispanic white only

adni = adni( strcmp(table2cell(adni(:,'PTRACCAT')),'White') & strcmp(table2cell(adni(:,'PTETHCAT')),'Not Hisp/Latino'), : );
writetable(adni,fullfile(save_path,'adni_plasma_table.csv'));

% pos_rena = ~isnan(cell2mat(table2cell(adni(:,'MH12RENA'))));
% adni_rena = adni(pos_rena,:);
% pos_egfr = ~isnan(cell2mat(table2cell(adni(:,'eGFR'))));
% adni_egfr = adni(pos_egfr,:);
% 
% adni_age = cell2mat(table2cell(adni(:,'Age-At-Visit')));
% stats_demography{1,1} = 'Age [y.o.]';
% stats_demography{1,2} = mean(adni_age,'omitnan');
% stats_demography{1,3} = std(adni_age,'omitnan');
% 
% adni_rena_age = cell2mat(table2cell(adni_rena(:,'Age-At-Visit')));
% stats_rena_demography{1,1} = 'Age [y.o.]';
% stats_rena_demography{1,2} = mean(adni_rena_age);
% stats_rena_demography{1,3} = std(adni_rena_age);
% disp('yes')