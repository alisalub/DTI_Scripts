%Repeated Measures- One within (BL vs after COND) 1 between- CPP vs NoCPP

%% General path and type:
path=('/Volumes/SAMSUNG 1/MSc_PhD/DTI_Analysis/smoothed_allscans'); %Insert the path of the scans from the same type-MD
%path=('/Volumes/SAMSUNG 1/MSc_PhD/DTI_Analysis/smoothed_allscans'); %Insert the path of the scans from the same type-FA
type='MD'; %the type of images
%type='FA'; %the type of images
Group='WT_VS_KO'; %the batch numbers


%% Mask Values input:
Mask=load_nii('/Volumes/SAMSUNG 1/MSc_PhD/DTI_Analysis/smoothed_allscans.AverageFA.nii'); %Insert the path of your template (MeanFA)- to use as a mask
MaskImg=Mask.img; %Take the template's image matrix (155X105X18 for example);
MatrixSize=size(Mask.img);
MaskImgVec=MaskImg(:); %Turn the template to a vector

%orgasnize the full path of BL and COND scans -> NoCPP group  
sacn1WT= fuf([path '/swrWT*_scan1_*','.nii'],'detail');
scan2WT= fuf([path '/swrWT*_scan2_*','.nii'],'detail');
scan3WT= fuf([path '/swrWT*_scan3_*','.nii'],'detail');
scan4WT= fuf([path '/swrWT*_scan4_*','.nii'],'detail');
scan5WT= fuf([path '/swrWT*_scan5_*','.nii'],'detail');
scan6WT= fuf([path '/swrWT*_scan6_*','.nii'],'detail');
scan7WT= fuf([path '/swrWT*_scan7_*','.nii'],'detail');
scan1KO= fuf([path '/swrKO*_scan1_*','.nii'],'detail');
scan2KO= fuf([path '/swrKO*_scan2_*','.nii'],'detail');
scan3KO= fuf([path '/swrKO*_scan3_*','.nii'],'detail');
scan4KO= fuf([path '/swrKO*_scan4_*','.nii'],'detail');
scan5KO= fuf([path '/swrKO*_scan5_*','.nii'],'detail');
scan6KO= fuf([path '/swrKO*_scan6_*','.nii'],'detail');
scan7KO= fuf([path '/swrKO*_scan7_*','.nii'],'detail');






%Create an array with before (BL) all mice(CPP+NoCPP) and after (COND) all mice (CPP+NoCPP)
allScans=[preScansEtHO;postScansEtHO];

%create a catgorial vector with CPP/NoCPP
GroupVec=cell(length(allScans),1);
GroupWT='WT';
GroupKO='KO';
for i=1:length(allScans)
    if isempty(strfind(allScans{i}, '_No_'))==1 %if the scan's name contains 'CPP' 
        GroupVec{i}=GroupCPP; %put in the GroupVec{i} the string CPP
    else
        GroupVec{i}=GroupNoCPP; %else put in the GroupVec{i} the string NoCPP
    end
end
GroupVecCat=categorical(GroupVec); %creat a categorical vector (CPP/NoCPP) from the group vector 

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
%creats a 1X2 mat (the first dimension 
Data=zeros(length(Subj1),size(SubjsData,4));
for i=1:size(SubjsData,4)
    subTemp=SubjsData(:,:,:,i);
    Data(:,i)=subTemp(:);
end

%for results
p_main_withinScans_BLvsCOND=zeros(length(MaskImgVec),1);
%interaction
p_main_Interaction_CPPvsNoCPP=zeros(length(MaskImgVec),1);

for x=1:length(MaskImgVec)
    x %the number of iteration (index of the voxel place)
    
    if MaskImgVec(x)<=0;
        continue
    end
    
    DataAfterMask=Data(x,:)'; %insert value of DTI indice MD/FA/L1/RD/B0/L2/L3
    %DataAfterMask(1:nsubjs) values of all mice's BL scans
    %DataAfterMask(nsubj+1:end)  values of all mice's COND scans
    tBet=table(GroupVecCat(1:nsubjs),DataAfterMask(1:nsubjs),DataAfterMask(nsubjs+1:end), 'VariableNames', {'CPPVsNoCPP','Baseline','AfterCond'});
   
    rm=fitrm(tBet, 'AfterCond-Baseline~ CPPVsNoCPP');
    [ranovatbl] = ranova(rm);
    p_main_withinScans_BLvsCOND(x)=ranovatbl{'(Intercept):Time','pValue'};
    p_main_Interaction_CPPvsNoCPP(x)=ranovatbl{'CPPVsNoCPP:Time','pValue'};
end

voxel_size=[Mask.hdr.dime.pixdim(2),Mask.hdr.dime.pixdim(3),Mask.hdr.dime.pixdim(4)]; %takes the vox size from the mask
images={p_main_withinScans_BLvsCOND, p_main_Interaction_CPPvsNoCPP}; %organize the P-images as a cell array
Namesimages={'p_main_withinScans_BLvsCOND', 'p_main_interaction_CPPvsNoCPP'}; %name of the P-images
for i=1:length(Namesimages)
    P_imageTemp=reshape(images{i},size(Mask.img)); %reshaps the P-vec imto the image matrix
    Nii = make_nii(P_imageTemp,voxel_size); %creats a nii image from the P-image 
    Nii.hdr.hist.originator=Mask.hdr.hist.originator; %compare the origin of the P-image to the mask origin
    save_nii(Nii, [Group '_' num2str(nsubjs) 'mice_'  Namesimages{i} '_' type '.nii']); %saves the nii as is
    Nii.img(Nii.img>0.05)=0;
    save_nii(Nii, [Group '_' num2str(nsubjs) 'mice_' Namesimages{i} '_0.05_' type '.nii']); %saves the nii as >0.05=0;
end