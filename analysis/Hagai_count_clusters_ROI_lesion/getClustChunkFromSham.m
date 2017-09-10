function listOfShamMice = getClustChunkFromSham(folderOfScans, fileWithClusters)
    % Go through all files in the folder (all separate scans) and calculate
    % the mean FA, MD and T2 in all specific clusters for all sham mice.
    % Data structure is as follows:
    % Each line in the struct listOfClusters is a struct in itself, with
    % the scan numbers as the field name. Each cell is a structured array, a line per mouse, with
    % the three types of scans (typesToParse) as its fields. Each type of scan has a mean
    % and SEM value attached to it, as a map.
    
    %% Parameters
    typesToParse = {'FA', 'MD', 'T2'};
    genotypesToDisplay = {'KO', 'WT', 'sham'};  % Out of {'KO', 'WT', 'sham'}
    typesToDisplay = {'FA', 'MD', 'T2'};  % Out of {'FA', 'MD', 'T2'};
    
    %% Create and load data structures
    % Load cluster data and extract the brain volume for each cluster
    clustData = load_untouch_nii('WT_VS_KO_16mice_p_main_Between_WTvsKO_FA_FDR_FAcluster10.nii');
    clustData = clustData.img;
    numOfClusts = max(clustData(:));
    MAX_NUM_OF_SCANS = 7;
    listOfClusters = struct();
    valueStruct = struct('mean', {}, 'sem', {});
    % Initiate this complex data structure
    for scanNum = 1:MAX_NUM_OF_SCANS
       listOfClusters(1).(['scan' num2str(scanNum)]) = struct('name', {}, 'summedVol', {}, ...
                                                              'manualMask', {}, 'lesionOnly', {}, ...
                                                              'croppedVol', {}, 'lesionMask', {});
        for type = typesToParse
            listOfClusters(1).(['scan' num2str(scanNum)]).(type{1}) = valueStruct;
        end
    end
    % Find out how many mice we have  
    T2Scans = dir([workDir, '/swrTsham*_scan2_*T2.nii']);
    numOfMice = size(T2Scans, 1);
    
    %% Start parsing the folder by cluster
    
    for clust = 1:numOfClusts
        curClustMask = clustData == clust;
        for scanNum = 1:MAX_NUM_OF_SCANS
           curScan = ['scan' num2str(scanNum)];
           listOfMice = groupMiceInFolder(folderOfScans, ['swrTsham*_scan' num2str(scanNum)]);
           for miceNum = 1:size(listOfMice, 2)
              listOfClusters(clust).(curScan).name = ['sham' num2str(miceNum)];
           end
        end
        
    end
    allMouseScans = groupMiceInFolder(folderOfScans, mouseName);
    
end