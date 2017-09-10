function [data,files,durations]=OpenBruker(directory,CreateAnalyze,basename)
% Directory  - contains all the scan acquisitions
% CreateAnalyze=0/1 (0 - don't create analyze ; 1 - create analyze files)
% basename - defines the saved files initial name
files=fuf([directory '\2dseq.'],'detail');
if  CreateAnalyze~=0 && ~exist('basename','var')
    basename=input('Enter saving name: ','s'); 
end
for fn=1:length(files)
    fid=fopen(files{fn},'rb');
    method=ReadMethod(files{fn});
    [pth_reco tmp tmp]=fileparts(files{fn});
    [pth reco_num tmp]=fileparts(pth_reco);
    if reco_num~=1
%         method_reco=ReadMethod(pth_reco);
    end
    if strcmp(method.Read_direction,'H_F')
        method.Matrix_size=cat(2,method.Matrix_size(2),method.Matrix_size(1),method.Matrix_size(3));
    end
    if isfield(method,'EffBval')
        img_tmp=fread(fid,...
            [ method.Matrix_size(1)*method.Matrix_size(2)*method.Matrix_size(3)*size(method.EffBval,1) 1],'int16');
        img_tmp=reshape(img_tmp,[method.Matrix_size(1) method.Matrix_size(2) method.Matrix_size(3) size(method.EffBval,1)]);
    else
        img_tmp=fread(fid,...
            [ method.Matrix_size(1)*method.Matrix_size(2)*method.Matrix_size(3)*method.NRepetitions 1],'int16');
        img_tmp=reshape(img_tmp,[method.Matrix_size(1) method.Matrix_size(2) method.Matrix_size(3) method.NRepetitions]);
    end
    data{fn,1}=method;
    data{fn,1}.img=img_tmp; %create img matrix of each scan
    data{fn,1}.file_name=files{fn};
    durations{fn,1}=method.Duration;
    if CreateAnalyze~=0
        if ~exist([directory '\Data\OrgImages\' int2str(data{fn,1}.Acquisition)],'dir')
            path_save=['\Data\OrgImages\' int2str(data{fn,1}.Acquisition)];
            mkdir([ directory path_save ]);
            path_save=['\Data\OrgImages\' int2str(data{fn,1}.Acquisition) '\'];
        else
            path_save=['\Data\OrgImages\' int2str(data{fn,1}.Acquisition) '\'];
        end
    end
    if CreateAnalyze~=0
        hdr.pre=16;
        hdr.dim=method.Matrix_size;
        hdr.siz=method.Spatial_resolution;
        hdr.lim=[255;0];
        hdr.offset=0;
        hdr.scale=1;
        hdr.origin=[0;0;0];
        hdr.Read_direction=method.Read_direction;
        hdr.matrix_orientation=method.Matrix_orientation;
        hdr.fileformat='ieee-le';
        hdr.gradorg=[0;0;0];
        if isfield(data{fn,1},'Directions')
            for dwi=1:size(data{fn,1}.EffBval,1)
                hdr.name=sprintf('%s%s%s_%03d_%03d',directory,path_save,basename,data{fn,1}.Acquisition,dwi);
                writeanalyzeimg(hdr, img_tmp(:,:,:,dwi));
            end
        elseif method.NRepetitions~=1
            for nrep=1:method.NRepetitions
                hdr.name=sprintf('%s%s%s_%03d_%03d',directory,path_save,basename,data{fn,1}.Acquisition,nrep);
                writeanalyzeimg(hdr, img_tmp(:,:,:,nrep));
            end
        else
                hdr.name=sprintf('%s%s%s_%03d',directory,path_save,basename,data{fn,1}.Acquisition);
                writeanalyzeimg(hdr, img_tmp);
        end
    end
    Acquisition(fn,1)=data{fn,1}.Acquisition;
    clear method fid img_tmp
end
[tmp order]=sort(Acquisition);
data=data(order,1);
files=files(order,1);
durations=durations(order,1);

