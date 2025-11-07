clear all;
close all; clc;

time_gap = 160;

csv_path = '~/data-on-porto/ADNI/StudyData';
brightfocus_path = '~/data-on-porto/ADNI/BrightFocus';
dmri_filename = 'idaSearch_9_17_2025.csv';

csv_filename = 'ADNIMERGE_18Sep2025.csv';
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
adni_plasma = readtable(fullfile(csv_path,plasma_filename),'PreserveVariableNames',1);
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
    
%     if strcmp(sub(ind,1),'002_S_6652')
%         disp('yes')
%     end
    
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
NumDaysCutOff = [];
for sbid = 1:size(dmri,1)
%     if sbid==3840
%         disp('yes')
%     end
    
    sub = table2cell(dmri(sbid,'Subject ID'));
    dmri_date = table2cell(dmri(sbid,'Study Date'));
    
    subpos = strcmp(table2cell(tbl(:,'PTID')),sub);
    tbl_date = table2cell(tbl(subpos,'EXAMDATE'));
    
    if ~isempty(tbl_date)
        tbl_sub = tbl(subpos,:);

        for dateid = 1:size(tbl_date,1)
            NumDays(dateid,1) = abs( daysdif( tbl_date{dateid,1} , dmri_date{1,1} ) );
        end
        if min(abs(NumDays)) <= time_gap
%             tbl_dmri(sbid,:) = table2cell(tbl_sub(NumDays<=time_gap,:));
            tbl_dmri(sbid,:) = table2cell(tbl_sub(abs(NumDays)==min(abs(NumDays)),:));
        else
            NumDaysCutOff = [NumDaysCutOff; min(abs(NumDays))];
        end
        clear NumDays
    end
end

tbl_dmri_names = tbl.Properties.VariableNames;
dmri_names = dmri.Properties.VariableNames;

tbl_dmri = cell2table(tbl_dmri,'VariableNames',tbl.Properties.VariableNames);

adni = [dmri tbl_dmri];
adni_names = [dmri.Properties.VariableNames tbl.Properties.VariableNames];

for ind = 1:size(adni,1)
    %% Find and fill missing baseline data into ADNI table
    if isempty(cell2mat(table2cell(adni(ind,'RID'))))
        sub_tmp = table2cell(adni(ind,'Subject ID'));
        tmp = adni;
        tmp(ind,:) = [];
        sub_tmp_pos = strcmp(table2cell(tmp(:,'Subject ID')),sub_tmp);
        if sum(sub_tmp_pos)>0
            tmp = tmp(sub_tmp_pos,:);    
            if ~isempty(cell2mat(table2cell(tmp(1,'RID'))))
                adni(ind,'RID') = tmp(1,'RID');

                tmp2 = table2cell(adni(ind,'Phase'));
                tmp2{1,1}(end-1) = [];
                adni(ind,'COLPROT') = tmp2;

                colpos = find(strcmp(adni.Properties.VariableNames,'ORIGPROT')==1):find(strcmp(adni.Properties.VariableNames,'SITE')==1);
                adni(ind,colpos) = tmp(1,colpos);

                colpos = find(strcmp(adni.Properties.VariableNames,'DX_bl')==1):find(strcmp(adni.Properties.VariableNames,'APOE4')==1);
                adni(ind,colpos) = tmp(1,colpos);

                % !!! Check if that is hou m156 visit is calculated
                tmp_viscode = round(12*( cell2mat(table2cell(adni(ind,'Age'))) - cell2mat(table2cell(adni(ind,'AGE'))) ) / 6)*6;
                if tmp_viscode < 10
                    tmp_viscode = {[ 'm0' num2str(tmp_viscode) ]};
                else
                    tmp_viscode = {[ 'm' num2str(tmp_viscode) ]};
                end
                adni(ind,'VISCODE') = tmp_viscode;

                colpos = find(strcmp(adni.Properties.VariableNames,'EXAMDATE_bl')==1):find(strcmp(adni.Properties.VariableNames,'Month_bl')==1);
                adni(ind,colpos) = tmp(1,colpos);
            end
        end
    end
    
    
    count_irregular = 0;
    viscode = table2cell( adni(ind,strcmp(adni_names,'VISCODE')) );
    if ~isempty(viscode{1,1})
%         rid = cell2mat(table2cell( adni(ind,strcmp(adni_names,'RID')) ));
        rid = str2double(cell2mat( extractAfter(table2cell( adni(ind,strcmp(adni_names,'Subject ID'))),'_S_') ));
        if strcmp(viscode,'bl')
            vis0 = 0;
        else
            vis0 = str2double(viscode{1,1}(2:end));
        end
        
        
        %% METADATA DIGGING
        rid_pos = cell2mat(table2cell( adni_metadata( : , strcmp(adni_metadata.Properties.VariableNames,'RID')) )) == rid;
        if sum(rid_pos)>0
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
        else
            mtdt(ind,:) = repmat({NaN},1,size(mtdt,2));
        end
        
        %% VITALS DIGGING
        rid_pos = cell2mat(table2cell( adni_vitals( : , strcmp(adni_vitals.Properties.VariableNames,'RID')) )) == rid;
        if sum(rid_pos)>0
            weight = adni_vitals( rid_pos, ...
                strcmp(adni_vitals.Properties.VariableNames,'VISCODE') | ...
                strcmp(adni_vitals.Properties.VariableNames,'VISCODE2') | ...
                strcmp(adni_vitals.Properties.VariableNames,'VSWEIGHT') | ...
                strcmp(adni_vitals.Properties.VariableNames,'VSWTUNIT') ...
                );
            height = adni_vitals( rid_pos, ...
                strcmp(adni_vitals.Properties.VariableNames,'VISCODE') | ...
                strcmp(adni_vitals.Properties.VariableNames,'VISCODE2') | ...
                strcmp(adni_vitals.Properties.VariableNames,'VSHEIGHT') | ...
                strcmp(adni_vitals.Properties.VariableNames,'VSHTUNIT') ...
                );

            weight = weight( ~( cell2mat(table2cell(weight(:,'VSWEIGHT')))<0 | isnan(cell2mat(table2cell(weight(:,'VSWEIGHT')))) ) , : );
            height = height( ~( cell2mat(table2cell(height(:,'VSHEIGHT')))<0 | isnan(cell2mat(table2cell(height(:,'VSHEIGHT')))) ) , : );

            weight_pos_pounds = cell2mat(table2cell(weight(:,'VSWTUNIT')))==1;
            height_pos_inches = cell2mat(table2cell(height(:,'VSHTUNIT')))==1;

            if sum(weight_pos_pounds)>0
                for wnd = 1:size(weight,1)
                    if weight_pos_pounds(wnd,1) == 1
                        weight(wnd,'VSWEIGHT') = table(cell2mat(table2cell(weight(wnd,'VSWEIGHT')))*0.453592);
                        weight(wnd,'VSWTUNIT') = table(2);
                    end
                end
            end

            if sum(height_pos_inches)>0
                for wnd = 1:size(height,1)
                    if height_pos_inches(wnd,1) == 1
                        height(wnd,'VSHEIGHT') = table(convlength(cell2mat(table2cell(height(wnd,'VSHEIGHT'))),'in','m')*100);
                        height(wnd,'VSHTUNIT') = table(2);
                    end
                end
            end

            wght_pos = strcmp( table2cell(weight(:,'VISCODE')) , viscode ) | strcmp( table2cell(weight(:,'VISCODE2')) , viscode );
            if sum(wght_pos)>0
                tmp = cell2mat(table2cell( weight ( wght_pos , 'VSWEIGHT' ) ));
            elseif strcmp(viscode,'bl') && sum(strcmp( table2cell(weight(:,'VISCODE')) , 'sc' ) | strcmp( table2cell(weight(:,'VISCODE2')) , 'sc' ))>0
                tmp = cell2mat(table2cell( weight ( strcmp( table2cell(weight(:,'VISCODE')) , 'sc' ) | strcmp( table2cell(weight(:,'VISCODE2')) , 'sc' ) , 'VSWEIGHT' ) ));
            elseif strcmp(viscode,'sc') && sum(strcmp( table2cell(weight(:,'VISCODE')) , 'bl' ) | strcmp( table2cell(weight(:,'VISCODE2')) , 'bl' ))>0
                tmp = cell2mat(table2cell( weight ( strcmp( table2cell(weight(:,'VISCODE')) , 'bl' ) | strcmp( table2cell(weight(:,'VISCODE2')) , 'bl' ) , 'VSWEIGHT' ) ));
            else
                tmp = cell2mat(table2cell( weight ( : , 'VSWEIGHT' ) ));
            end
            if mean(tmp,'omitnan') > 275
                wght(ind,1) = median(cell2mat(table2cell(weight(:,'VSWEIGHT'))),'omitnan');
            else
                wght(ind,1) =  mean(tmp,'omitnan');
            end

            hght_pos = strcmp( table2cell(height(:,'VISCODE')) , viscode ) | strcmp( table2cell(height(:,'VISCODE2')) , viscode );
            if sum(hght_pos)>0
                tmp = cell2mat(table2cell( height ( hght_pos , 'VSHEIGHT' ) ));
            elseif strcmp(viscode,'bl') && sum(strcmp( table2cell(height(:,'VISCODE')) , 'sc' ) | strcmp( table2cell(height(:,'VISCODE2')) , 'sc' ))>0
                tmp = cell2mat(table2cell( height ( strcmp( table2cell(height(:,'VISCODE')) , 'sc' ) | strcmp( table2cell(height(:,'VISCODE2')) , 'sc' ) , 'VSHEIGHT' ) ));
            elseif strcmp(viscode,'sc') && sum(strcmp( table2cell(height(:,'VISCODE')) , 'bl' ) | strcmp( table2cell(height(:,'VISCODE2')) , 'bl' ))>0
                tmp = cell2mat(table2cell( height ( strcmp( table2cell(height(:,'VISCODE')) , 'bl' ) | strcmp( table2cell(height(:,'VISCODE2')) , 'bl' ) , 'VSHEIGHT' ) ));
            else
                tmp = cell2mat(table2cell( height ( : , 'VSHEIGHT' ) ));
            end
            if sum(tmp>250)>0
                for wnd = 1:size(tmp,1)
                    if tmp(wnd,1)>250
                        tmp(wnd,1) = convlength(tmp(wnd,1)/100,'m','in');
                    end
                end
            end
            hght(ind,1) =  mean(tmp,'omitnan');
        else
            wght(ind,1) = NaN;
            hght(ind,1) = NaN;
        end
        
        
        %% MEDHIST DIGGING
        rid_pos = cell2mat(table2cell( adni_medhist( : , strcmp(adni_medhist.Properties.VariableNames,'RID')) )) == rid;
        if sum(rid_pos)>0
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
        else
            mdhst(ind,:) = {NaN};
        end
        
        %% MODHACH DIGGING
        rid_pos = cell2mat(table2cell( adni_modhach( : , strcmp(adni_modhach.Properties.VariableNames,'RID')) )) == rid;
        if sum(rid_pos)>0
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
        else
            modhach(ind,:) = {NaN};
        end
        
        %% LABDATA DIGGING
        rid_pos = cell2mat(table2cell( adni_labdata( : , strcmp(adni_labdata.Properties.VariableNames,'RID')) )) == rid;
        if sum(rid_pos)>0
            tmp = adni_labdata( rid_pos, ...
                strcmp(adni_labdata.Properties.VariableNames,'RCT392') | ...
                strcmp(adni_labdata.Properties.VariableNames,'VISCODE') | ...
                strcmp(adni_labdata.Properties.VariableNames,'VISCODE2') ...
                );
            tmp = renamevars(tmp,'VISCODE','VISCODE-labdata');
            tmp = renamevars(tmp,'VISCODE2','VISCODE2-labdata');
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
%                 labdata(ind,:) = {NaN};
                labdata(ind,:) = [{''} {''} {NaN}];
            end
        else
            labdata(ind,:) = [{''} {''} {NaN}];
        end
        
        %% PLASMA MARKER DIGGING
        rid_pos = cell2mat(table2cell( adni_plasma( : , strcmp(adni_plasma.Properties.VariableNames,'RID')) )) == rid;
        if sum(rid_pos)>0
            tmp = adni_plasma( rid_pos, ...
                strcmp(adni_plasma.Properties.VariableNames,'pT217_F') | ...
                strcmp(adni_plasma.Properties.VariableNames,'AB42_F') | ...
                strcmp(adni_plasma.Properties.VariableNames,'AB40_F') | ...
                strcmp(adni_plasma.Properties.VariableNames,'AB42_AB40_F') | ...
                strcmp(adni_plasma.Properties.VariableNames,'pT217_AB42_F') | ...
                strcmp(adni_plasma.Properties.VariableNames,'NfL_Q') | ...
                strcmp(adni_plasma.Properties.VariableNames,'GFAP_Q') | ...
                strcmp(adni_plasma.Properties.VariableNames,'VISCODE') | ...
                strcmp(adni_plasma.Properties.VariableNames,'VISCODE2') ...
                );
            tmp = renamevars(tmp,'VISCODE','VISCODE-plasma');
            tmp = renamevars(tmp,'VISCODE2','VISCODE2-plasma');
            if sum(rid_pos) == 1
                plasma_marker(ind,:) = tmp;
            elseif sum(rid_pos) > 1
                vis = table2cell( adni_plasma( rid_pos , strcmp(adni_plasma.Properties.VariableNames,'VISCODE2')) );
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
                plasma_marker(ind,:) = tmp(vis_pos,:);
            else
%                 plasma_marker(ind,:) = {NaN};
                plasma_marker(ind,:) = [repmat({''},1,2) repmat({NaN},1,7)];
            end
        else
            plasma_marker(ind,:) = [repmat({''},1,2) repmat({NaN},1,7)];
        end
        
    else
        mtdt(ind,:) = repmat({NaN},1,size(mtdt,2));
        wght(ind,1) = NaN;
        hght(ind,1) = NaN;
        mdhst(ind,:) = {NaN};
        modhach(ind,:) = {NaN};
        labdata(ind,:) = [{''} {''} {NaN}];
        plasma_marker(ind,:) = [repmat({''},1,2) repmat({NaN},1,7)];
    end
end


% bmi = wght ./ (hght/100).^2;
bmi = cell2mat(table2cell(adni(:,'Weight'))) ./ (hght/100).^2;
hght = array2table(hght,'VariableNames',{'Height'});
wght = array2table(wght,'VariableNames',{'Weight-vitals'});
bmi = array2table(bmi,'VariableNames',{'BMI'});

labdata(size(adni,1)+1,:)=labdata(1,:);
labdata(end,:)=[];

adni = [adni mtdt mdhst modhach labdata plasma_marker hght wght bmi];
adni_names = [adni_names mtdt.Properties.VariableNames mdhst.Properties.VariableNames modhach.Properties.VariableNames labdata.Properties.VariableNames plasma_marker.Properties.VariableNames ...
    hght.Properties.VariableNames wght.Properties.VariableNames bmi.Properties.VariableNames];

egfr = zeros(size(adni,1),1);
for ind = 1:size(adni,1)
    viscode = table2cell( adni(ind,strcmp(adni_names,'VISCODE')) );
    if ~isempty(viscode{1,1})
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
    else
        egfr(ind,1) = NaN;
    end
end
% egfr(egfr==Inf) = NaN;
egfr = array2table(egfr,'VariableNames',{'eGFR'});

adni = [adni egfr];
adni_names = [adni_names  egfr.Properties.VariableNames];

%% MAKE BASELINE ADNI0 TABLE
for ind = 1:size(tbl0,1)
    bs_pos = strcmp(table2cell(adni(:,'Subject ID')),tbl0{ind,strcmp(dmri_names,'Subject ID')}) & ...
        cell2mat(table2cell(adni(:,'Age')))==tbl0{ind,strcmp(dmri_names,'Age')} & ...
        strcmp(table2cell(adni(:,'Description')),tbl0{ind,strcmp(dmri_names,'Description')}) & ...
        cell2mat(table2cell(adni(:,'Image ID')))==tbl0{ind,strcmp(dmri_names,'Image ID')};
    if sum(bs_pos) == 1
        adni0(ind,:) = adni(bs_pos,:);
    else
        disp(ind)
    end
end

%% MAKE BASELILNE STATS
tbl0_race = adni0.PTRACCAT;
for ind = 1:size(tbl0_race,1)
    if isempty(tbl0_race{ind,1})
        tbl0_race{ind,1} = 'Not available';
    end
end

tbl0_mmse = cell2mat(table2cell(adni0(:,'MMSE')));
tbl0_ptau217 = cell2mat(table2cell(adni0(:,'pT217_F')));
tbl0_ab4240 = cell2mat(table2cell(adni0(:,'AB42_AB40_F')));
tbl0_ab4240(tbl0_ab4240<-0.5)=NaN;
tbl0_gfap = cell2mat(table2cell(adni0(:,'GFAP_Q')));
tbl0_nfl = cell2mat(table2cell(adni0(:,'NfL_Q')));
tbl0_apoe4 = table2cell(adni0(:,'APOE4'));
for ind = 1:size(tbl0_apoe4,1)
    if isempty(tbl0_apoe4{ind,1})
        tbl0_apoe4{ind,1} = NaN;
    end
end
tbl0_apoe4 = cell2mat(tbl0_apoe4);
tbl0_ethnicity = table2cell(adni0(:,'PTETHCAT'));
for ind = 1:size(tbl0_ethnicity,1)
    if isempty(tbl0_ethnicity{ind,1})
        tbl0_ethnicity{ind,1} = 'Not available';
    end
end


stats0_mmse_counts = sum(~isnan(tbl0_mmse));
stats0_ptau217_counts = sum(~isnan(tbl0_ptau217));
stats0_ab4240_counts = sum(~isnan(tbl0_ab4240));
stats0_gfap_counts = sum(~isnan(tbl0_gfap));
stats0_nfl_counts = sum(~isnan(tbl0_nfl));

stats0_apoe4_counts(1,:) = [sum(tbl0_apoe4==0) sum(tbl0_apoe4==1) sum(tbl0_apoe4==2) sum(isnan(tbl0_apoe4))];
stats0_apoe4_counts(2,:) = stats0_apoe4_counts(1,:).*100./sum(stats0_apoe4_counts(1,1:3));

stats0_ethnicity_counts(1,:) = [ sum(strcmp(tbl0_ethnicity,'Not Hisp/Latino')) sum(strcmp(tbl0_ethnicity,'Hisp/Latino')) sum(strcmp(tbl0_ethnicity,'Unknown')) sum(strcmp(tbl0_ethnicity,'Not available')) ];
stats0_ethnicity_counts(2,:) = stats0_ethnicity_counts(1,:).*100./sum(stats0_ethnicity_counts(1,1:3));


stats0_race_counts(1,:) = [ sum(strcmp(tbl0_race,'White')) sum(strcmp(tbl0_race,'Black')) sum(strcmp(tbl0_race,'Asian')) sum(strcmp(tbl0_race,'Am Indian/Alaskan')) sum(strcmp(tbl0_race,'More than one')) sum(strcmp(tbl0_race,'Unknown')) sum(strcmp(tbl0_race,'Not available')) ];
stats0_race_counts(2,:) = stats0_race_counts(1,:).*100./sum(stats0_race_counts(1,1:6));
%% Data visualization
h(1).fig = figure(1);
set(h(1).fig,'Position',[50 50 650 1250])

subplot(4,2,1)
histogram(tbl0_age,15)
ylabel('Counts')
xlabel('Age [years]')
set(gca,'FontSize',14,'LineWidth',2)

subplot(4,2,2)
histogram(tbl0_weight,25)
xlabel('Weight [kg]')
xlim([40 150])
set(gca,'FontSize',14,'LineWidth',2,...
    'XTick',(0:25:200)-2,'XTickLabel',0:25:200)

subplot(4,2,3)
histogram(tbl0_nvisits,18)
ylabel('Counts')
xlabel('Number of visits')
xlim([0.5 9.5])
set(gca,'FontSize',14,'LineWidth',2,...
    'XTick',[1.2 3 4.9 6.7 8.5 11],'XTickLabel',1:2:11)

subplot(4,2,4)
histogram(tbl0_distvisit,'BinEdges',1:6:100)
xlabel('Time between visits [mon.]')
xlim([0 50])
set(gca,'FontSize',14,'LineWidth',2,...
    'XTick',(6:6:150)-2,'XTickLabel',6:6:150)

subplot(4,2,5)
histogram(tbl0_mmse,18)
hold on
text(19,520,'Idenfitied for','Fontsize',14,'HorizontalAlignment','left')
text(19,450,[num2str(stats0_mmse_counts) ' participants'],'Fontsize',14,'HorizontalAlignment','left')
hold off
ylabel('Counts')
xlabel('Baseline MMSE')
xlim([18 30])
set(gca,'FontSize',14,'LineWidth',2,...
    'XTick',0:2:30,'XTickLabel',0:2:30)

subplot(4,2,6)
histogram(tbl0_ptau217,25)
hold on
text(1.4,190,'Idenfitied for','Fontsize',14,'HorizontalAlignment','right')
text(1.4,165,[num2str(stats0_ptau217_counts) ' participants'],'Fontsize',14,'HorizontalAlignment','right')
hold off
xlabel('Baseline p\tau_{217}')
xlim([0 1.5])
set(gca,'FontSize',14,'LineWidth',2,...
    'XTick',0:0.5:3,'XTickLabel',0:0.5:3)

subplot(4,2,7)
histogram(tbl0_ab4240,25)
hold on
text(0.147,180,'Idenfitied for','Fontsize',14,'HorizontalAlignment','right')
text(0.147,155,num2str(stats0_ab4240_counts),'Fontsize',14,'HorizontalAlignment','right')
text(0.147,135,'participants','Fontsize',14,'HorizontalAlignment','right')
hold off
ylabel('Counts')
xlabel('Baseline A\beta_{42/40}')
xlim([0.05 0.15])
set(gca,'FontSize',14,'LineWidth',2,...
    'XTick',0:0.03:1,'XTickLabel',0:0.03:1)

subplot(4,2,8)
histogram(tbl0_gfap,25)
hold on
text(580,270,'Idenfitied for','Fontsize',14,'HorizontalAlignment','right')
text(580,240,[num2str(stats0_gfap_counts) ' participants'],'Fontsize',14,'HorizontalAlignment','right')
hold off
xlabel('Baseline GFAP')
xlim([0 600])
set(gca,'FontSize',14,'LineWidth',2,...
    'XTick',0:200:1800,'XTickLabel',0:200:1800)

