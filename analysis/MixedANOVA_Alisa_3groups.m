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
path=('/Volumes/SAMSUNG/MSc_PhD/DTI_Analysis/WSK_allscans_analysis/registered_T2_to_ko51_normalize_smooth_5'); %Insert the path of the scans from the same type-MD
%path=('/Volumes/SAMSUNG 1/MSc_PhD/DTI_Analysis/smoothed_allscans'); %Insert the path of the scans from the same type-FA
%type='MD'; %the type of images
type='MD'; %the type of images
Group='WT_vs_KO_vs_SH'; %the batch numbers

%% Mask Values input:
Mask=load_untouch_nii('/Volumes/SAMSUNG/MSc_PhD/DTI_Analysis/WSK_allscans_analysis/registered_T2_to_ko51_normalize_smooth_5/Mask_3000.nii'); %Insert the path of your template (MeanFA)- to use as a mask
MaskImg=Mask.img; %Take the template's image matrix (155X105X18 for example);
MatrixSize=size(Mask.img);
MaskImgVec=MaskImg(:); %Turn the template to a vector

%% organizing the data in a design matirx:


%%%%%% Organize the Dependent variable - first column %%%%%% 	 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%orgasnize the full path of scans -> WT group  
scan1WT= fuf([path '/swrTWT*_scan1_*', type, '.nii'],'detail');
scan2WT= fuf([path '/swrTWT*_scan2_*',type, '.nii'],'detail');
scan3WT= fuf([path '/swrTWT*_scan3_*',type, '.nii'],'detail');
scan4WT= fuf([path '/swrTWT*_scan4_*',type, '.nii'],'detail');
scan5WT= fuf([path '/swrTWT*_scan5_*',type, '.nii'],'detail');
% scan6WT= fuf([path '/swrTWT*_scan6_*','FA.nii'],'detail');
% scan7WT= fuf([path '/swrTWT*_scan7_*','FA.nii'],'detail');

%orgasnize the full path of scans -> KO group  
scan1KO= fuf([path '/swrTKO*_scan1_*',type, '.nii'],'detail');
scan2KO= fuf([path '/swrTKO*_scan2_*',type, '.nii'],'detail');
scan3KO= fuf([path '/swrTKO*_scan3_*',type, '.nii'],'detail');
scan4KO= fuf([path '/swrTKO*_scan4_*',type, '.nii'],'detail');
scan5KO= fuf([path '/swrTKO*_scan5_*',type, '.nii'],'detail');
% scan6KO= fuf([path '/swrTKO*_scan6_*','FA.nii'],'detail');
% scan7KO= fuf([path '/swrTKO*_scan7_*','FA.nii'],'detail');

%orgasnize the full path of scans -> sham group  
scan1SH= fuf([path '/swrTsham*_scan1_*',type, '.nii'],'detail');
scan2SH= fuf([path '/swrTsham*_scan2_*',type, '.nii'],'detail');
scan3SH= fuf([path '/swrTsham*_scan3_*',type, '.nii'],'detail');
scan4SH= fuf([path '/swrTsham*_scan4_*',type, '.nii'],'detail');
scan5SH= fuf([path '/swrTsham*_scan5_*',type, '.nii'],'detail');


%Create an array with all scans.. scan1 of all wt, scan 1 of all ko, scan 2 of wt, scan 2 ko...
%allScans=[scan1WT;scan1KO;scan2WT;scan2KO;scan3WT;scan3KO;scan4WT;scan4KO;scan5WT;scan5KO;];
allScans=[scan1WT;scan1KO; scan1SH; scan2WT;scan2KO; scan2SH; scan3WT;scan3KO;scan3SH; scan4WT;scan4KO;scan4SH; scan5WT;scan5KO;scan5SH;];

%number of mice
nsubjs=length(scan1WT)+length(scan1KO)+length(scan1SH);
nScan1=length(scan1WT)+length(scan1KO)+length(scan1SH);
nScan2=length(scan2WT)+length(scan2KO)+length(scan2SH);
nScan3=length(scan3WT)+length(scan3KO)+length(scan3SH);
nScan4=length(scan4WT)+length(scan4KO)+length(scan4SH);
nScan5=length(scan5WT)+length(scan5KO)+length(scan5SH);
% nScan6=length(scan6WT)+length(scan6KO);


%creating an 4D mat -> include matrix size (118X118X50) and the number of scans as a fourth dimension
%open images to one 4D mat
SubjsData=zeros([MatrixSize,length(allScans)]); %creats a array
for i=1:length(allScans)
    %opem image
    nii=load_untouch_nii(allScans{i});
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

%create a vector with the between-subject levels- WT(1)/KO(2)/SH(3)
GroupVec=zeros(length(allScans),1);
GroupWT=1;
GroupKO=2;
GroupSH=3;

for i=1:length(allScans)
    if isempty(strfind(allScans{i}, 'swrTWT'))==0 %if the scan's name contains 'WT' 
        GroupVec(i)=GroupWT; %put in the GroupVec(i) the number 1
    elseif isempty(strfind(allScans{i}, 'swrTsham'))==0
        GroupVec(i)=GroupSH;
    else
        GroupVec(i)=GroupKO; %else put in the GroupVec(i) the number 2
    end
end


%%%%%% Organize the within subjects variable -  third column %%%%%% 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%create a vector with the within-subject levels- scan1(1)-scan7(7)
WithinVec=zeros(length(allScans),1); 
WithinVec(1:nScan1)=1; %All the BL scans- put in the WithinVec(i)the number 1
WithinVec((nScan1+1):(nScan1+nScan2))=2; %All the second scans- put in the WithinVec(i)the number 2
WithinVec((nScan1+nScan2+1):(nScan1+nScan2+nScan3))=3; %All the third scans- put in the WithinVec(i)the number 3
WithinVec((nScan1+nScan2+nScan3+1):(nScan1+nScan2+nScan3+nScan4))=4; %All the forth scans- put in the WithinVec(i)the number 4
WithinVec((nScan1+nScan2+nScan3+nScan4+1):(nScan1+nScan2+nScan3+nScan4+nScan5))=5; %All the fifth scans- put in the WithinVec(i)the number 5
% WithinVec((nScan1+nScan2+nScan3+nScan4+nScan5+1):(nScan1+nScan2+nScan3+nScan4+nScan5+nScan6))=6; %All the sixed scans- put in the WithinVec(i)the number 6
% WithinVec((nScan1+nScan2+nScan3+nScan4+nScan5+nScan6+1):(nScan1+nScan2+nScan3+nScan4+nScan5+nScan6+nScan7))=7; %All the seventh scans- put in the WithinVec(i)the number 7


%%%%%% Organize the -  forth column %%%%%% DID it MANUALY!!!!!!!! give
%%%%%% number to each animal
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
Forth_column=zeros(length(allScans),1); 

Forth_column(1:nScan1)=[1:nScan1];
Forth_column((nScan1+1):(nScan1+nScan2))=[1:nScan2];
Forth_column((nScan1+nScan2+1):(nScan1+nScan2+nScan3))=[1:nScan3];
Forth_column((nScan1+nScan2+nScan3+1):(nScan1+nScan2+nScan3+nScan4))=[1:nScan4];
Forth_column((nScan1+nScan2+nScan3+nScan4+1):(nScan1+nScan2+nScan3+nScan4+nScan5))=[1:nScan5];
% Forth_column((nScan1+nScan2+nScan3+nScan4+nScan5+1):(nScan1+nScan2+nScan3+nScan4+nScan5+5))=[1:5];
% Forth_column((nScan1+nScan2+nScan3+nScan4+nScan5+6):(nScan1+nScan2+nScan3+nScan4+nScan5+nScan6))=[9:16];
% Forth_column((nScan1+nScan2+nScan3+nScan4+nScan5+nScan6+1):(nScan1+nScan2+nScan3+nScan4+nScan5+nScan6+2))=[1:2];
% Forth_column((nScan1+nScan2+nScan3+nScan4+nScan5+nScan6+3):(nScan1+nScan2+nScan3+nScan4+nScan5+nScan6+nScan7))=[9:16];

%for results:
p_main_Between=zeros(length(MaskImgVec),1);
p_main_within=zeros(length(MaskImgVec),1);
p_main_interaction=zeros(length(MaskImgVec),1);

for x=1:length(MaskImgVec)
    % x %the number of iteration (index of the voxel place)
    
    if MaskImgVec(x)<=0
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
    
    [SSQs, DFs, MSQs, Fs, Ps]= mixed_between_within_anova_original(DesignMarix,1);
    
    p_main_Between(x)=Ps{1};
    p_main_within(x)=Ps{3};
    p_main_interaction(x)=Ps{4};
    
end

voxel_size=[Mask.hdr.dime.pixdim(2),Mask.hdr.dime.pixdim(3),Mask.hdr.dime.pixdim(4)]; %takes the vox size from the mask
images={p_main_Between, p_main_within,p_main_interaction}; %organize the P-images as a cell array
Namesimages={'p_main_Between_WTvsKOvsSH', 'p_main_Within_scan1_5', 'p_main_interaction'}; %name of the P-images
for i=1:length(Namesimages)
    P_imageTemp=reshape(images{i},size(Mask.img)); %reshaps the P-vec imto the image matrix
%     Nii = make_nii(P_imageTemp,voxel_size); %creats a nii image from the P-image 
%     Nii.hdr.hist.originator=Mask.hdr.hist.originator; %compare the origin of the P-image to the mask origin
    Nii = Mask;
    Nii.img = P_imageTemp;
    Nii.hdr.dime.glmax = max(P_imageTemp(:));
    Nii.hdr.dime.glmin = min(P_imageTemp(:));
    Nii.hdr.dime.datatype = 64;
    Nii.hdr.dime.bitpix = 64;
    save_untouch_nii(Nii, [Group '_' num2str(nsubjs) 'mice_'  Namesimages{i} '_' type '.nii']); %saves the nii as is
    Nii.img(Nii.img>0.05)=0;
    save_untouch_nii(Nii, [Group '_' num2str(nsubjs) 'mice_' Namesimages{i} '_0.05_' type '.nii']); %saves the nii as >0.05=0;
end