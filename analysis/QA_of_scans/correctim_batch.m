path=('/Volumes/SAMSUNG 1/MSc_PhD/DTI_Analysis/T2_masks_orig_multiply_manually_zero_registered/test2');

scans= fuf([path '/r*GS.nii'],'detail');

for i=1:length(scans)
    niifile=load_untouch_nii(scans{i});
    correctim(niifile)
end



