function Mean_FA_update (FA_path)
%This script creates an FA mean image (for later to be used for
%normalization)

%in order to activate correctly this script you need to: (via SPM-add spm to matlab path)
% a. organize a folder with all the files you want to average
% b. in line: d = dir([relevantDir,'/*.nii'])- change the endings of the
%    files you want to average
% c. in line: matlabbatch{1}.spm.util.imcalc.output = - change it to the
%    file name you want the mean image to be named. 
% d. in line: matlabbatch{1}.spm.util.imcalc.outdir - change it to the
%    output folder you want the mean image to be create in. 

%Input: the path of the folder you organized in a.

% check if user input is needed or use value given 
if isempty(FA_path)
    relevantDir = uigetdir();
else
    relevantDir = FA_path;
end

% find *.nii file in this directory (FA files in this case)  
d = dir([relevantDir,'/rT*FA*']);
Images=cell(length(d),1);

for i = 1:length(d)
    Images{i}=fullfile(relevantDir,d(i).name);% store data
    Images{i}=[Images{i},',1']; %insert ',1' for later SPM use
end

%%choose random n=50 scans in order to create the mean FA
N=50; %number of images you want to averege
rand_ind=randi(length(d),N,1); %choose randomly the N images to averege
ImagesN=cell(length(rand_ind),1);
for j = 1:length(rand_ind)
    ImagesN{j} =  Images{rand_ind(j)};  
end

%% DATA PROCESSING Steps
%Creating Mean image:
matlabbatch{1}.spm.util.imcalc.input = ImagesN; %input- the images you want to calculate 
matlabbatch{1}.spm.util.imcalc.output = 'rMean_FA_50N_nativeX10.nii'; %name for the new image
matlabbatch{1}.spm.util.imcalc.outdir = {'D:\HL_PreProcessing_NEW\NEW_Third_Try\MD2\native\'};%output path for the new file
matlabbatch{1}.spm.util.imcalc.expression = 'mean(X)'; %calculation
matlabbatch{1}.spm.util.imcalc.options.dmtx = 1;
matlabbatch{1}.spm.util.imcalc.options.mask = 0;
matlabbatch{1}.spm.util.imcalc.options.interp = 1;
matlabbatch{1}.spm.util.imcalc.options.dtype = 4;

% run the job: 
spm('defaults', 'FMRI');
spm_jobman('serial', matlabbatch, '', cell(0,1));


end
