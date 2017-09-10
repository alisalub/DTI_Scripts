% 
% files = dir('*.nii');
% for i=1:length(files)
%     new_name = [files(i).name(1:10) '_nii_regularized_MD_C_native_masked.nii'];
%     movefile(files(i).name,new_name);
% end
% 

% % files = dir('*.nii');
% % for i=1:length(files)
% %     new_name = [files(i).name(4:12) '_nii_regularized_MD_C_native_T2.nii'];
% %     movefile(files(i).name,new_name);
% % end

% files = dir('*.txt');
% for i=1:length(files)
%     new_name = [files(i).name(1:10) '_nii_regularized_MD_C_native_B_matrix.txt'];
%     movefile(files(i).name,new_name);
% end
% 
files = dir('*mask.nii');
for i=1:length(files)
    new_name = [files(i).name(1:end-18) '.nii'];
    movefile(files(i).name,new_name);
end

% files = dir('*mask.nii');
% for i=1:length(files)
%     new_name = [files(i).name(4:end)];
%     movefile(files(i).name,new_name);
% end