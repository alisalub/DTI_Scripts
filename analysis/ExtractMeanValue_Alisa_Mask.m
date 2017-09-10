%%%% ExtractMeanValue(regionNum,group)

%% creating cluster images - FA
P_value_nii=load_nii('F:\MSC\AlisaScansDTI\AlisaScriptsDTI\analysis\ALanovaFA1_ttest.nii'); %load Anova image
P_value_img=P_value_nii.img;
voxel_size=[P_value_nii.hdr.dime.pixdim(2),P_value_nii.hdr.dime.pixdim(3),P_value_nii.hdr.dime.pixdim(4)];

 PBmask_nii = load_untouch_nii('PBmask.nii');
 PBmask_img = PBmask_nii.img;
 P_value_img(isnan(PBmask_img)) = 0;

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

save_nii(Nii, 'ALanovaFA1_ttest_cluster10.nii');

%% creating cluster images - MD
P_value_nii=load_nii('F:\MSC\AlisaScansDTI\AlisaScriptsDTI\analysis\ALanovaMD1_ttest.nii');
P_value_img=P_value_nii.img;
voxel_size=[P_value_nii.hdr.dime.pixdim(2),P_value_nii.hdr.dime.pixdim(3),P_value_nii.hdr.dime.pixdim(4)];

 PBmask_nii = load_untouch_nii('PBmask.nii');
 PBmask_img = PBmask_nii.img;
 P_value_img(isnan(PBmask_img)) = 0;

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

save_nii(Nii, 'ALanovaMD1_ttest_cluster10.nii');

%% 
% load atlas template and images
nii_Mice_clust_FA = load_untouch_nii('I:\MSC\AlisaScansDTI\AlisaScriptsDTI\analysis\MaskCC.nii'); %H:\AlisaScansDTI\Pablo_smothhed_for_statistics\PBanova1FA_ttest_cluster10.nii
img_Mice_clust_FA = nii_Mice_clust_FA.img;
nii_Mice_clust_MD = load_untouch_nii('I:\MSC\AlisaScansDTI\AlisaScriptsDTI\analysis\MaskCortexMD.nii'); %H:\AlisaScansDTI\Pablo_smothhed_for_statistics\PBanova1_ttest_cluster10.nii
img_Mice_clust_MD = nii_Mice_clust_MD.img;
% 

%Organize all the Images
path=('I:\MSC\AlisaScansDTI\Smoothed copy'); %H:\AlisaScansDTI\Pablo_smothhed_for_statistics\Smoothed % Insert the path of the MD scans
%uploading FA scans path
Scan1_FA= fuf([path '\swPB*' ,'*scan1*', 'FA.nii'],'detail');
Scan2_FA= fuf([path '\swPB*' ,'*scan2*', 'FA.nii'],'detail');
Scan3_FA= fuf([path '\swPB*' ,'*scan3*', 'FA.nii'],'detail');
Scan4_FA= fuf([path '\swPB*' ,'*scan4*', 'FA.nii'],'detail');
Scan5_FA= fuf([path '\swPB*' ,'*scan5*', 'FA.nii'],'detail');
Scan6_FA= fuf([path '\swPB*' ,'*scan6*', 'FA.nii'],'detail');

allScansFA=[Scan1_FA;Scan2_FA;Scan3_FA;Scan4_FA;Scan5_FA;Scan6_FA];

%uploading MD scans path
Scan1_MD= fuf([path '\swPB*' ,'*scan1*', 'MD.nii'],'detail');
Scan2_MD= fuf([path '\swPB*' ,'*scan2*', 'MD.nii'],'detail');
Scan3_MD= fuf([path '\swPB*' ,'*scan3*', 'MD.nii'],'detail');
Scan4_MD= fuf([path '\swPB*' ,'*scan4*', 'MD.nii'],'detail');
Scan5_MD= fuf([path '\swPB*' ,'*scan5*', 'MD.nii'],'detail');
Scan6_MD= fuf([path '\swPB*' ,'*scan6*', 'MD.nii'],'detail');

allScansMD=[Scan1_MD;Scan2_MD;Scan3_MD;Scan4_MD;Scan5_MD;Scan6_MD];

scannum=6; %number of scans to all mice

%creating a subject list
Subjects=cell(1,length(Scan1_MD));
for subj=1:length(Scan1_MD)
    Subjects{subj}=char(Scan1_MD{subj}(38:40)); %59:61
end

%%
% create matrix for the results - FA & MD
meanValuesRegionFA = cell(1+length(Subjects),20);
columns_titles = {'Subject','clustnum', 'Scan1', 'Scan2', 'Scan3', 'Scan4','Scan5','Scan6','%change2-1' ,'%change3-2' ,'%change4-3','%change5-4','%change6-5','%change6-1', 'Scan1-std', 'Scan2-std', 'Scan3-std', 'Scan4-std','Scan5-std','Scan6-std'};
meanValuesRegionFA(1,:) = columns_titles;
meanValuesRegionFA(2:end,1) = Subjects;
meanValuesRegionFA(2:end,2)={'CC'};

meanValuesRegionMD = cell(1+length(Subjects),20);
columns_titles = {'Subject','clustnum', 'Scan1', 'Scan2', 'Scan3', 'Scan4','Scan5','Scan6','%change2-1' ,'%change3-2' ,'%change4-3','%change5-4','%change6-5','%change6-1', 'Scan1-std', 'Scan2-std', 'Scan3-std', 'Scan4-std','Scan5-std','Scan6-std'};
meanValuesRegionMD(1,:) = columns_titles;
meanValuesRegionMD(2:end,1) = Subjects;
meanValuesRegionMD(2:end,2)={'Cortex'};


% run through subjects & clusters  - FA


for clust_FA=1:1; %loop for each cluster
    img_clust_FA = logical(img_Mice_clust_FA); %creat 1/0 image of the cluster
    for subjectInd = 1:length(Subjects) %loop for each subject
        mean_scan=zeros(1,scannum); %scans for each subject
        std_scan=zeros(1,scannum); %scans std for each subject
        count=0;
        for scan=subjectInd:length(Subjects):(scannum*length(Subjects)) %loop for each scan
            count=count+1;
            nii_normalized = load_untouch_nii(allScansFA{scan});%uploading nii scan
            img_normalized = nii_normalized.img; %taking the image matrix
            region_scan = img_normalized(img_clust_FA);  %taking voxels from image cluster
            region_scan = region_scan(~isnan(region_scan)); %removing all NaN values
            mean_scan (1,count) = mean(region_scan(:)); %mean of cluster
            std_scan (1,count) = std(region_scan(:)); %std of cluster
        end %end for all scans for one subject
        meanValuesRegionFA{1+subjectInd,3} = mean_scan(1,1);
        meanValuesRegionFA{1+subjectInd,4} = mean_scan(1,2);
        meanValuesRegionFA{1+subjectInd,5} = mean_scan(1,3);
        meanValuesRegionFA{1+subjectInd,6} = mean_scan(1,4);
        meanValuesRegionFA{1+subjectInd,7} = mean_scan(1,5);
        meanValuesRegionFA{1+subjectInd,8} = mean_scan(1,6);
        meanValuesRegionFA{1+subjectInd,9} = ((meanValuesRegionFA{1+subjectInd,4}-meanValuesRegionFA{1+subjectInd,3})/meanValuesRegionFA{1+subjectInd,3})*100;
        meanValuesRegionFA{1+subjectInd,10} = ((meanValuesRegionFA{1+subjectInd,5}-meanValuesRegionFA{1+subjectInd,4})/meanValuesRegionFA{1+subjectInd,4})*100;
        meanValuesRegionFA{1+subjectInd,11}= ((meanValuesRegionFA{1+subjectInd,6}-meanValuesRegionFA{1+subjectInd,5})/meanValuesRegionFA{1+subjectInd,5})*100;
        meanValuesRegionFA{1+subjectInd,12}= ((meanValuesRegionFA{1+subjectInd,7}-meanValuesRegionFA{1+subjectInd,6})/meanValuesRegionFA{1+subjectInd,6})*100;
        meanValuesRegionFA{1+subjectInd,13}= ((meanValuesRegionFA{1+subjectInd,8}-meanValuesRegionFA{1+subjectInd,7})/meanValuesRegionFA{1+subjectInd,7})*100;
        meanValuesRegionFA{1+subjectInd,14}= ((meanValuesRegionFA{1+subjectInd,8}-meanValuesRegionFA{1+subjectInd,3})/meanValuesRegionFA{1+subjectInd,3})*100;
        meanValuesRegionFA{1+subjectInd,15} = std_scan(1,1);
        meanValuesRegionFA{1+subjectInd,16} = std_scan(1,2);
        meanValuesRegionFA{1+subjectInd,17} = std_scan(1,3);
        meanValuesRegionFA{1+subjectInd,18} = std_scan(1,4);
        meanValuesRegionFA{1+subjectInd,19} = std_scan(1,5);
        meanValuesRegionFA{1+subjectInd,20} = std_scan(1,6);
        
    end % end for subjectInd
end


for clust_MD=1:1; %loop for each cluster
    img_clust_MD = logical(img_Mice_clust_MD); %creat 1/0 image of the cluster
    for subjectInd = 1:length(Subjects) %loop for each subject
        mean_scan=zeros(1,scannum); %scans for each subject
        std_scan=zeros(1,scannum); %scans std for each subject
        count=0;
        for scan=subjectInd:length(Subjects):(scannum*length(Subjects)) %loop for each scan
            count=count+1;
            nii_normalized = load_untouch_nii(allScansMD{scan});%uploading nii scan
            img_normalized = nii_normalized.img; %taking the image matrix
            region_scan = img_normalized(img_clust_MD);  %taking voxels from image cluster
            region_scan = region_scan(~isnan(region_scan)); %removing all NaN values
            mean_scan (1,count) = mean(region_scan(:)); %mean of cluster
            std_scan (1,count) = std(region_scan(:)); %std of cluster
        end %end for all scans for one subject
        meanValuesRegionMD{1+subjectInd,3} = mean_scan(1,1);
        meanValuesRegionMD{1+subjectInd,4} = mean_scan(1,2);
        meanValuesRegionMD{1+subjectInd,5} = mean_scan(1,3);
        meanValuesRegionMD{1+subjectInd,6} = mean_scan(1,4);
        meanValuesRegionMD{1+subjectInd,7} = mean_scan(1,5);
        meanValuesRegionMD{1+subjectInd,8} = mean_scan(1,6);
        meanValuesRegionMD{1+subjectInd,9} = ((meanValuesRegionMD{1+subjectInd,4}-meanValuesRegionMD{1+subjectInd,3})/meanValuesRegionMD{1+subjectInd,3})*100;
        meanValuesRegionMD{1+subjectInd,10} = ((meanValuesRegionMD{1+subjectInd,5}-meanValuesRegionMD{1+subjectInd,4})/meanValuesRegionMD{1+subjectInd,4})*100;
        meanValuesRegionMD{1+subjectInd,11}= ((meanValuesRegionMD{1+subjectInd,6}-meanValuesRegionMD{1+subjectInd,5})/meanValuesRegionMD{1+subjectInd,5})*100;
        meanValuesRegionMD{1+subjectInd,12}= ((meanValuesRegionMD{1+subjectInd,7}-meanValuesRegionMD{1+subjectInd,6})/meanValuesRegionMD{1+subjectInd,6})*100;
        meanValuesRegionMD{1+subjectInd,13}= ((meanValuesRegionMD{1+subjectInd,8}-meanValuesRegionMD{1+subjectInd,7})/meanValuesRegionMD{1+subjectInd,7})*100;
        meanValuesRegionMD{1+subjectInd,14}= ((meanValuesRegionMD{1+subjectInd,8}-meanValuesRegionMD{1+subjectInd,3})/meanValuesRegionMD{1+subjectInd,3})*100;
        meanValuesRegionMD{1+subjectInd,15} = std_scan(1,1);
        meanValuesRegionMD{1+subjectInd,16} = std_scan(1,2);
        meanValuesRegionMD{1+subjectInd,17} = std_scan(1,3);
        meanValuesRegionMD{1+subjectInd,18} = std_scan(1,4);
        meanValuesRegionMD{1+subjectInd,19} = std_scan(1,5);
        meanValuesRegionMD{1+subjectInd,20} = std_scan(1,6);
        
    end % end for subjectInd
end

save('meanValuesRegionMD1_Cortex.mat','meanValuesRegionMD');
save('meanValuesRegionFA1_cc.mat','meanValuesRegionFA');