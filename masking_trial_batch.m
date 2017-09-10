
path='/Volumes/SAMSUNG 1/MSc_PhD/DTI_Analysis/T2_masks_orig_multiply_manually_zero_registered';
scans= fuf([path '/*T2.nii'],'detail');

for i=1:length(scans)
    mask=load_untouch_nii(scans{i});
    mask_img=mask.img;
    threshold = 2000;
    mask_img(mask_img <= threshold) = 0;
    mask.img=mask_img;
    save_untouch_nii(mask,[mask.fileprefix '_masked.nii']);
    
end

