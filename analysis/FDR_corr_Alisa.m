% correctedVec=FDR_corr(uncorrectedVec)
% function correctedVec=FDR_corr(uncorrectedVec)
% June 2016 - Ido & Hadas
% FDR correction: this functions gets a P_value vector and returns a
% corrected vector (using Benjamini & Hochberg 1995 FDR routine)

Map=load_nii('WT_VS_KO_16mice_p_main_Between_WTvsKO_FA.nii');
Map_name=Map.fileprefix;
Map_img=Map.img;
uncorrectedVec=Map_img(:);

alpha=0.05; % default FDR threshold, change for different thresholding

sortedVec=sort(uncorrectedVec(uncorrectedVec>0));
M = length(sortedVec); % total number of comparisons (without zeros)
sortedVec(:,2)=1:M;
sortedVec(:,2)=sortedVec(:,2).*alpha;
sortedVec(:,2)=sortedVec(:,2)./M;
sortedVec(:,3)=sortedVec(:,1)<sortedVec(:,2);

newThreshIDX = max(find(sortedVec(:,3)==1));
newThrsh = sortedVec(newThreshIDX,1);

correctedVec = uncorrectedVec;
correctedVec(correctedVec>newThrsh)=0;

voxel_size=[Map.hdr.dime.pixdim(2),Map.hdr.dime.pixdim(3),Map.hdr.dime.pixdim(4)]; %takes the vox size from the mask
P_imageTemp=reshape(correctedVec,size(Map.img)); %reshaps the P-vec imto the image matrix
    Nii = make_nii(P_imageTemp,voxel_size); %creats a nii image from the P-image 
    Nii.hdr.hist.originator=Map.hdr.hist.originator; %compare the origin of the P-image to the mask origin
    save_nii(Nii, [Map_name '_FDR.nii']); %saves the nii as is
