function plotSeparateMice(data, names, genotype, scanType, numOfScans)
    % Create one plot for all mice throughout all scans for each scan type
    % (MD, FA, T2)
    figure;
    hold on;
    title(['All ' genotype ' Mice']);
    xlabel('Scan Number');
    ylabel(scanType);
    x_ticks_labels = {'Scan 1', 'Scan 2', 'Scan 3', 'Scan 4', 'Scan 5', 'Scan 6', 'Scan 7'};
    xticks(1:numOfScans);
    xticklabels(x_ticks_labels(1:numOfScans));
    for mouseNum = 1:length(data)
        if isempty(data{mouseNum})
            continue
        end
        y = [data{mouseNum}.mean];
        y = y(1:numOfScans);
        errors = [data{mouseNum}.sem];
        errors = errors(1:numOfScans);
        errorbar(1:numOfScans, y, errors);        
    end

    legend(names);
end