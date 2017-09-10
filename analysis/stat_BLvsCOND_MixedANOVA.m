%% ### Statistics - BL vs COND ###

%This script takes all the Base-line scans and After-conditioining scans
%and creates A design matrix for future analysis using the
%'mixed_between_within_anova' function

% The design matrix consist of four columns 
%     - first column  (i.e., X(:,1)) : all dependent variable values
%     - second column (i.e., X(:,2)) : between-subjects factor (e.g., subj ect group) level codes (ranging from 1:L where 
%         L is the # of levels for the between-subjects factor)
%     - third column  (i.e., X(:,3)) : within-subjects factor (e.g., condition/task) level codes (ranging from 1:L where 
%         L is the # of levels for the within-subjects factor)
%     - fourth column (i.e., X(:,4)) : subject codes (ranging from 1:N where N is the total number of subjects)

%% General path and type:
%path=('D:\Smoothing_NoOutliers\15_Edges_MD'); %Insert the path of the scans from the same type-MD
path=('D:\Smoothing_NoOutliers\15_Edges_FA'); %Insert the path of the scans from the same type-FA
%type='MD'; %the type of images
type='FA'; %the type of images
Group='HL3478910'; %the batch numbers

%% Mask Values input:
Mask=load_nii('D:\Normaliztion_New\NewMask_FP.nii'); %Insert the path of your template (MeanFA)- to use as a mask
MaskImg=Mask.img; %Take the template's image matrix (155X105X18 for example);
MatrixSize=size(Mask.img);
MaskImgVec=MaskImg(:); %Turn the template to a vector

%% organizing the data in a design matirx:


%%%%%% Organize the Dependent variable - first column %%%%%% 	 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%orgasnize the full path of BL and COND scans -> CPP group  
preScansCPP= fuf([path '\swr*_BL_*' ,'*_CPP_*', '.nii'],'detail');
postScansCPP= fuf([path '\swr*_COND_*' '*_CPP_*', '.nii'],'detail');

%orgasnize the full path of BL and COND scans -> NoCPP group  
preScansNOCPP= fuf([path '\swr*_BL_*' ,'*_No_*','.nii'],'detail');
postScansNOCPP= fuf([path '\swr*_COND_*' ,'*_No_*', '.nii'],'detail');

%Create an array with before (BL) all mice(CPP+NoCPP) and after (COND) all mice (CPP+NoCPP)
allScans=[preScansCPP;preScansNOCPP;postScansCPP;postScansNOCPP];

%number of mice
nsubjs=length(preScansCPP)+length(preScansNOCPP);

%creating an 4D mat -> include matrix size (155X105X18) and the number of scans as a fourth dimension
%open images to one 4D mat
SubjsData=zeros([MatrixSize,(nsubjs*2)]); %creats a array
for i=1:length(allScans)
    %opem image
    nii=load_nii(allScans{i});
    niiTemp=nii.img;
    SubjsData(:,:,:,i)=niiTemp; %arrange all the data in 4D mat (the forth Dimension is the scan)
end

%arrange data in vector
Subj1=niiTemp(:);%creatas the last scan into a vector - in order to know the vecor's size
%creats a 1X2 mat (the first dimension is the image vaector) 
Data=zeros(length(Subj1),size(SubjsData,4));
for i=1:size(SubjsData,4)
    subTemp=SubjsData(:,:,:,i);
    Data(:,i)=subTemp(:);
end


%%%%%% Organize the between subjects variable -  second column %%%%%% 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%create a vector with the between-subject levels- CPP(1)/NoCPP(2)
GroupVec=zeros(length(allScans),1);
GroupCPP=1;
GroupNoCPP=2;
for i=1:length(allScans)
    if isempty(strfind(allScans{i}, '_No_'))==1 %if the scan's name contains 'CPP' 
        GroupVec(i)=GroupCPP; %put in the GroupVec(i) the number 1
    else
        GroupVec(i)=GroupNoCPP; %else put in the GroupVec(i) the number 2
    end
end



%%%%%% Organize the within subjects variable -  third column %%%%%% 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%create a vector with the within-subject levels- BL(1)/COND(2)
WithinVec=zeros(length(allScans),1); 
WithinVec(1:nsubjs)=1; %All the BL scans- put in the WithinVec(i)the number 1
WithinVec(nsubjs+1:length(allScans))=2; %All the COND scans- put in the WithinVec(i)the number 2

%%%%%% Organize the -  forth column %%%%%% 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
Forth_column=zeros(length(allScans),1); 
Forth_column(1:nsubjs)=[1:nsubjs];
Forth_column(nsubjs+1:length(Forth_column))=[1:nsubjs];

%for results:
p_main_Between=zeros(length(MaskImgVec),1);
p_main_within=zeros(length(MaskImgVec),1);
p_main_interaction=zeros(length(MaskImgVec),1);

for x=1:length(MaskImgVec)
    x %the number of iteration (index of the voxel place)
    
    if MaskImgVec(x)<=0;
        continue
    end
    
    DataAfterMask=Data(x,:)'; %insert value of DTI indice MD/FA/L1/RD/B0/L2/L3
    %DataAfterMask(1:nsubjs) values of all mice's BL scans
    %DataAfterMask(nsubj+1:end)  values of all mice's COND scans
    DesignMarix=zeros(length(allScans),4);
    DesignMarix(:,1)=DataAfterMask; %dependent variable - first column
    DesignMarix(:,2)= GroupVec; %between subjects variable -  second column
    DesignMarix(:,3)= WithinVec; %within subjects variable - third column
    DesignMarix(:,4)= Forth_column; %subject number variable -  fourth column
    
    [SSQs, DFs, MSQs, Fs, Ps]= mixed_between_within_anova(DesignMarix,1);
    
    p_main_Between(x)=Ps{1};
    p_main_within(x)=Ps{3};
    p_main_interaction(x)=Ps{4};
    
end

voxel_size=[Mask.hdr.dime.pixdim(2),Mask.hdr.dime.pixdim(3),Mask.hdr.dime.pixdim(4)]; %takes the vox size from the mask
images={p_main_Between, p_main_within,p_main_interaction}; %organize the P-images as a cell array
Namesimages={'p_main_Betwwen_CPPNoCPP', 'p_main_Within_BLvsCOND', 'p_main_interaction'}; %name of the P-images
for i=1:length(Namesimages)
    P_imageTemp=reshape(images{i},size(Mask.img)); %reshaps the P-vec imto the image matrix
    Nii = make_nii(P_imageTemp,voxel_size); %creats a nii image from the P-image 
    Nii.hdr.hist.originator=Mask.hdr.hist.originator; %compare the origin of the P-image to the mask origin
    save_nii(Nii, [Group '_' num2str(nsubjs) 'mice_'  Namesimages{i} '_' type '.nii']); %saves the nii as is
    Nii.img(Nii.img>0.05)=0;
    save_nii(Nii, [Group '_' num2str(nsubjs) 'mice_' Namesimages{i} '_0.05_' type '.nii']); %saves the nii as >0.05=0;
end