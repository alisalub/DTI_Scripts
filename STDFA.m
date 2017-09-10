
% create std dev map

nii_list = dir('sw*scan4*FA.nii');

for i=1:length(nii_list)
    tempim = load_untouch_nii(nii_list(i).name);
    IM(:,:,:,i) = tempim.img;
end

stdIM = tempim;
stdIM.img=std(IM,[],4);
stdIM.img(isnan(stdIM.img)) = 0;
save_untouch_nii(stdIM,'STD_FA_scan7.nii');