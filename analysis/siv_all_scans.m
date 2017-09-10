%% Instatiate output parameters
dirToCheck = uigetdir('/Volumes/SAMSUNG/MSc_PhD/DTI_Analysis/Fiber_Tracts');
listOfAllFiles = dir([dirToCheck filesep 'K*CC.mat']);
listOfAllFiles = [listOfAllFiles; dir([dirToCheck filesep 'W*CC.mat'])];
meanSiv = cell(length(listOfAllFiles), 2);
stdSiv = cell(length(listOfAllFiles), 2);
tSiv = cell(length(listOfAllFiles), 2);

%% Go through all files in the folder and check if they're valid for the analysis
for idx = 1:length(listOfAllFiles)
    fprintf('Current file number: %d\n', idx);
    curName = listOfAllFiles(idx).name;
    load(curName);
    meanSiv{idx, 1} = curName;
    stdSiv{idx, 1} = curName;
    tSiv{idx, 1} = curName;
    [meanSiv{idx, 2}, stdSiv{idx, 2}, tSiv{idx, 2}] = avsiv(TractFA, Tracts);
    close;
end

%% Save variables after thresholding
save([dirToCheck filesep 'results_of_thresholding.mat'], 'meanSiv', 'stdSiv', 'tSiv');

%% Plot graph for each group of animals
close all;
numOfDiffScans = 7;
sizeOfAverages = 100;  % Based on Yaniv's avsiv function
vecOfPossibleNames = string({'scan1', 'scan2', 'scan3', 'scan4', 'scan5', ...
                             'scan6', 'scan7'});
allWTMean = zeros(sizeOfAverages, numOfDiffScans);
allWTStd = zeros(sizeOfAverages, numOfDiffScans);
allKOMean = zeros(sizeOfAverages, numOfDiffScans);
allKOStd = zeros(sizeOfAverages, numOfDiffScans);
idx = 1;

for name = vecOfPossibleNames
    % Find the two separate groups of indices - WT and KO
    relevantIndicesWT = contains(meanSiv(:, 1), name, 'IgnoreCase', true) ...
                      & contains(meanSiv(:, 1), 'WT', 'IgnoreCase', true);
               
    relevantIndicesKO = contains(meanSiv(:, 1), name, 'IgnoreCase', true) ...
                      & contains(meanSiv(:, 1), 'KO', 'IgnoreCase', true);
                             
    % Calculate mean and STD for each group
    % WT
    relevantMeansWT = cell2mat(meanSiv(relevantIndicesWT, 2));
    curMeanWT = mean(reshape(relevantMeansWT, sizeOfAverages, size(relevantMeansWT, 1)/sizeOfAverages), 2);
    relevantStdsWT = cell2mat(stdSiv(relevantIndicesWT, 2));
    curStdWT = std(reshape(relevantMeansWT, sizeOfAverages, size(relevantMeansWT, 1)/sizeOfAverages), 0, 2) ...
               ./ sqrt(size(relevantMeansWT, 1)/sizeOfAverages);  % To obtain SEM
    % KO
    relevantMeansKO = cell2mat(meanSiv(relevantIndicesKO, 2));
    curMeanKO = mean(reshape(relevantMeansKO, sizeOfAverages, size(relevantMeansKO, 1)/sizeOfAverages), 2);
    relevantStdsKO = cell2mat(stdSiv(relevantIndicesKO, 2));
    curStdKO = std(reshape(relevantMeansKO, sizeOfAverages, size(relevantMeansKO, 1)/sizeOfAverages), 0, 2) ...
               ./ sqrt(size(relevantMeansKO, 1)/sizeOfAverages);  % To obtain SEM
    
    % Plot KO and WT of the same scan
    figure;
    errorbar(1:sizeOfAverages, curMeanWT, curStdWT);
    hold on;
    errorbar(1:sizeOfAverages, curMeanKO, curStdKO);
    legend('WT', 'KO');
    title(name)
    
    % Plot all KOs and WTs in a single plot
    allWTMean(:, idx) = curMeanWT;
    allWTStd(:, idx) = curStdWT;
    allKOMean(:, idx) = curMeanKO;
    allKOStd(:, idx) = curStdKO;    
    idx = idx + 1;
end

% Plot all KOs and WTs in a single plot
figure;
hold on;
errorbar(repmat([1:sizeOfAverages]', 1, numOfDiffScans), allWTMean, allWTStd);
title('WT across scans');
legend(vecOfPossibleNames);

figure;
hold on;
errorbar(repmat([1:sizeOfAverages]', 1, numOfDiffScans), allKOMean, allKOStd);
title('KO across scans');
legend(vecOfPossibleNames);

% Plot only scans x and y
x = 1;
y = 5;

figure;
hold on;
errorbar(repmat([1:sizeOfAverages]', 1, 2), ... 
         [allWTMean(:, x), allWTMean(:, y)], ...
         [allWTStd(:, x), allWTStd(:, y)]);
titleWT = sprintf('WT scans %d and %d', x, y);
title(titleWT);
legend(vecOfPossibleNames(x), vecOfPossibleNames(y));

figure;
hold on;
errorbar(repmat([1:sizeOfAverages]', 1, 2), ... 
         [allKOMean(:, x), allKOMean(:, y)], ...
         [allKOStd(:, x), allKOStd(:, y)]);
titleKO = sprintf('KO scans %d and %d', x, y);
title(titleKO);
legend(vecOfPossibleNames(x), vecOfPossibleNames(y));

