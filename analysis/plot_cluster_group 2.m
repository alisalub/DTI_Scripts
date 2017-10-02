function plot_cluster_group(data, clusterNum, typeOfData, numberOfPlots)
% data - Relevant parts of the cell array
% clusterNum
% typeOfData - FA or MD
% numberOfPlots - Number of plots in a single figure

    %% Define figure properties
    figure(clusterNum);
    curTitle = sprintf('%s mean cluster %d', typeOfData, clusterNum);
    title(curTitle, 'Interpreter', 'none');
    hold on
    
    %% Create plots for each group in current cluster
    
    numberOfScans = size(data, 2);
    
    for curPlot = 1:2:(2 * numberOfPlots - 1)  % Might change for a given data structure
        normFactor = data(curPlot, 1);
        normFactor = repmat(normFactor, 1, numberOfScans);
        errorbar(1:numberOfScans, data(curPlot,:)./normFactor, data(curPlot + 1, :)./normFactor, ... 
        '-',...
        'LineWidth', 9, ...
        'Marker', 's', ...
        'MarkerSize', 6)
    end

    %legend('WT_Avg', 'KO_Avg', 'SH_Avg', 'Location', 'Best'); % for 3
    %genotypes
    legend('WT_Avg', 'KO_Avg', 'Location', 'Best'); % for two genotypes

end