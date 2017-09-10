function [ sum_of_pixels ] = sum_through_scans( path, relevant_files, file_contains )
% Finds all files that end with a string in a folder, and sums up all
% pixels that are larger than a specific threshold.

    file_name = relevant_files(contains(relevant_files, file_contains));
    cur_niifile = load_untouch_nii(fullfile(path, char(file_name)));
    cur_img = cur_niifile.img;
    sum_of_pixels = nansum(nansum(nansum(cur_img)));  % Using NANSUM since the data is read with NaNs instead of zeros.
end

