function Coregister_Alisa(ExportStuff_Path)
%This script co-registrate all the export images (al the nii files) to the
%FA template (in our case - the mean FA template)

%How to use the script: (via SPM-add spm to matlab path)
%A. input: ExportStuff_Path=the path to the folder which you have the nii
%          files you exported (via explore DTI->export stuff)
%B. you can change the type of images you want register in lines:23-40 (delete the ones you dont need or add others)
%   -> then change it accordingly in lines 42-61 -> and in line 75  
%C. create a source folder- put a copy of all your FA images and write this folder path in sourceDir (line 20) 
%D. you need to change the path and the template you want to register to in
%lines: 68(path), 69(name+name of copy file) ,73(path+name of copy file),90(path),91(path+name of copy file) 

% check if user input is needed or use value given 
if isempty(ExportStuff_Path)
    relevantDir = uigetdir();
else
    relevantDir =ExportStuff_Path;
end

% find the .nii files in this directory 
d1 = dir([relevantDir,'/T*.nii']); %FA img 
T2_images=cell(length(d1),1);


for i = 1:length(d1)
    T2_images{i}=fullfile(relevantDir,d1(i).name); % store data
        T2_images{i}=[T2_images{i},',1']; %insert ',1' for later SPM use
end

%% DATA PROCESSING Steps

for j=1:length(T2_images) 

% copy the template (for later use)
cd('/data/Alisa/DTI/WSK_allscans_analysis/pi10_register_to_meanFA/register_all_to_meanFA')
copyfile('Mean_FA.nii','Mean_FA_COPY.nii')

cd(ExportStuff_Path)
%coregister stage:  
matlabbatch{1}.spm.spatial.coreg.estwrite.ref ={'/data/Alisa/DTI/WSK_allscans_analysis/pi10_register_to_meanFA/exported_MD_FA/Mean_FA_COPY.nii,1'}; 
matlabbatch{1}.spm.spatial.coreg.estwrite.source = {T2_images{j}};
matlabbatch{1}.spm.spatial.coreg.estwrite.other = {''}; %L1_images{j};L2_images{j};L3_images{j};MeanB0_images{j};RD_images{j};
matlabbatch{1}.spm.spatial.coreg.estwrite.eoptions.cost_fun = 'nmi';
matlabbatch{1}.spm.spatial.coreg.estwrite.eoptions.sep = [0.4 0.2];
matlabbatch{1}.spm.spatial.coreg.estwrite.eoptions.tol = [0.02 0.02 0.02 0.001 0.001 0.001 0.01 0.01 0.01 0.001 0.001 0.001];
matlabbatch{1}.spm.spatial.coreg.estwrite.eoptions.fwhm = [7 7];
matlabbatch{1}.spm.spatial.coreg.estwrite.roptions.interp = 4;
matlabbatch{1}.spm.spatial.coreg.estwrite.roptions.wrap = [0 0 0];
matlabbatch{1}.spm.spatial.coreg.estwrite.roptions.mask = 0;
matlabbatch{1}.spm.spatial.coreg.estwrite.roptions.prefix = 'r';

% run the job: %%
spm('defaults', 'FMRI');
spm_jobman('serial', matlabbatch, '', cell(0,1));

% delete the copied template
cd('/data/Alisa/DTI/WSK_allscans_analysis/pi10_register_to_meanFA/register_all_to_meanFA')
delete('/data/Alisa/DTI/WSK_allscans_analysis/pi10_register_to_meanFA/register_all_to_meanFA/Mean_FA_COPY.nii');

end
