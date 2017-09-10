function [nii_Data,nii_Bmat]=Convert2NII(Data,DTI_scan_files,path,filename)

for i=1:length(DTI_scan_files)
    data(:,:,:,:,i)=                    Data{DTI_scan_files(i),1}.img;
    DW_Bmat=                            Data{DTI_scan_files(i) ,1}.DW_Bmat;
    DW_Bmat=                            reshape(DW_Bmat',[9 size(DW_Bmat,1)/3]);
    DW_Bmat=                            DW_Bmat';
    B0_locations=               find(sum(DW_Bmat(:,1:6),2)==0);
    DWI_locations=           find(sum(DW_Bmat(:,1:6),2)~=0);
    B0_data(:,:,:,:,i)=            data(:,:,:,B0_locations,i);
    B0_Bmats(:,:,i)=               DW_Bmat(B0_locations,:);
    DWI_data(:,:,:,:,i)=         data(:,:,:,DWI_locations,i);
    DWI_Bmats(:,:,i)=            DW_Bmat(DWI_locations,:);
    voxel_size=                   Data{DTI_scan_files(i),1}.Spatial_resolution;
    clear DW_Bmat B0_locations DWI_locations
end
[xdim ydim zdim B0 rep]=size(B0_data);
B0_data=reshape(B0_data,[xdim ydim zdim B0*rep]);
B0_Bmats=permute(B0_Bmats,[2 1 3]);
B0_Bmats=reshape(B0_Bmats,[9 2*rep])';
[xdim ydim zdim DWI rep]=size(DWI_data);
DWI_data=reshape(DWI_data,[xdim ydim zdim DWI*rep]);
DWI_Bmats=permute(DWI_Bmats,[2 1 3]); 
DWI_Bmats=reshape(DWI_Bmats,[ 9 DWI.*rep])';

nii_Data=cat(4,B0_data,DWI_data);
nii_Bmat=cat(1,B0_Bmats,DWI_Bmats);
clear B0_Bmats B0_data DWI_Bmats DWI_data DTI_scan_files xdim ydim zdim B0 DWI rep i data Data

% Create nii file 
nii = make_nii(nii_Data,voxel_size);
% Syntax:
% ~~~~~~~
%   nii = make_nii(img, [voxel_size], [origin], [datatype], [description])
%
% 	voxel_size (optional):	Voxel size in millimeter for each dimension. 
%	datatype (optional):	   Storage data type:
%		2 - uint8,  4 - int16,  8 - int32,  16 - float32, 64 - float64,  128 - RGB24,  
%       256 - int8,  511 - RGB96, 512 - uint16,  768 - uint32

% Save nii 
save_nii(nii, [path '\' filename '_nii.nii'], 0)
% Syntax:
% ~~~~~~~
% save_nii(nii, filename, [old_RGB])
%
%  old_RGB    - an optional boolean variable to handle special RGB data 
%       sequence [R1 R2 ... G1 G2 ... B1 B2 ...] that is used only by 
%       AnalyzeDirect (Analyze Software). Since both NIfTI and Analyze
%       file format use RGB triple [R1 G1 B1 R2 G2 B2 ...] sequentially
%       for each voxel, this variable is set to FALSE by default. If you
%       would like the saved image only to be opened by AnalyzeDirect 
%       Software, set old_RGB to TRUE (or 1). It will be set to 0, if it
%       is default or empty.