function MICO_run_batch

 path='/Volumes/SAMSUNG 1/MSc_PhD/DTI_Analysis/T2_masks_orig_multiply_manually_zero_registered/Hregistered_T2_masked_2000_smooth_correctim';
q=3;
iter_b=3; 
iterCM=3; 
iterNum_outer=30;  
N_region = 5;
tissueLabel=[1, 2, 3, 4, 5];
%th_bg = 5;
th_bg = 3000;

cur_dir = dir('*GS.nii');
cur_dir_file_names = string({cur_dir.name}');  % names of all files in folder

% for i=1:length(cur_dir_file_names)
%     niifile=load_untouch_nii(scans{i});
%     MICO_run()
% end

for i = 1:length(cur_dir_file_names)
    MICO_3Dseq(cur_dir_file_names(i), N_region, q, th_bg, iterNum_outer, iter_b, iterCM, tissueLabel);
end


