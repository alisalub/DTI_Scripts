
path='/Volumes/SAMSUNG 1/MSc_PhD/DTI_Analysis/smoothed_allscans/scan1_scan5';
scans= fuf([path '/*geFA.nii'],'detail');

for i=1:length(scans)
    mask=load_untouch_nii(scans{i});
    mask_img=mask.img;
    threshold = 3000;
    mask_img(mask_img <= threshold) = 0;
    mask_img(mask_img > threshold) = 1;
    mask.img=mask_img;
    save_untouch_nii(mask,[mask.fileprefix '_masked.nii']);
%imshow(imadjust(mask_img(:,:,25)))

end