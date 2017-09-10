function Normalization(Path)
%This script Normalize the Images to the template (in our case: the mean
%mice FA)

%How to use the script: (via SPM-add spm to matlab path)
%A. input: Path=the path to the folder which you have the nii
%          files you already registered to the template.
%B. you can change the type of images you want write on in lines:23-40 (delete the ones you dont need or add others)
%   -> then change it accordingly in lines 42-61 -> and in line 75  
%C. create a source folder- put a copy of all your rFA images and write this folder path in sourceDir (line 20) 
%D. you need to change the path and the template you want to register to in
%lines: 68(path), 69(name+name of copy file) ,76(path+name of copy file),97(path),98(path+name of copy file) 

% check if user input is needed or use value given 
if isempty(Path)
    relevantDir = uigetdir();
else
    relevantDir = Path;
end
SourceDir= '/data/Alisa/DTI/WSK_allscans_analysis/exported_MD_FA_ko5_1_registered';

% find r*.nii file in this directory  - the scans after slice time
d1 = dir([relevantDir,'/rT*native_FA*.nii']); %FA img 
FA_images=cell(length(d1),1);
d2 = dir([relevantDir,'/rT*MD_C_native_*_native_MD.nii*']); %MD img
MD_images=cell(length(d2),1);
% d3 = dir([relevantDir,'/Tr*T2.nii']); %T2 img
% T2_images=cell(length(d3),1);
%d3 = dir([relevantDir,'/r*L1_X10.nii']);
%L1_images=cell(length(d3),1);
%d4 = dir([relevantDir,'/r*L2_X10.nii']);
%L2_images=cell(length(d4),1);
%d5 = dir([relevantDir,'/r*L3_X10.nii']);
%L3_images=cell(length(d5),1);
%d6 = dir([relevantDir,'/r*mean_B0*.nii']);
%MeanB0_images=cell(length(d6),1);
%d7 = dir([relevantDir,'/r*RD*.nii']);
%RD_images=cell(length(d7),1);
%d8 = dir([relevantDir,'/r*B0_FP*.nii']);
%B0_images=cell(length(d8),1);
d9 = dir([SourceDir,'/r*FA*']); %FA img -source folder 
Source_FA_images=cell(length(d9),1);

for i = 1:length(d1)
    FA_images{i}=fullfile(relevantDir,d1(i).name); % store data
        FA_images{i}=[FA_images{i},',1']; %insert ',1' for later SPM use
    MD_images{i}=fullfile(relevantDir,d2(i).name); % store data
        MD_images{i}=[MD_images{i},',1']; %insert ',1' for later SPM use
%     T2_images{i}=fullfile(relevantDir,d3(i).name); % store data
%         T2_images{i}=[T2_images{i},',1']; %insert ',1' for later SPM use
    %L2_images{i}=fullfile(relevantDir,d4(i).name); % store data
        %L2_images{i}=[L2_images{i},',1']; %insert ',1' for later SPM use
    %L3_images{i}=fullfile(relevantDir,d5(i).name); % store data
        %L3_images{i}=[L3_images{i},',1']; %insert ',1' for later SPM use
    %MeanB0_images{i}=fullfile(relevantDir,d6(i).name); % store data
        %MeanB0_images{i}=[MeanB0_images{i},',1']; %insert ',1' for later SPM use
    %RD_images{i}=fullfile(relevantDir,d7(i).name); % store data
        %RD_images{i}=[RD_images{i},',1']; %insert ',1' for later SPM use
%     B0_images{i}=fullfile(relevantDir,d8(i).name); % store data
%         B0_images{i}=[B0_images{i},',1']; %insert ',1' for later SPM use
    Source_FA_images{i}=fullfile(SourceDir,d9(i).name); % store data
        Source_FA_images{i}=[Source_FA_images{i},',1']; %insert ',1' for later SPM use
end

%% DATA PROCESSING Steps

for j=1:length(FA_images) 
    
% copy the template (for later use)
cd('/data/Alisa/DTI/WSK_allscans_analysis/exported_MD_FA_ko5_1_registered')
copyfile('Mean_FA.nii','Mean_FA_COPY.nii')

cd(Path)
%Normaliztion stages via SPM:
matlabbatch{1}.spm.spatial.normalise.estwrite.subj.source = {Source_FA_images{j}};
matlabbatch{1}.spm.spatial.normalise.estwrite.subj.wtsrc = '';
matlabbatch{1}.spm.spatial.normalise.estwrite.subj.resample = {FA_images{j};MD_images{j};% T2_images{j}}; %;L2_images{j};L3_images{j};MeanB0_images{j};RD_images{j};;B0_images{j}
matlabbatch{1}.spm.spatial.normalise.estwrite.eoptions.template = {'/data/Alisa/DTI/WSK_allscans_analysis/exported_MD_FA_ko5_1_registered/Mean_FA_COPY.nii,1'};
matlabbatch{1}.spm.spatial.normalise.estwrite.eoptions.weight = ''; 
matlabbatch{1}.spm.spatial.normalise.estwrite.eoptions.smosrc = 0.4;
matlabbatch{1}.spm.spatial.normalise.estwrite.eoptions.smoref = 0;
matlabbatch{1}.spm.spatial.normalise.estwrite.eoptions.regtype = 'none';
matlabbatch{1}.spm.spatial.normalise.estwrite.eoptions.cutoff = 25;
matlabbatch{1}.spm.spatial.normalise.estwrite.eoptions.nits = 16;
matlabbatch{1}.spm.spatial.normalise.estwrite.eoptions.reg = 1;
matlabbatch{1}.spm.spatial.normalise.estwrite.roptions.preserve = 0;
matlabbatch{1}.spm.spatial.normalise.estwrite.roptions.bb = [-Inf -Inf -Inf
                                                             Inf Inf Inf];
matlabbatch{1}.spm.spatial.normalise.estwrite.roptions.vox = [Inf Inf Inf];
matlabbatch{1}.spm.spatial.normalise.estwrite.roptions.interp = 1;
matlabbatch{1}.spm.spatial.normalise.estwrite.roptions.wrap = [0 0 0];
matlabbatch{1}.spm.spatial.normalise.estwrite.roptions.prefix = 'w';

% run the job: 
spm('defaults', 'FMRI');
spm_jobman('serial', matlabbatch, '', cell(0,1));

% delete the copied the template
cd('/data/Alisa/DTI/WSK_allscans_analysis/exported_MD_FA_ko5_1_registered')
delete('/data/Alisa/DTI/WSK_allscans_analysis/exported_MD_FA_ko5_1_registered/Mean_FA_COPY.nii');

end