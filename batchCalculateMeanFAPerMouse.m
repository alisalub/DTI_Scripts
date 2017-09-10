% For each mouse, use ROIPOLY to define the lesion area in a specific
% mouse. Then calculate the mean FA values in that area and plot them

%% Parameters
FirstSliceVector = [66 61 56 59 56 62 57 67 61 57 59 62 57 60 62 61 60 60 60 60 60 60 60 60];
LastSliceVector = [67 67 63 68 65 69 73 76 76 75 70 70 69 67 68 69 61 61 61 61 61 61 61 61];
workDir = '/Volumes/SAMSUNG/MSc_PhD/DTI_Analysis/WSK_allscans_analysis/WSK_Native_FA_MD_T2_not_pi10/smoothed_with_06/';
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
T2Scans = dir([workDir, 'swr*_scan2_*T2.nii']);
numberOfMice = size(T2Scans, 1);
assert(numberOfMice == length(FirstSliceVector))

for mouseNumber = startingMice:numberOfMice
    % Find the mouse's name and group 
    mouseName = strsplit(T2Scans(mouseNumber).name, '_');
    mouseName = mouseName{1}(4:end);
    listOfMice(mouseNumber).name = mouseName;
    isSham = contains(mouseName, 'sham');
    
    % Get lesion parameters for that specific mouse
    curVol = load_untouch_nii([T2Scans(mouseNumber).folder, filesep, T2Scans(mouseNumber).name]);
    rotatedVol = rotateBrain(curVol.img);
    firstSlice = FirstSliceVector(mouseNumber);
    lastSlice = LastSliceVector(mouseNumber);
    listOfMice(mouseNumber) = extractLesionFromVol(rotatedVol, firstSlice, ...
                                                   lastSlice, isSham, listOfMice(mouseNumber));

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
segregatedMiceByType = extractRelevantMiceByScan(listOfMice, typesToDisplay, genotypesToDisplay);
idx = 1;
for scanType = typesToDisplay
    plotScanTypeMiceVector(segregatedMiceByType, genotypesToDisplay);
    idx = idx + 1;
end
