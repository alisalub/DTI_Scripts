%%%% ExtractMeanValue(regionNum,group)

%% creating cluster images - FA
P_value_nii=load_nii('/Volumes/SAMSUNG 1/MSc_PhD/DTI_Analysis/smoothed_allscans/scan1_scan5_mask3000/WT_VS_KO_16mice_p_main_Within_scan1_5_0.01_FA.nii');  %load Anova image
P_val_name=P_value_nii.fileprefix;
P_value_img=P_value_nii.img;
voxel_size=[P_value_nii.hdr.dime.pixdim(2),P_value_nii.hdr.dime.pixdim(3),P_value_nii.hdr.dime.pixdim(4)];

 ALmask_nii = load_untouch_nii('AverageFA.nii');
 ALmask_img = ALmask_nii.img;
 P_value_img(isnan(ALmask_img)) = 0;

%bwlabeln
%ClusterImg-a labled matrix for connected components (26-connected neighborhood)
%ClusterNum-the number of connected objects (clusters) found in ClusterImg.
[ClusterImg,ClusterNum]=bwlabeln(P_value_img,26);
for i=1:ClusterNum
    clusterValues=ClusterImg(ClusterImg==i);
    if length(clusterValues)<10
        P_value_img(ClusterImg==i)=0;
    end
end
[ClusterImg,ClusterNum]=bwlabeln(P_value_img,26);

Nii = make_nii(ClusterImg,voxel_size);
Nii.hdr.hist.originator=P_value_nii.hdr.hist.originator;

save_nii(Nii, [P_val_name  '_FAcluster10.nii']);
% 
% load atlas template and imagesnii_Mice_clust_FA = load_untouch_nii([P_val_name  '_FAcluster10.nii']); %H:\AlisaScansDTI\Pablo_smothhed_for_statistics\PBanova1FA_ttest_cluster10.nii
nii_Mice_clust_FA = load_untouch_nii([P_val_name  '_FAcluster10.nii']); %H:\AlisaScansDTI\Pablo_smothhed_for_statistics\PBanova1_ttest_cluster10.nii
img_Mice_clust_FA = nii_Mice_clust_FA.img;

%Organize all the Images
path=('/Volumes/SAMSUNG 1/MSc_PhD/DTI_Analysis/smoothed_allscans'); %H:\AlisaScansDTI\Pablo_smothhed_for_statistics\Smoothed % Insert the path of the MD scans

%uploading FA scans path
%orgasnize the full path of scans -> WT group  
scan1WT_FA= fuf([path '/swrWT*_scan1_*','FA.nii'],'detail');
scan2WT_FA= fuf([path '/swrWT*_scan2_*','FA.nii'],'detail');
scan3WT_FA= fuf([path '/swrWT*_scan3_*','FA.nii'],'detail');
scan4WT_FA= fuf([path '/swrWT*_scan4_*','FA.nii'],'detail');
scan5WT_FA= fuf([path '/swrWT*_scan5_*','FA.nii'],'detail');
%orgasnize the full path of scans -> KO group  
scan1KO_FA= fuf([path '/swrKO*_scan1_*','FA.nii'],'detail');
scan2KO_FA= fuf([path '/swrKO*_scan2_*','FA.nii'],'detail');
scan3KO_FA= fuf([path '/swrKO*_scan3_*','FA.nii'],'detail');
scan4KO_FA= fuf([path '/swrKO*_scan4_*','FA.nii'],'detail');
scan5KO_FA= fuf([path '/swrKO*_scan5_*','FA.nii'],'detail');

allScansFA=[scan1WT_FA;scan1KO_FA;scan5WT_FA;scan5KO_FA;];
% allScansFA=[scan1WT_FA;scan1KO_FA;scan2WT_FA;scan2KO_FA;scan3WT_FA;scan3KO_FA;scan4WT_FA;scan4KO_FA;scan5WT_FA;scan5KO_FA;];


scannum=2; %number of scans to all mice
WTnum=length(scan1WT_FA);
KOnum=length(scan1KO_FA);

%creating a subject list
Subjects=(1:(WTnum+KOnum))';
cellSubj=cell(1,length(Subjects));
for cellN=1:length(Subjects)
   cellSubj{cellN}=cellN;
end
% create matrix for the results PER SUBJ- FA
% create matrix for the results - FA 
columns_titles = {'Subject','clustnum', 'Scan1', 'Scan5'}; %'%change2-1' ,'%change3-2' ,'%change4-3','%change5-4','%change5-1', 'Scan1-std', 'Scan2-std', 'Scan3-std', 'Scan4-std','Scan5-std'
meanValuesRegionFA = cell(1+length(Subjects),length(columns_titles),max(img_Mice_clust_FA(:)));
for c=1:(size(meanValuesRegionFA,3))
    meanValuesRegionFA(1,:,c) = columns_titles;
    meanValuesRegionFA(2:end,1,c) = cellSubj;
    meanValuesRegionFA(2:end,2,c)={c};
end


% run through subjects & clusters  - FA


for clust_FA=1:max(img_Mice_clust_FA(:)) %loop for each cluster
    img_clust_FA = ismember(img_Mice_clust_FA,clust_FA); %creat 1/0 image of the cluster
    for subjectInd = 1:length(Subjects) %loop for each subject
        mean_scan=zeros(1,scannum); %scans for each subject
        count=0;
        for scan=subjectInd:length(Subjects):(scannum*length(Subjects)) %loop for each scan
            count=count+1;
            nii_normalized = load_untouch_nii(allScansFA{scan});%uploading nii scan
            img_normalized = nii_normalized.img; %taking the image matrix
            region_scan = img_normalized(img_clust_FA);  %taking voxels from image cluster
            region_scan = region_scan(~isnan(region_scan)); %removing all NaN values
            mean_scan (1,count) = mean(region_scan(:)); %mean of cluster
            meanValuesRegionFA{1+subjectInd,2+count,clust_FA}= mean_scan (1,count);
        end %end for all scans for one subject        
    end % end for subjectInd
end

save('Whithin_meanValuesFA_subj.mat','meanValuesRegionFA');
% save('Interaction_meanValuesFA_subj.mat','meanValuesRegionFA');
%save('Between_meanValuesFA_subj.mat','meanValuesRegionFA');

% create matrix for the results PER GROUP - FA
resGroups = {'WT_Avg', 'WT_SEM','KO_Avg', 'KO_SEM'}';
columns_titles_res = {'Group','clustnum', 'Scan1', 'Scan5'}; 
ResCell_FA = cell(length(resGroups)+1,length(columns_titles_res),max(img_Mice_clust_FA(:)));

for res_FA=1:(size(meanValuesRegionFA,3)) %loop for each cluster
    ResCell_FA(1,:,res_FA) = columns_titles_res;
    ResCell_FA(2:end,1,res_FA) = resGroups;
    ResCell_FA(2:end,2,res_FA) = {res_FA};
    for sc=1:scannum %loop for each scan
        ResCell_FA{2,2+sc,res_FA}=mean([(meanValuesRegionFA{(2:(WTnum+1)),2+sc,res_FA})]);
        ResCell_FA{3,2+sc,res_FA}=std([meanValuesRegionFA{(2:(WTnum+1)),2+sc,res_FA}])/sqrt(WTnum);
        ResCell_FA{4,2+sc,res_FA}=mean([meanValuesRegionFA{((WTnum+2):(WTnum+KOnum+1)),2+sc,res_FA}]);
        ResCell_FA{5,2+sc,res_FA}=std([meanValuesRegionFA{((WTnum+2):(WTnum+KOnum+1)),2+sc,res_FA}])/sqrt(KOnum);
    end
    
end

save('Whithin_ResCell_FA.mat','ResCell_FA');
% save('Interaction_ResCell_FA.mat','ResCell_FA');
%save('Between_ResCell_FA.mat','ResCell_FA');

%% creating cluster images - MD
P_value_nii=load_nii('/Volumes/SAMSUNG 1/MSc_PhD/DTI_Analysis/smoothed_allscans/scan1_scan5_mask3000/WT_VS_KO_16mice_p_main_Within_scan1_5_0.01_MD.nii'); %H:\AlisaScansDTI\Pablo_smothhed_for_statistics\PBanova1FA_ttest.nii %load Anova image
P_val_name=P_value_nii.fileprefix;
P_value_img=P_value_nii.img;
voxel_size=[P_value_nii.hdr.dime.pixdim(2),P_value_nii.hdr.dime.pixdim(3),P_value_nii.hdr.dime.pixdim(4)];

 ALmask_nii = load_untouch_nii('AverageFA.nii');
 ALmask_img = ALmask_nii.img;
 P_value_img(isnan(ALmask_img)) = 0;

%bwlabeln
%ClusterImg-a labled matrix for connected components (26-connected neighborhood)
%ClusterNum-the number of connected objects (clusters) found in ClusterImg.
[ClusterImg,ClusterNum]=bwlabeln(P_value_img,26);
for i=1:ClusterNum
    clusterValues=ClusterImg(ClusterImg==i);
    if length(clusterValues)<10
        P_value_img(ClusterImg==i)=0;
    end
end
[ClusterImg,ClusterNum]=bwlabeln(P_value_img,26);

Nii = make_nii(ClusterImg,voxel_size);
Nii.hdr.hist.originator=P_value_nii.hdr.hist.originator;
save_nii(Nii, [P_val_name  '_MDcluster10.nii']);


% uploading MD scans path
nii_Mice_clust_MD = load_untouch_nii([P_val_name  '_MDcluster10.nii']); %H:\AlisaScansDTI\Pablo_smothhed_for_statistics\PBanova1_ttest_cluster10.nii
img_Mice_clust_MD = nii_Mice_clust_MD.img;
%Organize all the Images
path=('/Volumes/SAMSUNG 1/MSc_PhD/DTI_Analysis/smoothed_allscans'); %H:\AlisaScansDTI\Pablo_smothhed_for_statistics\Smoothed % Insert the path of the MD scans

%orgasnize the full path of scans -> WT group  
scan1WT_MD= fuf([path '/swrWT*_scan1_*','MD.nii'],'detail');
scan2WT_MD= fuf([path '/swrWT*_scan2_*','MD.nii'],'detail');
scan3WT_MD= fuf([path '/swrWT*_scan3_*','MD.nii'],'detail');
scan4WT_MD= fuf([path '/swrWT*_scan4_*','MD.nii'],'detail');
scan5WT_MD= fuf([path '/swrWT*_scan5_*','MD.nii'],'detail');
%orgasnize the full path of scans -> KO group  
scan1KO_MD= fuf([path '/swrKO*_scan1_*','MD.nii'],'detail');
scan2KO_MD= fuf([path '/swrKO*_scan2_*','MD.nii'],'detail');
scan3KO_MD= fuf([path '/swrKO*_scan3_*','MD.nii'],'detail');
scan4KO_MD= fuf([path '/swrKO*_scan4_*','MD.nii'],'detail');
scan5KO_MD= fuf([path '/swrKO*_scan5_*','MD.nii'],'detail');

allScansMD=[scan1WT_MD;scan1KO_MD;scan5WT_MD;scan5KO_MD;];
% allScansMD=[scan1WT_MD;scan1KO_MD;scan2WT_MD;scan2KO_MD;scan3WT_MD;scan3KO_MD;scan4WT_MD;scan4KO_MD;scan5WT_MD;scan5KO_MD;];


scannum=2; %number of scans to all mice
WTnum=length(scan1WT_MD);
KOnum=length(scan1KO_MD);

%creating a subject list
Subjects=(1:(WTnum+KOnum))';
cellSubj=cell(1,length(Subjects));
for cellN=1:length(Subjects)
   cellSubj{cellN}=cellN;
end



% create matrix for the results PER SUBJ- MD

columns_titles = {'Subject','clustnum', 'Scan1', 'Scan5'}; %'%change2-1' ,'%change3-2' ,'%change4-3','%change5-4','%change5-1', 'Scan1-std', 'Scan2-std', 'Scan3-std', 'Scan4-std','Scan5-std'
meanValuesRegionMD = cell(1+length(Subjects),length(columns_titles),max(img_Mice_clust_MD(:)));
for c=1:(size(meanValuesRegionMD,3))
    meanValuesRegionMD(1,:,c) = columns_titles;
    meanValuesRegionMD(2:end,1,c) = cellSubj;
    meanValuesRegionMD(2:end,2,c)={c};
end
% run through subjects & clusters  - MD

for clust_MD=1:max(img_Mice_clust_MD(:)) %loop for each cluster
    img_clust_MD = ismember(img_Mice_clust_MD,clust_MD); %creat 1/0 image of the cluster
    for subjectInd = 1:length(Subjects) %loop for each subject
        mean_scan=zeros(1,scannum); %scans for each subject
        count=0;
        for scan=subjectInd:length(Subjects):(scannum*length(Subjects)) %loop for each scan
            count=count+1;
            nii_normalized = load_untouch_nii(allScansMD{scan});%uploading nii scan
            img_normalized = nii_normalized.img;%taking the image matrix
            img_normalized = img_normalized.*1000;
            region_scan = img_normalized(img_clust_MD);  %taking voxels from image cluster
            region_scan = region_scan(~isnan(region_scan)); %removing all NaN values
            mean_scan (1,count) = mean(region_scan(:)); %mean of cluster
            meanValuesRegionMD{1+subjectInd,2+count,clust_MD}= mean_scan (1,count);
        end %end for all scans for one subject      
    end % end for subjectInd
end

save('Whithin_meanValuesMD_subj.mat','meanValuesRegionMD');
% save('Interaction_meanValuesMD_subj.mat','meanValuesRegionMD');
%save('Between_meanValuesMD_subj.mat','meanValuesRegionMD');



% create matrix for the results PER GROUP - MD

resGroups = {'WT_Avg', 'WT_SEM','KO_Avg', 'KO_SEM'}';
columns_titles_res = {'Group','clustnum', 'Scan1','Scan5'}; 
ResCell_MD = cell(length(resGroups)+1,length(columns_titles_res),max(img_Mice_clust_MD(:)));

for res_MD=1:(size(meanValuesRegionMD,3)) %loop for each cluster
    ResCell_MD(1,:,res_MD) = columns_titles_res;
    ResCell_MD(2:end,1,res_MD) = resGroups;
    ResCell_MD(2:end,2,res_MD) = {res_MD};
    for sc=1:scannum %loop for each scan
        ResCell_MD{2,2+sc,res_MD}=mean([(meanValuesRegionMD{(2:(WTnum+1)),2+sc,res_MD})]);
        ResCell_MD{3,2+sc,res_MD}=std([meanValuesRegionMD{(2:(WTnum+1)),2+sc,res_MD}])/sqrt(WTnum);
        ResCell_MD{4,2+sc,res_MD}=mean([meanValuesRegionMD{((WTnum+2):(WTnum+KOnum+1)),2+sc,res_MD}]);
        ResCell_MD{5,2+sc,res_MD}=std([meanValuesRegionMD{((WTnum+2):(WTnum+KOnum+1)),2+sc,res_MD}])/sqrt(KOnum);
    end
end


% change the name according to the kind of statistics

save('Whithin_ResCell_MD.mat','ResCell_MD');
%save('Interaction_ResCell_MD.mat','ResCell_MD');
%save('Between_ResCell_MD.mat','ResCell_MD');
