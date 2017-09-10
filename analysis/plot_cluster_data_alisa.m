%% Load all .mat files containing data
close all;

load('meanValuesRegionFA1.mat');
load('meanValuesRegionMD1.mat');
% load('meanValuesRegionFA1_cortex.mat');
% load('meanValuesRegionMD1_Cortex.mat');

sizeOfFA1 = size(meanValuesRegionFA,3);
sizeOfMD1 = size(meanValuesRegionMD,3);

cellArrayOfOutliersFA = cell(sizeOfFA1, 1);
cellArrayOfOutliersMD = cell(sizeOfMD1, 1);

%% Decide on threshold % that the code marks and saves in its variables
percentThreshold = 15;

%% Start with FA data
for curClustNum = 2:(sizeOfFA1+1)
    %% Load a cluster
    curClust = cell2mat(meanValuesRegionFA(2:end,2:end,curClustNum - 1));
    
    %% Define figure properties
    Fig = figure(curClustNum);
    set(Fig,'color','w');
    curTitle = sprintf('FA mean value across scans of cluster %d', curClust(1,1));
    title(curTitle);
    hold on
    
    %% Create plots for each mouse in current cluster
    for mouseNum = 1:5
        errorbar(1:6,curClust(mouseNum,2:7),curClust(mouseNum,14:19), '--',...
        'LineWidth',3,...
        'Marker', 's',...
        'MarkerSize',4)
    end
    %%
    m2str = sprintf('M2: %4.2f%% total change', curClust(1, 13));
    m3str = sprintf('M3: %4.2f%% total change', curClust(2, 13));
    m4str = sprintf('M4: %4.2f%% total change', curClust(3, 13));
    m5str = sprintf('M5: %4.2f%% total change', curClust(4, 13));
    m6str = sprintf('M6: %4.2f%% total change', curClust(5, 13));
    avgstr = sprintf('Mean trace');
    
    %% Add averaged trace between scans
    avg_plot = mean(curClust(:,2:7));
    std_plot = std(curClust(:,2:7));
    
    errorbar(1:6, avg_plot, std_plot, 'k-', 'LineWidth', 4, 'Marker', 's', 'MarkerSize', 5);
    %% 
    legend({m2str, m3str, m4str, m5str, m6str, avgstr}, 'Location', 'Best','FontSize',20);
    set(gca, 'fontsize', 20);
    %% Check for mice with a high percentage of change 
    overThreshold = curClust(:, 8:12); % A matrix that only contains the percentage of change for each mouse
    overThreshold(find(abs(overThreshold < percentThreshold))) = 0;
    [mouseIndex, whichScans, outlierValue] = find(overThreshold);
    
    outlierMatrixFA = sparse(mouseIndex, whichScans, outlierValue);
    cellArrayOfOutliersFA{curClustNum - 1, 1} = outlierMatrixFA;
    
end

%% Moving on to MD data
for curClustNum = 2:(sizeOfMD1+1)
    %% Load a cluster
    curClust = cell2mat(meanValuesRegionMD(2:end,2:end,curClustNum - 1));
    
    %% Define figure properties
    Fig2 = figure(sizeOfFA1 + curClustNum);
    set(Fig2,'color','w');
    curTitle = sprintf('MD mean value across scans of cluster %d', curClust(1,1));
    title(curTitle);
    hold on
    
    %% Create plots for each mouse in current cluster
    for mouseNum = 1:5
        errorbar(1:6,curClust(mouseNum,2:7),curClust(mouseNum,14:19), '--',...
        'LineWidth',3,...
        'Marker', 's',...
        'MarkerSize',4)
    end
    %%
    m2str = sprintf('M2: %4.2f%% total change', curClust(1, 13));
    m3str = sprintf('M3: %4.2f%% total change', curClust(2, 13));
    m4str = sprintf('M4: %4.2f%% total change', curClust(3, 13));
    m5str = sprintf('M5: %4.2f%% total change', curClust(4, 13));
    m6str = sprintf('M6: %4.2f%% total change', curClust(5, 13));
    avgstr = sprintf('Mean trace');
    
    %% Add averaged trace between scans
    avg_plot = mean(curClust(:,2:7));
    std_plot = std(curClust(:,2:7));
    
    errorbar(1:6, avg_plot, std_plot, 'k-', 'LineWidth', 4, 'Marker', 's', 'MarkerSize', 5);
    %%
    legend({m2str, m3str, m4str, m5str, m6str, avgstr}, 'Location', 'Best','FontSize',20);
    set(gca, 'fontsize', 20);
    %% Check for mice with a high percentage of change 
    overThreshold = curClust(:, 8:12); % A matrix that only contains the percentage of change for each mouse
    overThreshold(find(abs(overThreshold < percentThreshold))) = 0;
    [mouseIndex, whichScans, outlierValue] = find(overThreshold);
   
    outlierMatrixMD = sparse(mouseIndex, whichScans, outlierValue);
    cellArrayOfOutliersMD{curClustNum - 1, 1} = outlierMatrixMD;
end

