function [white_matter, gray_matter, csf] = unpack_scan_types(mice_array, mice_num, scan_num)
% Receives a cell array containing all scans of all types, and separates it
% into three different arrays, each containing data for a single type of
% analysis - white matter, gray matter, or CSF.

mouse_idx = 1;
scan_idx = 1;
white_matter = nan(scan_num, mice_num);
gray_matter = nan(scan_num, mice_num);
csf = nan(scan_num, mice_num);

for mouse = mice_array'
   for scan = mouse{:}'
       if ~isempty(scan{1})
          white_matter(scan_idx, mouse_idx) = scan{1}('p4');
          gray_matter(scan_idx, mouse_idx) = scan{1}('p5');
          csf(scan_idx, mouse_idx) = scan{1}('p6');
          scan_idx = scan_idx + 1;
       end
   end
   scan_idx = 1;
   mouse_idx = mouse_idx + 1;
end

end