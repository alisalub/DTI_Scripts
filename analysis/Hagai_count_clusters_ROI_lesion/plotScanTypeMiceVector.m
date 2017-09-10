function plotScanTypeMiceVector(segMice, genotypesToDisplay, scanType)
% Plot the normalized data by scan type

    % Figure set ups
    numOfScans = 5;
    figure;
    xlabel('Scan Number');
    ylabel(['Normalized ' scanType]);
    colors = {'r', 'b', 'k'};
    hold all;
    genotype_idx = 1;
    for genotype = genotypesToDisplay
        data = segMice.(scanType)(genotype{1});
        if ~isempty(data)
            % Normalize current data by the first scan
            firstScanData = data(:, 1);
            firstScanData = repmat(firstScanData, 1, size(data, 2));
            dataNormed = data ./ firstScanData;
            % Caclulate mean on the normed data and plot
            meanData = mean(dataNormed(:, 1:numOfScans), 1);
            semData = std(dataNormed(:, 1:numOfScans), 1) ./ size(dataNormed, 1);
            errorbar(meanData, semData, colors{genotype_idx}, ...
                'LineWidth',4,...
                'MarkerSize',7,...
               'DisplayName', [genotype{1}, '_mean']);
            xdata = repmat(1:numOfScans, size(dataNormed, 1), 1);
            plot(xdata, dataNormed(:, 1:numOfScans), [colors{genotype_idx} 'o'], 'Marker', 'd', ...
                'DisplayName', [genotype{1}, '_raw']);
        end
        genotype_idx = genotype_idx + 1;
    end
    
    title(scanType);
    xticks(1:numOfScans);
    x_ticks_labels = {'Scan 1', 'Scan 2', 'Scan 3', 'Scan 4', 'Scan 5', 'Scan 6', 'Scan 7'};
    xticklabels(x_ticks_labels(1:numOfScans));
    
    legend('-DynamicLegend')
end