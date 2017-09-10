Nii=load_untouch_nii('WT_VS_KO_16mice_p_main_Within_scan1_5_0.05_MD.nii'); 
%X=Nii.img(:);
%max(X)
Nii.img(Nii.img>0.01)=0;
save_untouch_nii(Nii, 'WT_VS_KO_16mice_p_main_Within_scan1_5_0.01_MD.nii'); %saves the nii as >0.05=0');