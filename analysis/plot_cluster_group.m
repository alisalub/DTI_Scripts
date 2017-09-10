function plot_cluster_group(data, clusterNum, typeOfData, numberOfPlots)
% data - Relevant parts of the cell array
% clusterNum
% typeOfData - FA or MD
% numberOfPlots - Number of plots in a single figure

    %% Define figure properties
    figure(clusterNum);
    curTitle = sprintf('%s mean value across scans of cluster %d', typeOfData, clusterNum);
    title(curTitle);
    hold on
    
    %% Create plots for each group in current cluster
    
    numberOfScans = size(data, 2);
    
    for curPlot = 1:2:numberOfPlots + 1  % Might change for a given data structure
        errorbar(1:numberOfScans, data(curPlot,:), data(curPlot + 1, :), ... 
        '--',...
        'LineWidth',1,...
        'Marker', 's',...
        'MarkerSize',5)
    end

    legend('WT_Avg', 'KO_Avg', 'Location', 'Best');
end