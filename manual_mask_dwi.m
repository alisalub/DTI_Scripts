i1=load_untouch_nii('PB2_scan2_nii_regularized_MD_C_native_DWIs.nii');
i2=load_untouch_nii('DmTPB2_scan2_nii_regularized_MD_C_native_mean_DWIs_masked.nii');
mask=i2.img;
mask(find(mask>0))=1;
mask=repmat(mask,[1 1 1 34]);
i1.img=i1.img.*int16(mask);
save_untouch_nii(i1, 'MPB2_scan2_nii_regularized_MD_C_native_DWIs_masked.nii')
