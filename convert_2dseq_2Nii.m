function convert_2dseq_2Nii (Directory_Path,subject_name)
%% 1) Open RAW Bruker Files
%
% Enter main subject directory
% Directory_Path='C:\Users\gorzany\Desktop\YY_RA1_200911.a81';
% subject_name='RA1';

% Open Bruker files
path=[Directory_Path '\Data'];
[ Data , Files , Duration ]=OpenBruker(Directory_Path,0);

% Syntax: 
% ~~~~~~~
%       [ data , files , duration ] = OpenBruker( ' Main directory name ' , Create analyze , ' Base name ') 
%       Main direcotry name:     contains study scans
%       Create analyze:                 1 / 0 -->  Create /  don't create analyze files
%       Base name:                              when 'Create analyze' sets to 1, enter base name for analyzet files

% Plot scan durations for DTI scans selection
for ind=1:length(Files)
Duration{ind,2}=int2str(ind);
end
Duration

%% 2) Convert T2w files to nii format
% ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
if ~exist('T2w_scan_files')
T2w_scan_files = input( ' Enter T2w scan numbers: (e.g. [1:3])' );
end

%[nii_Data, nii_Bmat]=Convert2NII( Data , DTI_scan_files,path,subject_name);

data(:,:,:,:)=Data{T2w_scan_files,1}.img;
voxel_size=Data{T2w_scan_files,1}.Spatial_resolution;

nii=make_nii(data,voxel_size);
save_nii(nii, [path '\' subject_name '_nii_T2.nii'], 0)

end