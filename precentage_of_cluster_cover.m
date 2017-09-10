%exrtact the precentage of the affected area. 
%the amount of voxels that underwent significant (p_val) change 

%% Load a specific brain with parameters
p_val = 0.05;
work_dir = '/Volumes/SAMSUNG/MSc_PhD/DTI_Analysis/WSK_allscans_analysis/WSK_Native_FA_MD_T2_not_pi10/smoothed_with_04/';
file = 'WT_VS_SH_16mice_p_main_Between_WTvsSH_0.05_FA.nii';
filename_cur = [work_dir, file];
nii = load_untouch_nii(filename_cur);
sig_vox_with_value = nii.img;
sig_vox = zeros(size(sig_vox_with_value));
sig_vox(sig_vox_with_value > 0) = 1;

%% Load the average mask
avg_file = 'mask_3000.nii';
filename_avg = [work_dir, avg_file];
nii_avg = load_untouch_nii(filename_avg);
brainwide_mask = double(nii_avg.img);

if ~isequal(unique(brainwide_mask), [0; 1])
    error('Problem with brainwide_mask values.')
end

highest_planar = size(brainwide_mask, 1);
highest_z = size(brainwide_mask, 3);

%%
rel_vox = brainwide_mask .* sig_vox;

%% Parameters for brain cross-sections
brain_sections = struct('name', {}, 'x_low', {}, 'x_high', {}, ...
                        'y_low', {}, 'y_high', {}, ...
                        'z_low', {}, 'z_high', {});
brain_sections(1) = brain_section_constructor('Contralateral', ...
                                              1, 54, ...
                                              1, highest_planar, ...
                                              1, highest_z);
brain_sections(2) = brain_section_constructor('Ipsi Anterior', ...
                                              55, highest_planar, ...
                                              1, 60, ...
                                              1, 33);
brain_sections(3) = brain_section_constructor('Ipsi Posterior', ...
                                              55, highest_planar, ...
                                              75, highest_planar, ...
                                              1, 33);
brain_sections(4) = brain_section_constructor('Occlusion', ...
                                              55, highest_planar, ...
                                              60, 75, ...
                                              33, highest_z);
                                          
%% Go through the sections and calculate the percentage
percentage_of_sig_voxels = zeros(size(brain_sections));
x_labels = cell(1, length(brain_sections));
for idx = 1:length(brain_sections)
   rel_vox_in_section = slice_brain(brain_sections(idx), rel_vox);
   brainwide_mask_section = slice_brain(brain_sections(idx), brainwide_mask);
   
   num_of_sig_voxels = sum(sum(sum(rel_vox_in_section)));
   num_of_voxels = sum(sum(sum(brainwide_mask_section)));
   
   percentage_of_sig_voxels(idx) = num_of_sig_voxels / num_of_voxels * 100;
   
   x_labels{idx} = brain_sections(idx).name;
end

%% Plot results
bar(percentage_of_sig_voxels);
xticklabels(x_labels);
title(file, 'Interpreter', 'none');
ylabel('Percentage');

%% Save
save([work_dir, file(1:end-4), '_percent.mat'], 'percentage_of_sig_voxels');
