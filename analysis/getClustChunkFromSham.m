function allData = getClustChunkFromSham(folderOfScans, fileWithClusters)
    % Go through all files in the folder (all separate scans) and calculate
    % the mean FA, MD and T2 in all specific clusters for all sham mice.
    % Data structure is identical to the input of 'loadDataAndPlot': One
    % cell array for each scan type, containing a header line with the scan
    % number, and a row for each mouse. Another cell array, of the mean and
    % STD values, should be generated.
    
    %% Parameters
    typesToParse = {'FA', 'MD'}%, 'T2'};
    
    %% Create and load data structures
    % Load cluster data and extract the brain volume for each cluster
    clustData = load_untouch_nii([folderOfScans, filesep, fileWithClusters]); %'WT_VS_KO_16mice_p_main_interaction_MD_FDR_MDcluster10.nii'
    clustData = clustData.img;
    numOfClusts = max(clustData(:));
    MAX_NUM_OF_SCANS = 7;
    
    % Find out how many mice we have  
    T2Scans = dir([folderOfScans,  filesep, 'swrTsham*_scan2_*T2.nii']);
    numOfMice = size(T2Scans, 1);
    
    % Initiate the cell array holding the data
    rawCellArray = cell(numOfMice + 1, MAX_NUM_OF_SCANS + 2);
    meanCellArray = cell(3, MAX_NUM_OF_SCANS + 2);  % 3 - one row for mean, one for SEM and one for the header
    rawCellArray(1, :) = {'Subject', 'clustnum', 'Scan1', 'Scan2', 'Scan3', 'Scan4', 'Scan5', 'Scan6', 'Scan7'};
    meanCellArray(1, :) = {'Group', 'clustnum', 'Scan1', 'Scan2', 'Scan3', 'Scan4', 'Scan5', 'Scan6', 'Scan7'};
    meanCellArray(2, 1) = {'sham_Mean'};
    meanCellArray(3, 1) = {'sham_SEM'};
    allData = containers.Map(typesToParse, {cell(1, 2), cell(1, 2), cell(1, 2)});  % Inner cells are {raw, mean}
    
    %% Start parsing the folder by cluster
    
    for clust = 1:numOfClusts
        curClustMask = clustData == clust;
        for scanType = keys(allData)
            curRawData = rawCellArray;
            curMeanData = meanCellArray;
            for scanNum = 1:MAX_NUM_OF_SCANS
               curScan = ['scan' num2str(scanNum)];
               listOfMice = dir([folderOfScans, filesep, 'swrTsham*_' curScan '*_native_' scanType{1} '*.nii']);
               for mouseNum = 1:size(listOfMice, 1)
                   curMouse = load_untouch_nii([listOfMice(mouseNum).folder, filesep, listOfMice(mouseNum).name]);
                   curMouse = curMouse.img;
                   if scanType{1} == 'MD'  % Changed by Alisa and Hagai due to unknown reasons 14-9-17
                       curMouse = curMouse .* 1000;
                   end
                   maskedMouse = curMouse(curClustMask);
                   curRawData{mouseNum + 1, scanNum + 2} = mean(maskedMouse(:));
               end
               curMeanData{2, scanNum + 2} = mean(cell2mat(curRawData(2:end, scanNum + 2)));
               curMeanData{3, scanNum + 2} = std(cell2mat(curRawData(2:end, scanNum + 2))) ./ sqrt(mouseNum);
               fprintf('Scan number %d for type %s complete.\n', scanNum, scanType{1});
            end
            % Concatenate the new data to the old one
            curRawData(2:end, 2) = {clust};
            curMeanData(2:end, 2) = {clust};
            if clust == 1
                accumRaw = curRawData;
                accumMean = curMeanData;
            else
                curData = allData(scanType{1});
                accumRaw = curData(1, 1);
                accumMean = curData(1, 2);
                accumRaw = cat(3, accumRaw{1}, curRawData);
                accumMean = cat(3, accumMean{1}, curMeanData);
            end
            
            allData(scanType{1}) = {accumRaw, accumMean};
            fprintf('Cluster %d complete.\n', clust);
        end 
    end
   
    save([folderOfScans, filesep, fileWithClusters(1:end-4), '_shamClustersGroupedData' '.mat'], 'allData');
end