%%%% ExtractMeanValue(regionNum,group)
 
%% creating cluster images 
P_value_nii=load_nii('/Volumes/SAMSUNG 1/MSc_PhD/DTI_Analysis/smoothed_allscans/AL_anova_meanMD.nii'); %H:\AlisaScansDTI\Pablo_smothhed_for_statistics\PBanova1FA_ttest.nii %load Anova image
P_value_img=P_value_nii.img;
voxel_size=[P_value_nii.hdr.dime.pixdim(2),P_value_nii.hdr.dime.pixdim(3),P_value_nii.hdr.dime.pixdim(4)];
 
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
save_nii(Nii, 'AL_anova_meanMD_cluster10.nii');
%save_nii(Nii, 'AL_anova_meanFA_cluster10.nii');
%%
 
 
% load atlas template and images
nii_Mice_clust_FA = load_untouch_nii('/Volumes/SAMSUNG 1/MSc_PhD/DTI_Analysis\AL_anova_meanFA_cluster10.nii'); %H:\AlisaScansDTI\Pablo_smothhed_for_statistics\PBanova1FA_ttest_cluster10.nii
img_Mice_clust_FA = nii_Mice_clust_FA.img;
nii_Mice_clust_MD = load_untouch_nii('/Volumes/SAMSUNG 1/MSc_PhD/DTI_Analysis\AL_anova_meanMD_cluster10.nii'); %H:\AlisaScansDTI\Pablo_smothhed_for_statistics\PBanova1_ttest_cluster10.nii
img_Mice_clust_MD = nii_Mice_clust_MD.img;
 
 
% %% General parametes
% path = '/Volumes/SAMSUNG 1/MSc_PhD/DTI_Analysis/T2_masks_orig_multiply_manually_zero_registered/registered_T2_masked_2000_aniso_smooth';
% cd(path)

% cur_dir = dir(path);
% cur_dir_file_names = string({cur_dir.name}');  % names of all files in folder
% 
% mice = find_all_mice_tags(path);
% scans = {'scan1', 'scan2', 'scan3', 'scan4', 'scan5'}';

% sum_data = containers.Map;
% scan_data = cell(size(scans));
% scan_idx = 1;
% mouse_idx = 1;
% mice_array = cell(size(mice));
% 

%Organize all the Images 
path=('/Volumes/SAMSUNG 1/MSc_PhD/DTI_Analysis/smoothed_allscans'); %H:\AlisaScansDTI\Pablo_smothhed_for_statistics\Smoothed % Insert the path of the MD scans
%uploading FA scans path
Scan1_FA= fuf([path '\swPB*' ,'*scan1*', 'FA.nii'],'detail');
Scan2_FA= fuf([path '\swPB*' ,'*scan2*', 'FA.nii'],'detail');
Scan3_FA= fuf([path '\swPB*' ,'*scan3*', 'FA.nii'],'detail');
Scan4_FA= fuf([path '\swPB*' ,'*scan4*', 'FA.nii'],'detail');
Scan5_FA= fuf([path '\swPB*' ,'*scan5*', 'FA.nii'],'detail');
Scan6_FA= fuf([path '\swPB*' ,'*scan6*', 'FA.nii'],'detail');
Scan7_FA= fuf([path '\swPB*' ,'*scan7*', 'FA.nii'],'detail');
 
allScansFA=[Scan1_FA;Scan2_FA;Scan3_FA;Scan4_FA;Scan5_FA;Scan6_FA; Scan7_FA]; 
 
%uploading MD scans path
Scan1_MD= fuf([path '\swPB*' ,'*scan1*', 'MD.nii'],'detail');
Scan2_MD= fuf([path '\swPB*' ,'*scan2*', 'MD.nii'],'detail');
Scan3_MD= fuf([path '\swPB*' ,'*scan3*', 'MD.nii'],'detail');
Scan4_MD= fuf([path '\swPB*' ,'*scan4*', 'MD.nii'],'detail');
Scan5_MD= fuf([path '\swPB*' ,'*scan5*', 'MD.nii'],'detail');
Scan6_MD= fuf([path '\swPB*' ,'*scan6*', 'MD.nii'],'detail');
Scan7_MD= fuf([path '\swPB*' ,'*scan7*', 'MD.nii'],'detail');

 
allScansMD=[Scan1_MD;Scan2_MD;Scan3_MD;Scan4_MD;Scan5_MD;Scan6_MD; Scan7_MD]; 
 
scannum=5; %number of scans to all mice
 
%creating a subject list
Subjects=cell(1,length(Scan1_FA));
for subj=1:length(Scan1_FA)
Subjects{subj}=char(Scan1_FA{subj}(40:42)); %59:61
end
 
% create matrix for the results - FA & MD 
meanValuesRegionFA = cell(1+length(Subjects),14,max(img_Mice_clust_FA(:)-1));
columns_titles = {'Subject','clustnum', 'Scan1', 'Scan2', 'Scan3', 'Scan4','Scan5','%change2-1' ,'%change3-2' ,'%change4-3','%change5-4','%change5-1'};
for c=2:(size(meanValuesRegionFA,3)+1)
meanValuesRegionFA(1,:,c-1) = columns_titles;
meanValuesRegionFA(2:end,1,c-1) = Subjects;
meanValuesRegionFA(2:end,2,c-1)={c};
end
 
meanValuesRegionMD = cell(1+length(Subjects),14,max(img_Mice_clust_MD(:)-1));
columns_titles = {'Subject','clustnum', 'Scan1', 'Scan2', 'Scan3', 'Scan4','Scan5','%change2-1' ,'%change3-2' ,'%change4-3','%change5-4','%change5-1'};
for c=2:(size(meanValuesRegionMD,3)+1)
meanValuesRegionMD(1,:,c-1) = columns_titles;
meanValuesRegionMD(2:end,1,c-1) = Subjects;
meanValuesRegionMD(2:end,2,c-1)={c};
end 
 
% run through subjects & clusters  - FA
 
 
for clust_FA=2:max(img_Mice_clust_FA(:)) %loop for each cluster
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
        end %end for all scans for one subject
        meanValuesRegionFA{1+subjectInd,3,clust_FA-1} = mean_scan(1,1);
        meanValuesRegionFA{1+subjectInd,4,clust_FA-1} = mean_scan(1,2);
        meanValuesRegionFA{1+subjectInd,5,clust_FA-1} = mean_scan(1,3);
        meanValuesRegionFA{1+subjectInd,6,clust_FA-1} = mean_scan(1,4);
        meanValuesRegionFA{1+subjectInd,7,clust_FA-1} = mean_scan(1,5);
        meanValuesRegionFA{1+subjectInd,8,clust_FA-1} = mean_scan(1,6);
        meanValuesRegionFA{1+subjectInd,9,clust_FA-1} = ((meanValuesRegionFA{1+subjectInd,4,clust_FA-1}-meanValuesRegionFA{1+subjectInd,3,clust_FA-1})/meanValuesRegionFA{1+subjectInd,3,clust_FA-1})*100;
        meanValuesRegionFA{1+subjectInd,10,clust_FA-1} = ((meanValuesRegionFA{1+subjectInd,5,clust_FA-1}-meanValuesRegionFA{1+subjectInd,4,clust_FA-1})/meanValuesRegionFA{1+subjectInd,4,clust_FA-1})*100;
        meanValuesRegionFA{1+subjectInd,11,clust_FA-1}= ((meanValuesRegionFA{1+subjectInd,6,clust_FA-1}-meanValuesRegionFA{1+subjectInd,5,clust_FA-1})/meanValuesRegionFA{1+subjectInd,5,clust_FA-1})*100;
        meanValuesRegionFA{1+subjectInd,12,clust_FA-1}= ((meanValuesRegionFA{1+subjectInd,7,clust_FA-1}-meanValuesRegionFA{1+subjectInd,6,clust_FA-1})/meanValuesRegionFA{1+subjectInd,6,clust_FA-1})*100;
        meanValuesRegionFA{1+subjectInd,13,clust_FA-1}= ((meanValuesRegionFA{1+subjectInd,8,clust_FA-1}-meanValuesRegionFA{1+subjectInd,7,clust_FA-1})/meanValuesRegionFA{1+subjectInd,7,clust_FA-1})*100;
        meanValuesRegionFA{1+subjectInd,14,clust_FA-1}= ((meanValuesRegionFA{1+subjectInd,8,clust_FA-1}-meanValuesRegionFA{1+subjectInd,3,clust_FA-1})/meanValuesRegionFA{1+subjectInd,3,clust_FA-1})*100;
        
    end % end for subjectInd
end
 
 
for clust_MD=2:max(img_Mice_clust_MD(:)); %loop for each cluster
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
        end %end for all scans for one subject
        meanValuesRegionMD{1+subjectInd,3,clust_MD-1} = mean_scan(1,1);
        meanValuesRegionMD{1+subjectInd,4,clust_MD-1} = mean_scan(1,2);
        meanValuesRegionMD{1+subjectInd,5,clust_MD-1} = mean_scan(1,3);
        meanValuesRegionMD{1+subjectInd,6,clust_MD-1} = mean_scan(1,4);
        meanValuesRegionMD{1+subjectInd,7,clust_MD-1} = mean_scan(1,5);
        meanValuesRegionMD{1+subjectInd,8,clust_MD-1} = mean_scan(1,6);
        meanValuesRegionMD{1+subjectInd,9,clust_MD-1} = ((meanValuesRegionMD{1+subjectInd,4,clust_MD-1}-meanValuesRegionMD{1+subjectInd,3,clust_MD-1})/meanValuesRegionMD{1+subjectInd,3,clust_MD-1})*100;
        meanValuesRegionMD{1+subjectInd,10,clust_MD-1} = ((meanValuesRegionMD{1+subjectInd,5,clust_MD-1}-meanValuesRegionMD{1+subjectInd,4,clust_MD-1})/meanValuesRegionMD{1+subjectInd,4,clust_MD-1})*100;
        meanValuesRegionMD{1+subjectInd,11,clust_MD-1}= ((meanValuesRegionMD{1+subjectInd,6,clust_MD-1}-meanValuesRegionMD{1+subjectInd,5,clust_MD-1})/meanValuesRegionMD{1+subjectInd,5,clust_MD-1})*100;
        meanValuesRegionMD{1+subjectInd,12,clust_MD-1}= ((meanValuesRegionMD{1+subjectInd,7,clust_MD-1}-meanValuesRegionMD{1+subjectInd,6,clust_MD-1})/meanValuesRegionMD{1+subjectInd,6,clust_MD-1})*100;
        meanValuesRegionMD{1+subjectInd,13,clust_MD-1}= ((meanValuesRegionMD{1+subjectInd,8,clust_MD-1}-meanValuesRegionMD{1+subjectInd,7,clust_MD-1})/meanValuesRegionMD{1+subjectInd,7,clust_MD-1})*100;
        meanValuesRegionMD{1+subjectInd,14,clust_MD-1}= ((meanValuesRegionMD{1+subjectInd,8,clust_MD-1}-meanValuesRegionMD{1+subjectInd,3,clust_MD-1})/meanValuesRegionMD{1+subjectInd,3,clust_MD-1})*100;
        
    end % end for subjectInd
end

save('meanValuesRegionMD.mat','meanValuesRegionMD');
save('meanValuesRegionFA.mat','meanValuesRegionFA');