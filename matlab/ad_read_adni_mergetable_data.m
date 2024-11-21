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
dmri = ida(dmri_pos,:);

adai = readtable(fullfile(match_path,adai_filename),'PreserveVariableNames',1);
adai_dmripa_pos = cell2mat(table2cell(adai(:,'dwi-pa'))) == 1;
adai = adai(adai_dmripa_pos,:);

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

ptid_unique = tbl_dmri(:,strcmp(tbl_dmri_names,'PTID'));
for ind = 1:size(ptid_unique,1)
    if isempty(ptid_unique{ind,1})
        ptid_unique{ind,1}='';
    end
end
ptid_unique = unique(ptid_unique);
ptid_unique = ptid_unique(2:end,1);

for ind = 1:size(ptid_unique,1)
    pos = strcmp(tbl_dmri(:,strcmp(tbl_dmri_names,'PTID')),ptid_unique{ind,1});
    tmp = dmri(pos,:);
    ag = cell2mat(table2cell(tmp(:,strcmp(dmri.Properties.VariableNames,'Age'))));
    ag_pos = find(ag==min(ag));
    if size(ag_pos,1) > 1
        ag_pos = ag_pos(1);
    end
    dmri_unique(ind,:) = tmp(ag_pos,:);
    tmp = tbl_dmri(pos,:);
    tbl_dmri_unique(ind,:) = tmp(ag_pos,:);
end

tbl_dmri_unique = cell2table(tbl_dmri_unique,...
    'VariableNames',tbl.Properties.VariableNames);

adni = [dmri_unique tbl_dmri_unique];
adni_names = [dmri.Properties.VariableNames tbl.Properties.VariableNames];

count_irregular = 0;
for ind = 1:size(adni,1)
    rid = cell2mat(table2cell( adni(ind,strcmp(adni_names,'RID')) ));
    viscode = table2cell( adni(ind,strcmp(adni_names,'VISCODE')) );
    if strcmp(viscode,'bl')
        vis0 = 0;
    else
        vis0 = str2double(viscode{1,1}(2:end));
    end
    
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
        mdhst(ind,:) = tmp(vis_pos,:);
    else
        mdhst(ind,:) = {NaN};
    end
    
    %% MODHACH DIGGING
    rid_pos = cell2mat(table2cell( adni_modhach( : , strcmp(adni_modhach.Properties.VariableNames,'RID')) )) == rid;
    tmp = adni_modhach( rid_pos, ...
        strcmp(adni_modhach.Properties.VariableNames,'HMHYPERT') ...
        );
    if sum(rid_pos) == 1
        modhach(ind,:) = tmp;
    elseif sum(rid_pos) > 1
        disp(['Code FIX NEEDED: MODHACH multiple records for RID ' num2str(rid)])
    else
        modhach(ind,:) = {NaN};
    end
end

adni = [adni mtdt mdhst modhach];
adni_names = [adni_names mtdt.Properties.VariableNames mdhst.Properties.VariableNames modhach.Properties.VariableNames];



age_min=45;
age_max=100;
age_step=5;

weight_min=30;
weight_max=160;
weight_step=10;

vis_min = 0;
vis_step = 12;
vis_max = 174;

mmse_min=0;
mmse_step=1;
mmse_max=30;

y_max = 30;
y_step = 5;
y_max2 = 60;
y_step2 = 10;

clr_orange = [233, 116, 81]/255;
clr_lightblue = [0, 150, 255]/255;

% viscode_unique = unique(table2cell( adni(:,strcmp(adni_names,'VISCODE')) ));
% viscode_unique_numbers = viscode_unique(2:end);
% for ind = 1:size(viscode_unique_numbers,1)
%     viscode_unique_numbers{ind,1} = str2double(viscode_unique_numbers{ind,1}(2:end));
% end

h(1).fig = figure(1);
set(h(1).fig,'Position',[50 50 1400 1200]);

impair_text = {'CN','MCI','Dementia'};
impairment = cell2mat(table2cell(adai(:,'hp_impairment')));
impairment2 = impairment;
if strcmp(sci,'sci+mci')
    impairment2(impairment2==3) = 2;
elseif strcmp(sci,'sci+cn')
    impairment2(impairment2==2) = 1;
    impairment2(impairment2==3) = 2;
end
for impair = 1:3   
    a_age = cell2mat(table2cell( adai(impairment2 == impair,strcmp(adai.Properties.VariableNames,'Age[y]')) ));
    a_weight = cell2mat(table2cell( adai(impairment2 == impair,strcmp(adai.Properties.VariableNames,'Weight[kg]')) ));
    a_sex = table2cell( adai(impairment2 == impair,strcmp(adai.Properties.VariableNames,'Sex')) );
    
    
    b_age = cell2mat(table2cell( adni(strcmp(table2cell(adni(:,strcmp(adni_names,'DX'))),impair_text{1,impair}),strcmp(adni_names,'Age')) ));
    b_weight = cell2mat(table2cell( adni(strcmp(table2cell(adni(:,strcmp(adni_names,'DX'))),impair_text{1,impair}),strcmp(adni_names,'Weight')) ));
    b_sex = table2cell( adni(strcmp(table2cell(adni(:,strcmp(adni_names,'DX'))),impair_text{1,impair}),strcmp(adni_names,'Sex')) );
    b_viscode = table2cell( adni(strcmp(table2cell(adni(:,strcmp(adni_names,'DX'))),impair_text{1,impair}),strcmp(adni_names,'VISCODE')) );
    
    b_viscode_num = zeros(1,1);
    for vis = 1:size(b_viscode,1)
        if strcmp(b_viscode{vis,1},'bl')
            b_viscode_num(vis,1) = 0;
        else
            b_viscode_num(vis,1) = str2double(b_viscode{vis,1}(2:end));
        end
    end
    
    subplot(3,3,3*(impair-1)+1)
    histogram(b_age,age_min:age_step:age_max);
    hold on
    histogram(a_age,age_min:age_step:age_max);
    text(1.04*age_min,0.94*y_max,'ADAI:','FontSize',12,'Color',clr_orange,'FontWeight','bold')
    text(1.04*age_min,0.87*y_max,[ num2str(size(a_age,1)) ' subjects'],'FontSize',12,'Color',clr_orange)
    text(1.04*age_min,0.80*y_max,[ num2str(sum(strcmp(a_sex,'F'))) ' females'],'FontSize',12,'Color',clr_orange)
    
    text(0.99*age_max,0.94*y_max,'ADNI:','FontSize',12,'Color',clr_lightblue,'HorizontalAlignment','Right','FontWeight','bold')
    text(0.99*age_max,0.87*y_max,[ num2str(size(b_age,1)) ' subjects'],'FontSize',12,'Color',clr_lightblue,'HorizontalAlignment','Right')
    text(0.99*age_max,0.80*y_max,[ num2str(sum(strcmp(b_sex,'F'))) ' females'],'FontSize',12,'Color',clr_lightblue,'HorizontalAlignment','Right')
    hold off
    grid on
    xlim([age_min age_max])
    ylim([0 y_max])
    if impair < 3
        set(gca,'XTick',age_min+5:2*age_step:age_max,'XTickLabel','')
    else
        set(gca,'XTick',age_min+5:2*age_step:age_max,'XTickLabel',age_min+5:2*age_step:age_max)
        xlabel('Age [y.o.]')
    end    
    if (impair == 2 && strcmp(sci,'sci+mci')) || (impair == 1 && strcmp(sci,'sci+cn'))
        ylabel(['SCI + ' impair_text{1,impair} ' counts'])
    else
        ylabel([impair_text{1,impair} ' counts'])
    end
    set(gca,'Fontsize',14,'LineWidth',2)
    
    
    subplot(3,3,3*(impair-1)+2)
    hba = histogram(b_weight,weight_min:weight_step:weight_max);
    hold on
    haa = histogram(a_weight,weight_min:weight_step:weight_max);
    hold off
    grid on
    xlim([weight_min weight_max])
    ylim([0 y_max])
    if impair < 3
        set(gca,'XTick',weight_min:2*weight_step:weight_max,'XTickLabel','')
    else
        set(gca,'XTick',weight_min:2*weight_step:weight_max,'XTickLabel',weight_min:2*weight_step:weight_max)
        xlabel('Weight [kg]')
    end
    set(gca,'YTick',0:y_step:y_max,'YTickLabel','')
    if impair == 1
        legend([haa hba],{'ADAI','ADNI'},'Location','East')
    end
    set(gca,'Fontsize',14,'LineWidth',2)
    
    
    subplot(3,3,3*(impair-1)+3)
    hba = histogram(b_viscode_num,vis_min:vis_step:vis_max);
    grid on
    xlim([vis_min vis_max])
    ylim([0 2*y_max])
    if impair < 3
        set(gca,'XTick',vis_min:2*vis_step:vis_max,'XTickLabel','')
    else
        set(gca,'XTick',vis_min:2*vis_step:vis_max,'XTickLabel',vis_min:2*vis_step:vis_max)
        xlabel('Visit [months]')
    end
    set(gca,'Fontsize',14,'LineWidth',2)
end


a_age = cell2mat(table2cell( adai(:,strcmp(adai.Properties.VariableNames,'Age[y]')) ));
a_weight = cell2mat(table2cell( adai(:,strcmp(adai.Properties.VariableNames,'Weight[kg]')) ));
a_sex = table2cell( adai(:,strcmp(adai.Properties.VariableNames,'Sex')) );
a_mmse = cell2mat(table2cell( adai(:,strcmp(adai.Properties.VariableNames,'mmse_totalscore')) ));
a_sub = table2cell( adai(:,strcmp(adai.Properties.VariableNames,'SUB')) );
a_sess = table2cell( adai(:,strcmp(adai.Properties.VariableNames,'SESS')) );
a_apoe2 = cell2mat(table2cell( adai(:,strcmp(adai.Properties.VariableNames,'tr_apoee2')) ));
a_apoe3 = cell2mat(table2cell( adai(:,strcmp(adai.Properties.VariableNames,'tr_apoee3')) ));
a_apoe4 = cell2mat(table2cell( adai(:,strcmp(adai.Properties.VariableNames,'tr_apoee4')) ));
a_education = cell2mat(table2cell( adai(:,strcmp(adai.Properties.VariableNames,'hp_schoolyears')) ));
a_alcohol = cell2mat(table2cell( adai(:,strcmp(adai.Properties.VariableNames,'hp_alcohol')) ));
a_smoking = cell2mat(table2cell( adai(:,strcmp(adai.Properties.VariableNames,'hp_tobacco')) ));
a_hypertension = cell2mat(table2cell( adai(:,strcmp(adai.Properties.VariableNames,'Hypertension')) ));

b_age = cell2mat(table2cell( adni(:,strcmp(adni_names,'Age')) ));
b_weight = cell2mat(table2cell( adni(:,strcmp(adni_names,'Weight')) ));
b_sex = table2cell( adni(:,strcmp(adni_names,'Sex')) );
b_viscode = table2cell( adni(:,strcmp(adni_names,'VISCODE')) );
b_mmse = cell2mat(table2cell( adni(:,strcmp(adni_names,'MMSE')) ));
b_sub = table2cell( adni(:,strcmp(adni_names,'Subject ID')) );
b_race = table2cell( adni(:,strcmp(adni_names,'PTRACCAT')) );
b_ethnicity = table2cell( adni(:,strcmp(adni_names,'PTETHCAT')) );

b_weight(b_weight==0)=NaN;

b_viscode_num = zeros(1,1);
for vis = 1:size(b_viscode,1)
    if strcmp(b_viscode{vis,1},'bl')
        b_viscode_num(vis,1) = 0;
    else
        b_viscode_num(vis,1) = str2double(b_viscode{vis,1}(2:end));
    end
end

a_age_f = cell2mat(table2cell( adai(strcmp(table2cell(adai(:,strcmp(adai.Properties.VariableNames,'Sex'))),'F'),strcmp(adai.Properties.VariableNames,'Age[y]')) ));
a_weight_f = cell2mat(table2cell( adai(strcmp(table2cell(adai(:,strcmp(adai.Properties.VariableNames,'Sex'))),'F'),strcmp(adai.Properties.VariableNames,'Weight[kg]')) ));
a_mmse_f = cell2mat(table2cell( adai(strcmp(table2cell(adai(:,strcmp(adai.Properties.VariableNames,'Sex'))),'F'),strcmp(adai.Properties.VariableNames,'mmse_totalscore')) ));
a_sub_f = table2cell( adai(strcmp(table2cell(adai(:,strcmp(adai.Properties.VariableNames,'Sex'))),'F'),strcmp(adai.Properties.VariableNames,'SUB')) );
a_sess_f = table2cell( adai(strcmp(table2cell(adai(:,strcmp(adai.Properties.VariableNames,'Sex'))),'F'),strcmp(adai.Properties.VariableNames,'SESS')) );

a_age_m = cell2mat(table2cell( adai(strcmp(table2cell(adai(:,strcmp(adai.Properties.VariableNames,'Sex'))),'M'),strcmp(adai.Properties.VariableNames,'Age[y]')) ));
a_weight_m = cell2mat(table2cell( adai(strcmp(table2cell(adai(:,strcmp(adai.Properties.VariableNames,'Sex'))),'M'),strcmp(adai.Properties.VariableNames,'Weight[kg]')) ));
a_mmse_m = cell2mat(table2cell( adai(strcmp(table2cell(adai(:,strcmp(adai.Properties.VariableNames,'Sex'))),'M'),strcmp(adai.Properties.VariableNames,'mmse_totalscore')) ));
a_sub_m = table2cell( adai(strcmp(table2cell(adai(:,strcmp(adai.Properties.VariableNames,'Sex'))),'M'),strcmp(adai.Properties.VariableNames,'SUB')) );
a_sess_m = table2cell( adai(strcmp(table2cell(adai(:,strcmp(adai.Properties.VariableNames,'Sex'))),'M'),strcmp(adai.Properties.VariableNames,'SESS')) );

b_age_f = cell2mat(table2cell( adni(strcmp(table2cell(adni(:,strcmp(adni_names,'Sex'))),'F'),strcmp(adni_names,'Age')) ));
b_weight_f = cell2mat(table2cell( adni(strcmp(table2cell(adni(:,strcmp(adni_names,'Sex'))),'F'),strcmp(adni_names,'Weight')) ));
b_viscode_f = table2cell( adni(strcmp(table2cell(adni(:,strcmp(adni_names,'Sex'))),'F'),strcmp(adni_names,'VISCODE')) );
b_mmse_f = cell2mat(table2cell( adni(strcmp(table2cell(adni(:,strcmp(adni_names,'Sex'))),'F'),strcmp(adni_names,'MMSE')) ));
b_sub_f = table2cell( adni(strcmp(table2cell(adni(:,strcmp(adni_names,'Sex'))),'F'),strcmp(adni_names,'Subject ID')) );

b_age_m = cell2mat(table2cell( adni(strcmp(table2cell(adni(:,strcmp(adni_names,'Sex'))),'M'),strcmp(adni_names,'Age')) ));
b_weight_m = cell2mat(table2cell( adni(strcmp(table2cell(adni(:,strcmp(adni_names,'Sex'))),'M'),strcmp(adni_names,'Weight')) ));
b_viscode_m = table2cell( adni(strcmp(table2cell(adni(:,strcmp(adni_names,'Sex'))),'M'),strcmp(adni_names,'VISCODE')) );
b_mmse_m = cell2mat(table2cell( adni(strcmp(table2cell(adni(:,strcmp(adni_names,'Sex'))),'M'),strcmp(adni_names,'MMSE')) ));
b_sub_m = table2cell( adni(strcmp(table2cell(adni(:,strcmp(adni_names,'Sex'))),'M'),strcmp(adni_names,'Subject ID')) );

b_viscode_num_f = zeros(1,1);
for vis = 1:size(b_viscode_f,1)
    if strcmp(b_viscode_f{vis,1},'bl')
        b_viscode_num_f(vis,1) = 0;
    else
        b_viscode_num_f(vis,1) = str2double(b_viscode_f{vis,1}(2:end));
    end
end

b_viscode_num_m = zeros(1,1);
for vis = 1:size(b_viscode_m,1)
    if strcmp(b_viscode_m{vis,1},'bl')
        b_viscode_num_m(vis,1) = 0;
    else
        b_viscode_num_m(vis,1) = str2double(b_viscode_m{vis,1}(2:end));
    end
end

%% Figure 2
h(2).fig = figure(2);
set(h(2).fig,'Position',[50 50 1900 1200]);

subplot(3,4,1)
histogram(b_age,age_min:age_step:age_max);
hold on
histogram(a_age,age_min:age_step:age_max);
text(1.04*age_min,0.94*y_max2,'ADAI:','FontSize',12,'Color',clr_orange,'FontWeight','bold')
text(1.04*age_min,0.87*y_max2,[ num2str(size(a_age,1)) ' subjects'],'FontSize',12,'Color',clr_orange)
text(1.04*age_min,0.80*y_max2,[ num2str(sum(strcmp(a_sex,'F'))) ' females'],'FontSize',12,'Color',clr_orange)

text(0.99*age_max,0.94*y_max2,'ADNI:','FontSize',12,'Color',clr_lightblue,'HorizontalAlignment','Right','FontWeight','bold')
text(0.99*age_max,0.87*y_max2,[ num2str(size(b_age,1)) ' subjects'],'FontSize',12,'Color',clr_lightblue,'HorizontalAlignment','Right')
text(0.99*age_max,0.80*y_max2,[ num2str(sum(strcmp(b_sex,'F'))) ' females'],'FontSize',12,'Color',clr_lightblue,'HorizontalAlignment','Right')
hold off
grid on
xlim([age_min age_max])
ylim([0 y_max2])
set(gca,'XTick',age_min+5:2*age_step:age_max,'XTickLabel','')
ylabel('Counts')
set(gca,'Fontsize',14,'LineWidth',2)


subplot(3,4,2)
hba = histogram(b_weight,weight_min:weight_step:weight_max);
hold on
haa = histogram(a_weight,weight_min:weight_step:weight_max);
hold off
grid on
xlim([weight_min weight_max])
ylim([0 y_max2])
set(gca,'XTick',weight_min:2*weight_step:weight_max,'XTickLabel','')
set(gca,'YTick',0:y_step2:y_max2,'YTickLabel','')
legend([haa hba],{'ADAI','ADNI'},'Location','East')
set(gca,'Fontsize',14,'LineWidth',2)

subplot(3,4,3)
hba = histogram(b_mmse,mmse_min:mmse_step:mmse_max);
hold on
haa = histogram(a_mmse,mmse_min:mmse_step:mmse_max);
hold off
grid on
xlim([mmse_min mmse_max])
set(gca,'XTick',mmse_min:4*mmse_step:mmse_max,'XTickLabel','')
set(gca,'Fontsize',14,'LineWidth',2)

subplot(3,4,4)
histogram(b_viscode_num,vis_min:vis_step:vis_max);
grid on
xlim([vis_min vis_max])
ylim([0 2*y_max2])
set(gca,'XTick',vis_min:2*vis_step:vis_max,'XTickLabel','')
set(gca,'YTick',0:2*y_step2:2*y_max2,'YTickLabel','')
set(gca,'Fontsize',14,'LineWidth',2)

subplot(3,4,5)
histogram(b_age_f,age_min:age_step:age_max);
hold on
histogram(a_age_f,age_min:age_step:age_max);
hold off
grid on
xlim([age_min age_max])
ylim([0 y_max2])
set(gca,'XTick',age_min+5:2*age_step:age_max,'XTickLabel','')
ylabel('Female Counts')
set(gca,'Fontsize',14,'LineWidth',2)

subplot(3,4,6)
histogram(b_weight_f,weight_min:weight_step:weight_max);
hold on
histogram(a_weight_f,weight_min:weight_step:weight_max);
hold off
grid on
xlim([weight_min weight_max])
ylim([0 y_max2])
set(gca,'XTick',weight_min:2*weight_step:weight_max,'XTickLabel','')
set(gca,'YTick',0:y_step2:y_max2,'YTickLabel','')
set(gca,'Fontsize',14,'LineWidth',2)

subplot(3,4,7)
histogram(b_mmse_f,mmse_min:mmse_step:mmse_max);
hold on
histogram(a_mmse_f,mmse_min:mmse_step:mmse_max);
hold off
grid on
xlim([mmse_min mmse_max])
set(gca,'XTick',mmse_min:4*mmse_step:mmse_max,'XTickLabel','')
set(gca,'Fontsize',14,'LineWidth',2)

subplot(3,4,8)
histogram(b_viscode_num_f,vis_min:vis_step:vis_max);
grid on
xlim([vis_min vis_max])
ylim([0 80])
set(gca,'XTick',vis_min:2*vis_step:vis_max,'XTickLabel','')
set(gca,'YTick',0:20:80,'YTickLabel','')
set(gca,'Fontsize',14,'LineWidth',2)

subplot(3,4,9)
histogram(b_age_m,age_min:age_step:age_max);
hold on
histogram(a_age_m,age_min:age_step:age_max);
hold off
grid on
xlim([age_min age_max])
ylim([0 y_max2])
set(gca,'XTick',age_min+5:2*age_step:age_max,'XTickLabel',age_min+5:2*age_step:age_max)
xlabel('Age [y.o.]')  
ylabel('Male Counts')
set(gca,'Fontsize',14,'LineWidth',2)

subplot(3,4,10)
histogram(b_weight_m,weight_min:weight_step:weight_max);
hold on
histogram(a_weight_m,weight_min:weight_step:weight_max);
hold off
grid on
xlim([weight_min weight_max])
ylim([0 y_max2])
set(gca,'XTick',weight_min:2*weight_step:weight_max,'XTickLabel',weight_min:2*weight_step:weight_max)
xlabel('Weight [kg]')
set(gca,'YTick',0:y_step2:y_max2,'YTickLabel','')
set(gca,'Fontsize',14,'LineWidth',2)

subplot(3,4,11)
histogram(b_mmse_m,mmse_min:mmse_step:mmse_max);
hold on
histogram(a_mmse_m,mmse_min:mmse_step:mmse_max);
hold off
grid on
xlim([mmse_min mmse_max])
set(gca,'XTick',mmse_min:4*mmse_step:mmse_max,'XTickLabel',mmse_min:4*mmse_step:mmse_max)
xlabel('MMSE')
set(gca,'Fontsize',14,'LineWidth',2)

subplot(3,4,12)
histogram(b_viscode_num_m,vis_min:vis_step:vis_max);
grid on
xlim([vis_min vis_max])
ylim([0 50])
set(gca,'XTick',vis_min:2*vis_step:vis_max,'XTickLabel',vis_min:2*vis_step:vis_max)
set(gca,'YTick',0:10:50,'YTickLabel','')
xlabel('Visit [months]')
set(gca,'Fontsize',14,'LineWidth',2)

%% MMSE MATCHING
age_max_limit = age_max;
match_pos = b_mmse>=min(a_mmse) & b_age<=age_max_limit & strcmp(b_race,'White') & strcmp(b_ethnicity,'Not Hisp/Latino');

adni_matched = adni(match_pos,:);

match_adni_names = {'Subject ID' 'VISCODE' 'Sex' 'Age' 'Weight' 'MMSE' 'DX' 'APOE4' 'APOE2COUNT' 'APOE3COUNT' 'PTEDUCAT' 'PTMARRY' 'MH14ALCH' 'MH16SMOK' 'HMHYPERT'};
match_adni = cell(0,0);
for ind = 1:size(match_adni_names,2)
    match_adni(:,ind) = table2cell( adni(match_pos,strcmp(adni_names,match_adni_names{1,ind})) );
end



b_age = cell2mat(match_adni(:,strcmp(match_adni_names,'Age')));
b_sex = match_adni(:,strcmp(match_adni_names,'Sex'));
b_weight = cell2mat(match_adni(:,strcmp(match_adni_names,'Weight')));
b_weight(b_weight==0) = NaN;
b_mmse = cell2mat(match_adni(:,strcmp(match_adni_names,'MMSE')));
b_apoe2 = cell2mat(match_adni(:,strcmp(match_adni_names,'APOE2COUNT')));
b_apoe3 = cell2mat(match_adni(:,strcmp(match_adni_names,'APOE3COUNT')));
b_apoe4 = cell2mat(match_adni(:,strcmp(match_adni_names,'APOE4')));
b_education = cell2mat(match_adni(:,strcmp(match_adni_names,'PTEDUCAT')));
b_alcohol = cell2mat(match_adni(:,strcmp(match_adni_names,'MH14ALCH')));
b_smoking = cell2mat(match_adni(:,strcmp(match_adni_names,'MH16SMOK')));
b_hypertension = cell2mat(match_adni(:,strcmp(match_adni_names,'HMHYPERT')));


match_stat{1,2} = 'ADAI';
match_stat{1,6} = 'ADNI';
match_stat{1,10} = 'p';

match_stat{2,2} = 'Mean';
match_stat{2,3} = 'STD / %';
match_stat{2,4} = 'Min';
match_stat{2,5} = 'Max';
match_stat{2,6} = 'Mean';
match_stat{2,7} = 'STD / %';
match_stat{2,8} = 'Min';
match_stat{2,9} = 'Max';

match_stat{3,1} = 'Nsub';
match_stat{4,1} = 'Females';
match_stat{5,1} = 'Age [y]';
match_stat{6,1} = 'Weight [kg]';
match_stat{7,1} = 'MMSE';
match_stat{8,1} = 'Education [y]';
match_stat{9,1} = 'APOE2-0';
match_stat{10,1} = 'APOE2-1';
match_stat{11,1} = 'APOE2-2';
match_stat{12,1} = 'APOE3-0';
match_stat{13,1} = 'APOE3-1';
match_stat{14,1} = 'APOE3-2';
match_stat{15,1} = 'APOE4-0';
match_stat{16,1} = 'APOE4-1';
match_stat{17,1} = 'APOE4-2';
match_stat{18,1} = 'Hypertension-yes';
match_stat{19,1} = 'Hypertension-no';
match_stat{20,1} = 'Alcohol-yes';
match_stat{21,1} = 'Alcohol-no';
match_stat{22,1} = 'Smoking-yes';
match_stat{23,1} = 'Smoking-no';

match_stat{3,2} = size(a_age,1);
match_stat{3,6} = size(b_age,1);

match_stat{4,2} = sum(strcmp(a_sex,'F'));
match_stat{4,6} = sum(strcmp(b_sex,'F'));
match_stat{4,3} = [num2str(100*sum(strcmp(a_sex,'F'))/size(a_age,1),'%.1f') '%'];
match_stat{4,7} = [num2str(100*sum(strcmp(b_sex,'F'))/size(b_age,1),'%.1f') '%'];

match_stat{5,2} = mean(a_age,'omitnan');
match_stat{5,3} = std(a_age,'omitnan');
match_stat{5,4} = min(a_age);
match_stat{5,5} = max(a_age);
match_stat{5,6} = mean(b_age,'omitnan');
match_stat{5,7} = std(b_age,'omitnan');
match_stat{5,8} = min(b_age);
match_stat{5,9} = max(b_age);
[~, match_stat{5,10}] = ttest2(a_age,b_age);

match_stat{6,2} = mean(a_weight,'omitnan');
match_stat{6,3} = std(a_weight,'omitnan');
match_stat{6,4} = min(a_weight);
match_stat{6,5} = max(a_weight);
match_stat{6,6} = mean(b_weight,'omitnan');
match_stat{6,7} = std(b_weight,'omitnan');
match_stat{6,8} = min(b_weight);
match_stat{6,9} = max(b_weight);
[~, match_stat{6,10}] = ttest2(a_weight,b_weight);

match_stat{7,2} = mean(a_mmse,'omitnan');
match_stat{7,3} = std(a_mmse,'omitnan');
match_stat{7,4} = min(a_mmse);
match_stat{7,5} = max(a_mmse);
match_stat{7,6} = mean(b_mmse,'omitnan');
match_stat{7,7} = std(b_mmse,'omitnan');
match_stat{7,8} = min(b_mmse);
match_stat{7,9} = max(b_mmse);
[~, match_stat{7,10}] = ttest2(a_mmse,b_mmse);

match_stat{8,2} = mean(a_education,'omitnan');
match_stat{8,3} = std(a_education,'omitnan');
match_stat{8,4} = min(a_education);
match_stat{8,5} = max(a_education);
match_stat{8,6} = mean(b_education,'omitnan');
match_stat{8,7} = std(b_education,'omitnan');
match_stat{8,8} = min(b_education);
match_stat{8,9} = max(b_education);
[~, match_stat{8,10}] = ttest2(a_education,b_education);

match_stat{9,2} = sum(a_apoe2==0);
match_stat{9,6} = sum(b_apoe2==0);
match_stat{9,3} = [num2str(100*sum(a_apoe2==0)/size(a_age,1),'%.1f') '%'];
match_stat{9,7} = [num2str(100*sum(b_apoe2==0)/size(b_age,1),'%.1f') '%'];

match_stat{10,2} = sum(a_apoe2==1);
match_stat{10,6} = sum(b_apoe2==1);
match_stat{10,3} = [num2str(100*sum(a_apoe2==1)/size(a_age,1),'%.1f') '%'];
match_stat{10,7} = [num2str(100*sum(b_apoe2==1)/size(b_age,1),'%.1f') '%'];

match_stat{11,2} = sum(a_apoe2==2);
match_stat{11,6} = sum(b_apoe2==2);
match_stat{11,3} = [num2str(100*sum(a_apoe2==2)/size(a_age,1),'%.1f') '%'];
match_stat{11,7} = [num2str(100*sum(b_apoe2==2)/size(b_age,1),'%.1f') '%'];

match_stat{12,2} = sum(a_apoe3==0);
match_stat{12,6} = sum(b_apoe3==0);
match_stat{12,3} = [num2str(100*sum(a_apoe3==0)/size(a_age,1),'%.1f') '%'];
match_stat{12,7} = [num2str(100*sum(b_apoe3==0)/size(b_age,1),'%.1f') '%'];

match_stat{13,2} = sum(a_apoe3==1);
match_stat{13,6} = sum(b_apoe3==1);
match_stat{13,3} = [num2str(100*sum(a_apoe3==1)/size(a_age,1),'%.1f') '%'];
match_stat{13,7} = [num2str(100*sum(b_apoe3==1)/size(b_age,1),'%.1f') '%'];

match_stat{14,2} = sum(a_apoe3==2);
match_stat{14,6} = sum(b_apoe3==2);
match_stat{14,3} = [num2str(100*sum(a_apoe3==2)/size(a_age,1),'%.1f') '%'];
match_stat{14,7} = [num2str(100*sum(b_apoe3==2)/size(b_age,1),'%.1f') '%'];

match_stat{15,2} = sum(a_apoe4==0);
match_stat{15,6} = sum(b_apoe4==0);
match_stat{15,3} = [num2str(100*sum(a_apoe4==0)/size(a_age,1),'%.1f') '%'];
match_stat{15,7} = [num2str(100*sum(b_apoe4==0)/size(b_age,1),'%.1f') '%'];

match_stat{16,2} = sum(a_apoe4==1);
match_stat{16,6} = sum(b_apoe4==1);
match_stat{16,3} = [num2str(100*sum(a_apoe4==1)/size(a_age,1),'%.1f') '%'];
match_stat{16,7} = [num2str(100*sum(b_apoe4==1)/size(b_age,1),'%.1f') '%'];

match_stat{17,2} = sum(a_apoe4==2);
match_stat{17,6} = sum(b_apoe4==2);
match_stat{17,3} = [num2str(100*sum(a_apoe4==2)/size(a_age,1),'%.1f') '%'];
match_stat{17,7} = [num2str(100*sum(b_apoe4==2)/size(b_age,1),'%.1f') '%'];

match_stat{18,2} = sum(a_hypertension==1);
match_stat{18,6} = sum(b_hypertension==1);
match_stat{18,3} = [num2str(100*sum(a_hypertension==1)/size(a_age,1),'%.1f') '%'];
match_stat{18,7} = [num2str(100*sum(b_hypertension==1)/size(b_age,1),'%.1f') '%'];

match_stat{19,2} = sum(a_hypertension==0);
match_stat{19,6} = sum(b_hypertension==0);
match_stat{19,3} = [num2str(100*sum(a_hypertension==0)/size(a_age,1),'%.1f') '%'];
match_stat{19,7} = [num2str(100*sum(b_hypertension==0)/size(b_age,1),'%.1f') '%'];

match_stat{20,2} = sum(a_alcohol==1);
match_stat{20,6} = sum(b_alcohol==1);
match_stat{20,3} = [num2str(100*sum(a_alcohol==1)/size(a_age,1),'%.1f') '%'];
match_stat{20,7} = [num2str(100*sum(b_alcohol==1)/size(b_age,1),'%.1f') '%'];

match_stat{21,2} = sum(a_alcohol==0);
match_stat{21,6} = sum(b_alcohol==0);
match_stat{21,3} = [num2str(100*sum(a_alcohol==0)/size(a_age,1),'%.1f') '%'];
match_stat{21,7} = [num2str(100*sum(b_alcohol==0)/size(b_age,1),'%.1f') '%'];

match_stat{22,2} = sum(a_smoking==1);
match_stat{22,6} = sum(b_smoking==1);
match_stat{22,3} = [num2str(100*sum(a_smoking==1)/size(a_age,1),'%.1f') '%'];
match_stat{22,7} = [num2str(100*sum(b_smoking==1)/size(b_age,1),'%.1f') '%'];

match_stat{23,2} = sum(a_smoking==0);
match_stat{23,6} = sum(b_smoking==0);
match_stat{23,3} = [num2str(100*sum(a_smoking==0)/size(a_age,1),'%.1f') '%'];
match_stat{23,7} = [num2str(100*sum(b_smoking==0)/size(b_age,1),'%.1f') '%'];



% h(3).fig = figure(3);
% set(h(3).fig,'Position',[50 50 1900 1200]);
% 
% subplot(3,4,1)
% histogram(b_age,age_min:age_step:age_max_limit);
% hold on
% histogram(a_age,age_min:age_step:age_max_limit);
% text(1.04*age_min,0.94*y_max2,'ADAI:','FontSize',12,'Color',clr_orange,'FontWeight','bold')
% text(1.04*age_min,0.87*y_max2,[ num2str(size(a_age,1)) ' subjects'],'FontSize',12,'Color',clr_orange)
% text(1.04*age_min,0.80*y_max2,[ num2str(sum(strcmp(a_sex,'F'))) ' females'],'FontSize',12,'Color',clr_orange)
% text(0.99*age_max_limit,0.94*y_max2,'ADNI:','FontSize',12,'Color',clr_lightblue,'HorizontalAlignment','Right','FontWeight','bold')
% text(0.99*age_max_limit,0.87*y_max2,[ num2str(size(b_age,1)) ' subjects'],'FontSize',12,'Color',clr_lightblue,'HorizontalAlignment','Right')
% text(0.99*age_max_limit,0.80*y_max2,[ num2str(sum(strcmp(b_sex,'F'))) ' females'],'FontSize',12,'Color',clr_lightblue,'HorizontalAlignment','Right')
% hold off
% grid on
% xlim([age_min age_max_limit])
% ylim([0 y_max2])
% set(gca,'XTick',age_min+5:2*age_step:age_max_limit,'XTickLabel','')
% ylabel('Counts')
% set(gca,'Fontsize',14,'LineWidth',2)
