function plotScanTypeMiceVector(segMice, genotypesToDisplay, scanType)
% Plots an error bar with the scatter plot of every scan type for each
% mouse

    %% Generate color scheme
    all_colors = distinguishable_colors(40); 
    chosen_colors = all_colors([6, 40, 30], :);
    
    %%
    numOfScans = 5;
    figure;
    xlabel('Scan Number');
    ylabel(scanType);
    hold all;
    genotype_idx = 1;
    for genotype = genotypesToDisplay
        data = segMice.(scanType)(genotype{1});
        if ~isempty(data)
            meanData = mean(data(:, 1:numOfScans), 1);
            semData = std(data(:, 1:numOfScans), 1) ./ size(data, 1);
            errorbar(meanData, semData, ...
                     'DisplayName', [genotype{1}, '_mean'], ...
                     'Color', chosen_colors(genotype_idx, :), ...
                     'LineWidth', 6);
            xdata = repmat(1:numOfScans, size(data, 1), 1);
            plot(xdata, data(:, 1:numOfScans), 'o', ...
                 'Marker', 'd', ...
                 'DisplayName', [genotype{1}, '_raw'], ...
                 'Color', chosen_colors(genotype_idx, :));
        end
        genotype_idx = genotype_idx + 1;
    end
    
    title(scanType);
    xticks(1:numOfScans);
    x_ticks_labels = {'Scan 1', 'Scan 2', 'Scan 3', 'Scan 4', 'Scan 5', 'Scan 6', 'Scan 7'};
    xticklabels(x_ticks_labels(1:numOfScans));
    
    legend('-DynamicLegend')
end