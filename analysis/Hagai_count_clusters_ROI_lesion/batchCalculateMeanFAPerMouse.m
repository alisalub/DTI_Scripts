% Main script for the analysis and plotting of the FA/MD/T2 data in a selected area.
% For each mouse, use ROIPOLY to define the lesion area in a specific
% mouse. Then calculate the mean FA values in that area and plot them.
% Delete the 'listOfMice' variable if you wish to start over.

%% Parameters
analyzeGeneralROI = false;  % change to true if you want to work on general ROI
numOfMice = 24;
if analyzeGeneralROI
    fSlice = 46;
    lSlice = 53; 
    FirstSliceVector = repmat(fSlice, 1, numOfMice);
    LastSliceVector = repmat(lSlice, 1, numOfMice);
else
    %                   ko                      wt                      sh   
    FirstSliceVector = [50 46 43 45 43 47 45 52 48 44 46 48 44 45 47 47 46 48 46 46 46 46 46 46];
    LastSliceVector =  [57 50 48 51 50 51 55 58 58 53 52 53 50 50 50 51 50 51 50 49 49 49 49 49];
end
workDir = '/Volumes/Data/Alisa/DTI/WSK_allscans_analysis/registered_T2_to_ko51_normalize_smooth_5/';
typesToParse = {'FA', 'MD', 'T2'};
genotypesToDisplay = {'KO', 'WT', 'sham'};  % Out of {'KO', 'WT', 'sham'}
typesToDisplay = {'FA', 'MD', 'T2'};  % Out of {'FA', 'MD', 'T2'};

%% Setup result variables
% Each mouse is a line in listOfMice. This line contains one of three
% datatypes - T2, FA or MD. 
% Each of these datatypes is another structured array, with a single line
% per scan. Finally, these cells contain the mean and SEM values for that
% measurement. For example, to access mouse number 3's mean FA value in 
% scan 2: listOfMice(3).FA(2).mean
% To access all mice's FA values in scan 1: listOfMice(:).FA(1).mean
%% 
if exist('listOfMice')
    startingMice = length(listOfMice);
else
    startingMice = 1;
    listOfMice = struct('name', {}, 'summedVol', {}, 'manualMask', {}, ...
                        'lesionOnly', {}, 'croppedVol', {}, ...
                        'lesionMask', {});
    valueStruct = struct('mean', {}, 'sem', {});
    for type = typesToParse
        listOfMice(1).(type{1}) = valueStruct;
    end
end

%% Start going through the dirs
T2Scans = dir([workDir, '/swrT*_scan2_*T2.nii']);
numOfMice = size(T2Scans, 1);
assert(numOfMice == length(FirstSliceVector))

for mouseNumber = startingMice:numOfMice    
    % Get lesion parameters for that specific mouse
    curVol = load_untouch_nii([T2Scans(mouseNumber).folder, filesep, T2Scans(mouseNumber).name]);
    rotatedVol = rotateBrain(curVol.img);
    firstSlice = FirstSliceVector(mouseNumber);
    lastSlice = LastSliceVector(mouseNumber);
    
    if analyzeGeneralROI
        if mouseNumber == 1
            isSham = 1;
            manualMask = extractMaskFromVol(rotatedVol, firstSlice, lastSlice);
            listOfMice(mouseNumber) = extractLesionFromVol(rotatedVol, isSham, listOfMice(mouseNumber), manualMask);
        else
            % Find the mouse's name and group 
            listOfMice(mouseNumber) = extractLesionFromVol(rotatedVol, isSham, listOfMice(1), manualMask);
        end
        mouseName = strsplit(T2Scans(mouseNumber).name, '_');
        mouseName = mouseName{1}(4:end);
        listOfMice(mouseNumber).name = mouseName;
    else
        % Find the mouse's name and group 
        mouseName = strsplit(T2Scans(mouseNumber).name, '_');
        mouseName = mouseName{1}(4:end);
        listOfMice(mouseNumber).name = mouseName;
        isSham = contains(mouseName, 'sham');
        manualMask = extractMaskFromVol(rotatedVol, firstSlice, lastSlice);
        listOfMice(mouseNumber) = extractLesionFromVol(rotatedVol, isSham, listOfMice(mouseNumber), manualMask);
    end
    allMouseScans = groupMiceInFolder(workDir, mouseName);
    for type = typesToParse
       for scanNum = 1:size(allMouseScans.(type{1}), 1)
           fprintf('Calculating mean of scan number %d of mouse %s of type %s.\n', scanNum, mouseName, type{1});
           volOfMouse = load_untouch_nii([allMouseScans(1).(type{1})(scanNum).folder, filesep, allMouseScans(1).(type{1})(scanNum).name]);
           rotatedVol = rotateBrain(volOfMouse.img);
           listOfMice(mouseNumber).(type{1})(scanNum) = calculateMeanPixelValInVol(listOfMice(mouseNumber), rotatedVol);
       end
    end
end


%% Plotting

%% First we plot by the genotype
segregatedMice = extractRelevantMiceByGenotype(listOfMice, genotypesToDisplay);
idx = 1;
for genotype = genotypesToDisplay
    plotSegregatedMiceVector(segregatedMice{2, idx}, typesToDisplay, genotype{1});
    idx = idx + 1;
end

%% Plot by the scan type (FA, MD, T2)
% Plots the normalized data (normed by the first scan)
segregatedMiceByType = extractRelevantMiceByScan(typesToDisplay, genotypesToDisplay, ...
                                                 segregatedMice);
idx = 1;
for scanType = typesToDisplay
    plotScanTypeMiceVector(segregatedMiceByType, genotypesToDisplay, scanType{1});
    idx = idx + 1;
end
