%%%% ExtractMeanValue(regionNum,group)

%% creating cluster images 
P_value_nii=load_nii('H:\AlisaScansDTI\Pablo_smothhed_for_statistics\PBanova1FA_ttest.nii'); %load Anova image
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
save_nii(Nii, 'PBanova1FA_ttest_cluster10.nii');

%%


% load atlas template and images
nii_Mice_clust = load_untouch_nii('H:\AlisaScansDTI\Pablo_smothhed_for_statistics\PBanova1FA_ttest_cluster10.nii');
img_Mice_clust = nii_Mice_clust.img;


%Organize all the Images 
path=('H:\AlisaScansDTI\Pablo_smothhed_for_statistics\Smoothed'); %Insert the path of the MD scans
type='FA';
%type='MD';

% 
Scan1= fuf([path '\swPB*' ,'*scan1*', type '.nii'],'detail');
Scan2= fuf([path '\swPB*' ,'*scan2*', type '.nii'],'detail');
Scan3= fuf([path '\swPB*' ,'*scan3*', type '.nii'],'detail');
Scan4= fuf([path '\swPB*' ,'*scan4*', type '.nii'],'detail');
Scan5= fuf([path '\swPB*' ,'*scan5*', type '.nii'],'detail');
Scan6= fuf([path '\swPB*' ,'*scan6*', type '.nii'],'detail');

%creating a subject list
Subjects=cell(1,length(Scan1));
for subj=1:length(Scan1)
Subjects{subj}=char(Scan1{subj}(59:61));
end

% create matrix for the results
meanValuesRegion = cell(1+length(Subjects),7);
columns_titles = {'Subject', 'Scan1', 'Scan2', 'Scan3', 'Scan4','Scan5','Scan6'};
meanValuesRegion(1,:) = columns_titles;
meanValuesRegion(2:end,1) = Subjects;

% run through subjects and calculate: 'after' scans
for clust=1:max(img_Mice_clust(:));
    img_clust = ismember(img_Mice_clust,clust); %creat 1/0 image of the cluster
    for subjectInd = 1:length(Subjects)
        %uploading Nii files for each subj
        nii_normalized_scan1 = load_untouch_nii(Scan1{subjectInd});
        nii_normalized_scan2 = load_untouch_nii(Scan2{subjectInd});
        nii_normalized_scan3 = load_untouch_nii(Scan3{subjectInd});
        nii_normalized_scan4 = load_untouch_nii(Scan4{subjectInd});
        nii_normalized_scan5 = load_untouch_nii(Scan5{subjectInd});
        nii_normalized_scan6 = load_untouch_nii(Scan6{subjectInd});
        %uploading the image matrix
        img_normalized_scan1 = nii_normalized_scan1.img;
        img_normalized_scan2 = nii_normalized_scan2.img;
        img_normalized_scan3 = nii_normalized_scan3.img;
        img_normalized_scan4 = nii_normalized_scan4.img;
        img_normalized_scan5 = nii_normalized_scan5.img;
        img_normalized_scan6 = nii_normalized_scan6.img;
        %taking voxels from image cluster 
        region_scan1 = img_normalized_scan1(img_clust);
        region_scan1 = region_scan1(~isnan(region_scan1));
        region_scan2 = img_normalized_scan2(img_clust);
        region_scan2 = region_scan2(~isnan(region_scan2));
        region_scan3 = img_normalized_scan3(img_clust);
        region_scan3 = region_scan3(~isnan(region_scan3));
        region_scan4 = img_normalized_scan4(img_clust);
        region_scan4 = region_scan4(~isnan(region_scan4));
        region_scan5 = img_normalized_scan5(img_clust);
        region_scan5 = region_scan5(~isnan(region_scan5));
        region_scan6 = img_normalized_scan6(img_clust);
        region_scan6 = region_scan6(~isnan(region_scan6));
        
        mean_scan1 = mean(region_scan1(:)); 
        mean_scan2 = mean(region_scan2(:));        
        mean_scan3 = mean(region_scan3(:));
        mean_scan4 = mean(region_scan4(:));
        mean_scan5 = mean(region_scan5(:));
        mean_scan6 = mean(region_scan6(:));

        meanValuesRegion{1+subjectInd,2} = mean_scan1;
        meanValuesRegion{1+subjectInd,3} = mean_scan2;
        meanValuesRegion{1+subjectInd,4} = mean_scan3;
        meanValuesRegion{1+subjectInd,5} = mean_scan4;
        meanValuesRegion{1+subjectInd,6} = mean_scan5;
        meanValuesRegion{1+subjectInd,7} = mean_scan6;
      
        
    end % end for subjectInd_after
end

%save to excel file
if group==1
    groupID='Reconsolidation';
else
    if group==2
    groupID='Extinction';
    else
    groupID='Control';
    end
end


FileName=['meanValuesRegion_' groupID '_RegionNum_' num2str(regionNum)];
xlswrite(FileName,meanValuesRegion);


end % end function