Temp_Nii=load_untouch_nii('PBmask.nii');
Clust_Nii=load_untouch_nii('ALanovaMD1_ttest_cluster10.nii');
Clust_img=Clust_Nii.img;

Temp_img=Temp_Nii.img;
Temp_img_After=Temp_img;
Temp_img=mat2gray(Temp_img);
y=;
figure;
Temp_poly=roipoly(Temp_img(:,:,52));
%Temp_poly2=roipoly(Temp_img(:,:,16));
%imshow(Temp_poly);
Slice=Temp_img_After(:,:,z);
Slice(Temp_poly==1)=0;
%Slice(Temp_poly2==1)=0;
Temp_img_After(:,:,z)=Slice;
%imshow(Temp_img_After(:,:,z));
%imshow(Temp_img(:,:,16));

Temp_Nii.img=Temp_img_After;
save_untouch_nii(Temp_Nii,'HL347891012_107mice_p_main_interaction_0.025_FA10_clean.nii');

%%
R=load_untouch_nii('mT20HL4_C3S4_COND_nii_cropped_regularized_MD_C_native_mean_DWIs_masked_TRY.nii');
R.img(:,:,z)=Slice;
save_untouch_nii(R,'mT20HL4_C3S4_COND_nii_cropped_regularized_MD_C_native_mean_DWIs_masked_TRY.nii');

[a1 a2 a3]=size(Temp_img);
New_img=zeros(size(Temp_img));

for i=86:95
    for j=96:103
        for k=43:45
            if Clust_img(i,j,k)==16 
                New_img(i,j,k)=1;
            end
        end
    end
end

Temp_Nii.img=New_img;
save_untouch_nii(Temp_Nii,'MaskccMD.nii');
