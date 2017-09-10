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
    indexOfLastMouseOfGroup1 = floor(size(data, 1) / numberOfGroups);
    for curPlot = 1:indexOfLastMouseOfGroup1
        plot(xAxis, data(curPlot,:), ... 
        'c--', ...
        'LineWidth',1,...
        'Marker', 's',...
        'MarkerSize',5);
    
        plot(xAxis, data(curPlot + indexOfLastMouseOfGroup1, :), ...
        'r.-', ...
        'LineWidth',1,...
        'Marker', 's',...
        'MarkerSize',5);
    end

    % legend('WT_Avg', 'KO_Avg', 'Location', 'Best');
end