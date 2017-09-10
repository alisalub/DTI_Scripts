Temp_Nii=load_untouch_nii('wPB6_scan2_nii_regularized_MD_C_native_DWIs_T2.nii');
Temp_img=Temp_Nii.img;
Temp_img_After=Temp_img;
Temp_img=mat2gray(Temp_img);
z=33;
figure;
Temp_poly=roipoly(Temp_img(:,:,z));
%Temp_poly2=roipoly(Temp_img(:,:,16));
%imshow(Temp_poly);
Slice=Temp_img_After(:,:,z);
Slice(Temp_poly==1)=0;
%Slice(Temp_poly2==1)=0;
Temp_img_After(:,:,z)=Slice;
%imshow(Temp_img_After(:,:,z));
%imshow(Temp_img(:,:,16));

Temp_Nii.img=Temp_img_After;
save_untouch_nii(Temp_Nii,'wPB6_scan2_nii_regularized_MD_C_native_DWIs_T278778.ni');

%%
R=load_untouch_nii('mT20HL4_C3S4_COND_nii_cropped_regularized_MD_C_native_mean_DWIs_masked_TRY.nii');
R.img(:,:,z)=Slice;
save_untouch_nii(R,'mT20HL4_C3S4_COND_nii_cropped_regularized_MD_C_native_mean_DWIs_masked_TRY.nii');