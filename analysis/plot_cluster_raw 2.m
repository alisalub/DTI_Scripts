function plot_cluster_raw(data, clusterNum, typeOfData, numberOfGroups)
% data - Relevant parts of the cell array
% clusterNum
% typeOfData - FA or MD
% numberOfGroups - Number of groups to divide the data into

    %% Define figure properties
    figure(clusterNum);
    curTitle = sprintf('%s average per mouse across scans of cluster %d', typeOfData, clusterNum);
    title(curTitle, 'Interpreter', 'none');
    hold on
    
    %% Create plots for each group in current cluster
    
    numberOfScans = size(data, 2);
    xAxis = 1:numberOfScans;
    lastIndexOfMouseInGroup = floor(size(data, 1) / numberOfGroups);
    colors = ['r.-', 'c--', 'k:'];
    for mouseGroup = 0:numberOfGroups - 1
        for curPlot = 1:lastIndexOfMouseInGroup
            normFactor = data(curPlot + mouseGroup, 1);
            normFactor = repmat(normFactor, 1, numberOfScans);
            plot(xAxis, data(curPlot + mouseGroup, :)./normFactor, ... 
            colors(mouseGroup + 1), ...
            'LineWidth',1,...
            'Marker', 's',...
            'MarkerSize',5);
        end
    end

    legend('WT_Avg', 'KO_Avg', 'SH_Avg', 'Location', 'Best');
end