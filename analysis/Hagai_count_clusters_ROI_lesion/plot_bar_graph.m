function plot_bar_graph(data, clusterNum, typeOfData, numOfGroups)
% data - Relevant parts of the cell array
% clusterNum
% typeOfData - FA or MD
% numOfGroups - amount of adjacent bars

    %change colors
    %remove scan 1
    %make sure the SEM is correct
    
    %% Choose colors for the bars
    all_colors = distinguishable_colors(40); 
    chosen_colors = all_colors([40, 6, 30], :);
    %[wt,ko,sham]
    
    % Plot bars
    numberOfScans = size(data, 2) - 1;
    labels = {'24h', 'week 1', 'week 2' ,'week 4'};
    data_t = data(1:2:(2 * numOfGroups - 1), :);  % to arrange as 'bar' requires
    errors = data(2:2:(2 * numOfGroups), 2:end);    
    
    %% Normalize data
    normFactor = data_t(:, 1);
    data_t = data_t(:, 2:end);
    normFactor = repmat(normFactor, 1, numberOfScans);
    data_normed = ((data_t ./ normFactor) - 1) * 100 ;  % disp percent of change
    errors_normed = ((errors ./ normFactor) * 100);
    
    errorbar_groups(data_normed, errors_normed, ...
                    'bar_names', labels, ...
                    'bar_colors', chosen_colors);  

    curTitle = sprintf('%s mean cluster %d', typeOfData, clusterNum);
    title(curTitle, 'Interpreter', 'none');
   
end