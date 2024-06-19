function bcp_bedpostx2trackvis(data_folder)
    bedpostx_folder=[data_folder '.bedpostX'];
    noddi_folder=fullfile(data_folder,'NODDI','matlab-toolbox');
    
    cd(data_folder)
    MD = load_untouch_nii('dti_MD.nii.gz');
    AD = load_untouch_nii('dti_AD.nii.gz');
    RD = load_untouch_nii('dti_RD.nii.gz');
    FA = load_untouch_nii('dti_FA.nii.gz');
	t1 = load_untouch_nii('dmri_mprage.nii.gz');
	t1nn = load_untouch_nii('dmri_mprage_nn.nii.gz');
    
    cd(bedpostx_folder)
    theta1 = load_untouch_nii('mean_th1samples.nii.gz');
    theta2 = load_untouch_nii('mean_th2samples.nii.gz');
    theta3 = load_untouch_nii('mean_th3samples.nii.gz');
    phi1 = load_untouch_nii('mean_ph1samples.nii.gz');
    phi2 = load_untouch_nii('mean_ph2samples.nii.gz');
    phi3 = load_untouch_nii('mean_ph3samples.nii.gz');
    f1 = load_untouch_nii('mean_f1samples.nii.gz');
    f2 = load_untouch_nii('mean_f2samples.nii.gz');
    f3 = load_untouch_nii('mean_f3samples.nii.gz');
    fsum = load_untouch_nii('mean_fsumsamples.nii.gz');
    d = load_untouch_nii('mean_dsamples.nii.gz');
    f1dispersion = load_untouch_nii('dyads1_dispersion.nii.gz');
    f2dispersion = load_untouch_nii('dyads2_dispersion.nii.gz');
    f3dispersion = load_untouch_nii('dyads3_dispersion.nii.gz');
    
    cd(noddi_folder)
    kappa = load_untouch_nii('FIT_kappa.nii.gz');
    ficvf = load_untouch_nii('FIT_ficvf.nii.gz');
    odi = load_untouch_nii('FIT_odi.nii.gz');
    fiso = load_untouch_nii('FIT_fiso.nii.gz');
    
    
    fib.dimension = size(f1.img);
    fib.voxel_size = f1.hdr.dime.pixdim(2:4);
    fib.fa0 = double(reshape(f1.img,1,[]));
    fib.fa1 = double(reshape(f2.img,1,[]));
    fib.fa2 = double(reshape(f3.img,1,[]));
    fib.dir0(1,:,:,:) = sin(theta1.img).*cos(phi1.img);
    fib.dir0(2,:,:,:) = sin(theta1.img).*sin(phi1.img);
    fib.dir0(3,:,:,:) = cos(theta1.img);
    fib.dir1(1,:,:,:) = sin(theta2.img).*cos(phi2.img);
    fib.dir1(2,:,:,:) = sin(theta2.img).*sin(phi2.img);
    fib.dir1(3,:,:,:) = cos(theta2.img);
    fib.dir2(1,:,:,:) = sin(theta3.img).*cos(phi3.img);
    fib.dir2(2,:,:,:) = sin(theta3.img).*sin(phi3.img);
    fib.dir2(3,:,:,:) = cos(theta3.img);
    fib.dir0 = double(reshape(fib.dir0,3,[]));
    fib.dir1 = double(reshape(fib.dir1,3,[]));
    fib.dir2 = double(reshape(fib.dir2,3,[]));
    
    
    fib.FA = double(reshape(FA.img,1,[]));
    fib.fsum = double(reshape(fsum.img,1,[]));
    fib.AD = double(reshape(AD.img,1,[]));
    fib.MD = double(reshape(MD.img,1,[]));
    fib.RD = double(reshape(RD.img,1,[]));
    fib.d = double(reshape(d.img,1,[]));
    fib.kappa = double(reshape(kappa.img,1,[]));
    fib.ficvf = double(reshape(ficvf.img,1,[]));
    fib.fiso= double(reshape(fiso.img,1,[]));
    fib.odi = double(reshape(odi.img,1,[]));
    fib.f1dispersion = double(reshape(f1dispersion.img,1,[]));
    fib.f2dispersion = double(reshape(f2dispersion.img,1,[]));
    fib.f3dispersion = double(reshape(f3dispersion.img,1,[]));
	fib.t1 = double(reshape(t1.img,1,[]));
	fib.t1nn = double(reshape(t1nn.img,1,[]));
    
    % flip xy: you may need to make sure that this orientation is correct
    % do not flip RL orientatzion
    fib.fa0 = reshape(fib.fa0,fib.dimension);
    fib.fa0 = fib.fa0(:,fib.dimension(2):-1:1,:);
    fib.fa0 = reshape(fib.fa0,1,[]);

    fib.fa1 = reshape(fib.fa1,fib.dimension);
    fib.fa1 = fib.fa1(:,fib.dimension(2):-1:1,:);
    fib.fa1 = reshape(fib.fa1,1,[]);

    fib.fa2 = reshape(fib.fa2,fib.dimension);
    fib.fa2 = fib.fa2(:,fib.dimension(2):-1:1,:);
    fib.fa2 = reshape(fib.fa2,1,[]);

    fib.dir0 = reshape(fib.dir0,[3 fib.dimension]);
    fib.dir0 = fib.dir0(:,:,fib.dimension(2):-1:1,:);
    fib.dir0(2,:,:,:) = -fib.dir0(2,:,:,:);
    fib.dir0 = reshape(fib.dir0,3,[]);

    fib.dir1 = reshape(fib.dir1,[3 fib.dimension]);
    fib.dir1 = fib.dir1(:,:,fib.dimension(2):-1:1,:);
    fib.dir1(2,:,:,:) = -fib.dir1(2,:,:,:);
    fib.dir1 = reshape(fib.dir1,3,[]);

    fib.dir2 = reshape(fib.dir2,[3 fib.dimension]);
    fib.dir2 = fib.dir2(:,:,fib.dimension(2):-1:1,:);
    fib.dir2(2,:,:,:) = -fib.dir2(2,:,:,:);
    fib.dir2 = reshape(fib.dir2,3,[]);

    fib.FA = reshape(fib.FA,fib.dimension);
    fib.FA = fib.FA(:,fib.dimension(2):-1:1,:);
    fib.FA = reshape(fib.FA,1,[]);
    
    fib.fsum = reshape(fib.fsum,fib.dimension);
    fib.fsum = fib.fsum(:,fib.dimension(2):-1:1,:);
    fib.fsum = reshape(fib.fsum,1,[]);
    
    fib.AD = reshape(fib.AD,fib.dimension);
    fib.AD = fib.AD(:,fib.dimension(2):-1:1,:);
    fib.AD = reshape(fib.AD,1,[]);
    
    fib.MD = reshape(fib.MD,fib.dimension);
    fib.MD = fib.MD(:,fib.dimension(2):-1:1,:);
    fib.MD = reshape(fib.MD,1,[]);
    
    fib.RD = reshape(fib.RD,fib.dimension);
    fib.RD = fib.RD(:,fib.dimension(2):-1:1,:);
    fib.RD = reshape(fib.RD,1,[]);
    
    fib.d = reshape(fib.d,fib.dimension);
    fib.d = fib.d(:,fib.dimension(2):-1:1,:);
    fib.d = reshape(fib.d,1,[]);
    
    fib.kappa = reshape(fib.kappa,fib.dimension);
    fib.kappa = fib.kappa(:,fib.dimension(2):-1:1,:);
    fib.kappa = reshape(fib.kappa,1,[]);
    
    fib.ficvf = reshape(fib.ficvf,fib.dimension);
    fib.ficvf = fib.ficvf(:,fib.dimension(2):-1:1,:);
    fib.ficvf = reshape(fib.ficvf,1,[]);
    
    fib.odi = reshape(fib.odi,fib.dimension);
    fib.odi = fib.odi(:,fib.dimension(2):-1:1,:);
    fib.odi = reshape(fib.odi,1,[]);
    
    fib.fiso = reshape(fib.fiso,fib.dimension);
    fib.fiso = fib.fiso(:,fib.dimension(2):-1:1,:);
    fib.fiso = reshape(fib.fiso,1,[]);
    
    fib.f1dispersion = reshape(fib.f1dispersion,fib.dimension);
    fib.f1dispersion = fib.f1dispersion(:,fib.dimension(2):-1:1,:);
    fib.f1dispersion = reshape(fib.f1dispersion,1,[]);
    
    fib.f2dispersion = reshape(fib.f2dispersion,fib.dimension);
    fib.f2dispersion = fib.f2dispersion(:,fib.dimension(2):-1:1,:);
    fib.f2dispersion = reshape(fib.f2dispersion,1,[]);
    
    fib.f3dispersion = reshape(fib.f3dispersion,fib.dimension);
    fib.f3dispersion = fib.f3dispersion(:,fib.dimension(2):-1:1,:);
    fib.f3dispersion = reshape(fib.f3dispersion,1,[]);

	fib.t1 = reshape(fib.t1,fib.dimension);
    fib.t1 = fib.t1(:,fib.dimension(2):-1:1,:);
    fib.t1 = reshape(fib.t1,1,[]);

	fib.t1nn = reshape(fib.t1nn,fib.dimension);
    fib.t1nn = fib.t1nn(:,fib.dimension(2):-1:1,:);
    fib.t1nn = reshape(fib.t1nn,1,[]);

%     % flip xy: you may need to make sure that this orientation is correct
%     fib.fa0 = reshape(fib.fa0,fib.dimension);
%     fib.fa0 = fib.fa0(fib.dimension(1):-1:1,fib.dimension(2):-1:1,:);
%     fib.fa0 = reshape(fib.fa0,1,[]);
% 
%     fib.fa1 = reshape(fib.fa1,fib.dimension);
%     fib.fa1 = fib.fa1(fib.dimension(1):-1:1,fib.dimension(2):-1:1,:);
%     fib.fa1 = reshape(fib.fa1,1,[]);
% 
%     fib.fa2 = reshape(fib.fa2,fib.dimension);
%     fib.fa2 = fib.fa2(fib.dimension(1):-1:1,fib.dimension(2):-1:1,:);
%     fib.fa2 = reshape(fib.fa2,1,[]);
% 
%     fib.dir0 = reshape(fib.dir0,[3 fib.dimension]);
%     fib.dir0 = fib.dir0(:,fib.dimension(1):-1:1,fib.dimension(2):-1:1,:);
%     fib.dir0(3,:,:,:) = -fib.dir0(3,:,:,:);
%     fib.dir0 = reshape(fib.dir0,3,[]);
% 
%     fib.dir1 = reshape(fib.dir1,[3 fib.dimension]);
%     fib.dir1 = fib.dir1(:,fib.dimension(1):-1:1,fib.dimension(2):-1:1,:);
%     fib.dir1(3,:,:,:) = -fib.dir1(3,:,:,:);
%     fib.dir1 = reshape(fib.dir1,3,[]);
% 
%     fib.dir2 = reshape(fib.dir2,[3 fib.dimension]);
%     fib.dir2 = fib.dir2(:,fib.dimension(1):-1:1,fib.dimension(2):-1:1,:);
%     fib.dir2(3,:,:,:) = -fib.dir2(3,:,:,:);
%     fib.dir2 = reshape(fib.dir2,3,[]);

    save(fullfile(data_folder,'dsistudio','bedpostX.fib'), '-struct','fib','-v4');
end
