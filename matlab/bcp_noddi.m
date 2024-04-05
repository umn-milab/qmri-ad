function bcp_noddi(data_dir,mask)
%BCP_NODDI help....
% text text text
%


% addpath(genpath('/home/range1-raid1/labounek/toolbox/matlab/nifti_matlab-master'))
% addpath(genpath('/home/range1-raid1/labounek/toolbox/matlab/NODDI_toolbox_v1.05'))


CreateROI(fullfile(data_dir,'NODDI_DWI.nii'), fullfile(data_dir,[mask '.nii']), fullfile(data_dir,'matlab-toolbox','NODDI_roi.mat'));

protocol = FSL2Protocol(fullfile(data_dir,'NODDI_protocol.bval'), fullfile(data_dir,'NODDI_protocol.bvec'),15);

save(fullfile(data_dir,'protocol.mat'),'protocol')

noddi = MakeModel('WatsonSHStickTortIsoV_B0');

batch_fitting(fullfile(data_dir,'matlab-toolbox','NODDI_roi.mat'), protocol, noddi,  fullfile(data_dir,'matlab-toolbox','FittedParams.mat'), 16);
% batch_fitting_single('NODDI_roi.mat', protocol, noddi, 'FittedParams.mat');

SaveParamsAsNIfTI(fullfile(data_dir,'matlab-toolbox','FittedParams.mat'), fullfile(data_dir,'matlab-toolbox','NODDI_roi.mat'), fullfile(data_dir,'roi_mask.nii'), fullfile(data_dir,'matlab-toolbox','FIT'))
