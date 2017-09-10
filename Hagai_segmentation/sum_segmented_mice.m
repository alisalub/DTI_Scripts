%% General parametes
path = '/Volumes/SAMSUNG 1/MSc_PhD/DTI_Analysis/T2_masks_orig_multiply_manually_zero_registered/registered_T2_masked_2000_aniso_smooth';
cd(path)
resolution = 0.16^3;

cur_dir = dir(path);
cur_dir_file_names = string({cur_dir.name}');  % names of all files in folder

mice = find_all_mice_tags(path);
scans = {'scan1', 'scan2', 'scan3', 'scan4', 'scan5', 'scan6', 'scan7'}';
ps = {'p4', 'p5', 'p6'};
sum_data = containers.Map;
scan_data = cell(size(scans));
scan_idx = 1;
mouse_idx = 1;
mice_array = cell(size(mice));

%% Main loop iterates over the data and creates the final cell array

for mouse = mice'
    files_of_mouse = cur_dir_file_names(contains(cur_dir_file_names, mouse));
    if size(files_of_mouse, 1) ~= 0
        for scan = scans'
           relevant_files = files_of_mouse(contains(files_of_mouse, scan));  % only files containing 'scanX' in their filename
           if size(relevant_files, 1) ~= 0
               for p = ps
                    tot_sum = sum_through_scans(path, relevant_files, p);
                    sum_data(p{1}) = tot_sum;
               end
               scan_data{scan_idx} = sum_data;
               sum_data = containers.Map;
           end
          scan_idx = scan_idx + 1;
        end
        mice_array{mouse_idx} = scan_data;
        scan_data = cell(size(scans));
        scan_idx = 1;
    end
    mouse_idx = mouse_idx + 1;
end

%% Unpack data for display purposes

mice_num = max(size(mice_array));
scan_num = max(size(scans));
[white_matter, gray_matter, csf] = unpack_scan_types(mice_array, mice_num, scan_num);

%% Display data
display_mice_data(white_matter, 'White matter');
display_mice_data(gray_matter, 'Gray matter');
display_mice_data(csf, 'CSF');
