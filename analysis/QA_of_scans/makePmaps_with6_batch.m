path='/Volumes/SAMSUNG 1/MSc_PhD/DTI_Analysis/T2_masks_orig_multiply_manually_zero_registered/registered_T2_masked_2000_aniso_smooth/substraction';
thresh=0.1;
numGaus=6;
scans= fuf([path '/H*GS.nii'],'detail');

for i=1:length(scans)
    niifile=load_untouch_nii(scans{i});
    makePmaps_with6(niifile, thresh, numGaus)
end

