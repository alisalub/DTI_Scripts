function maskCorrection(filename1,filename2)


nii = load_untouch_nii(filename1);
mask_nii = load_untouch_nii(filename2);
mask = mask_nii.img>0;
nii.img = nii.img .* mask;
NewFileName = [filename2(1:end-4) '_multiply_mask.nii'];
save_untouch_nii(nii,NewFileName);

end