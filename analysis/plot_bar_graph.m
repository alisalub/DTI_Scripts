function plot_bar_graph(data, clusterNum, typeOfData, numOfGroups)
% data - Relevant parts of the cell array
% clusterNum
% typeOfData - FA or MD
% numOfGroups - amount of adjacent bars

    figure(clusterNum);
    curTitle = sprintf('%s mean cluster %d', typeOfData, clusterNum);
    title(curTitle, 'Interpreter', 'none');
    hold on
   
    %change colors
    %remove scan 1
    %make sure the SEM is correct
    
    % Plot bars
    numberOfScans = size(data, 2);
    labels = {'Scan 1', 'Scan 2', 'Scan 3', 'Scan 4' ,'Scan 5'};
    data_t = data(1:2:(2 * numOfGroups - 1), :);  % to arrange as 'bar' requires
    errors = data(2:2:(2 * numOfGroups), :);
    
    % Normalize data
    normFactor = data_t(:, 1);
    normFactor = repmat(normFactor, 1, numberOfScans);
    data_normed = ((data_t ./ normFactor) - 1) * 100 ;  % disp percent of change
    errors_normed = ((errors ./ normFactor) * 100);
    
    [xticks, b, err] = errorbar_groups(data_normed, errors_normed, 'bar_names', labels);
%     b(1).FaceColor = 'b';
%     b(2).FaceColor = 'r';
%     b(3).FaceColor = 'y';    
    
end