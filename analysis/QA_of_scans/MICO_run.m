% how to rum MICO segmentetion
% this is for single file
q=3;
iter_b=3; 
iterCM=3; 
iterNum_outer=30;  
N_region = 5;
tissueLabel=[1, 2, 3, 4, 5];
th_bg = 3000;

str_vector{1} = 'rHet3_scan1_nii_regularized_MD_C_native_T2_masked_Aniso_GS.nii';  

MICO_3Dseq(str_vector, N_region, q, th_bg, iterNum_outer, iter_b, iterCM, tissueLabel);
%it takes about 2 minutes for 1 file
%loop for all registered T2 scans

%we get this file that ends with seg 
% loop for all the  scans that end with 'seg'
i1=load_untouch_nii('rHet3_scan1_nii_regularized_MD_C_native_T2_masked_Aniso_GS_seg.nii');
im=i1.img;
im(find(im==2))=1;
im(find(im==3))=2;
im(find(im==4))=2;
im(find(im==5))=3;
i1.img=im;
%  we need to change it and name the new file seg2.
save_untouch_nii(i1,'rHet3_scan1_nii_regularized_MD_C_native_T2_masked_Aniso_GS_seg2.nii');

