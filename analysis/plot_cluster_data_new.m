%% Load all .mat files containing data
close all;

load('Inter_ResCell_FA.mat');
load('Inter_ResCell_MD.mat');


cellArrayOfOutliersFA = cell(48, 1);
cellArrayOfOutliersMD = cell(29, 1);

%% Decide on threshold % that the code marks and saves in its variables
%percentThreshold = 15;

%% Start with FA data
for ClusterNum = 1:16
    %% Load a cluster
    curClust = cell2mat(meanValuesRegionFA(2:end,2:end,ClusterNum - 1));
    
    %% Define figure properties
    figure(ClusterNum);
    curTitle = sprintf('FA mean value across scans of cluster %d', ClusterNum);
    title(curTitle);
    hold on
    
    %% Create plots for each mouse in current cluster
    for mouseNum = 1:5
        plot(1:6,curClust(mouseNum,2:7), '--',...
        'LineWidth',1,...
        'Marker', 's',...
        'MarkerSize',5)
    end
    %%
    legend('Mouse 2', 'Mouse 3', 'Mouse 4', 'Mouse 5', 'Mouse 6', 'Location', 'Best');

    %% Check for mice with a high percentage of change 
    overThreshold = curClust(:, 8:12); % A matrix that only contains the percentage of change for each mouse
    overThreshold(find(abs(overThreshold < percentThreshold))) = 0;
    [mouseIndex, whichScans, outlierValue] = find(overThreshold);
    
    outlierMatrixFA = sparse(mouseIndex, whichScans, outlierValue);
    cellArrayOfOutliersFA{ClusterNum - 1, 1} = outlierMatrixFA;
    
end

%% Moving on to MD data
for ClusterNum = 2:12
    %% Load a cluster
    curClust = cell2mat(meanValuesRegionMD(2:end,2:end,ClusterNum - 1));
    
    %% Define figure properties
    figure(27 + ClusterNum);
    curTitle = sprintf('MD mean value across scans of cluster %d', ClusterNum);
    title(curTitle);
    hold on
    
    %% Create plots for each mouse in current cluster
    for mouseNum = 1:5
        plot(1:6,curClust(mouseNum,2:7), '--',...
        'LineWidth',1,...
        'Marker', 's',...
        'MarkerSize',5)
    end
    %%
    legend('Mouse 2', 'Mouse 3', 'Mouse 4', 'Mouse 5', 'Mouse 6', 'Location', 'Best');
   
    %% Check for mice with a high percentage of change 
    overThreshold = curClust(:, 8:12); % A matrix that only contains the percentage of change for each mouse
    overThreshold(find(abs(overThreshold < percentThreshold))) = 0;
    [mouseIndex, whichScans, outlierValue] = find(overThreshold);
   
    outlierMatrixMD = sparse(mouseIndex, whichScans, outlierValue);
    cellArrayOfOutliersMD{ClusterNum - 1, 1} = outlierMatrixMD;
end

