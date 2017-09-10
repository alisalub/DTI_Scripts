function loadDataAndPlot(fileName, dataStructure)
    % Name of .mat file to load and plot
%example: loadDataAndPlot('Interact_ResCell_MD.mat', 'mean')
%         loadDataAndPlot('Whithin_meanValuesFA_subj.mat', 'raw')  
    %% Load all .mat files containing data
    close all;

    dataToPlot = load(fileName);
    fieldname = fieldnames(dataToPlot);
    fieldname = fieldname{1};

    firstRow = 2;
    firstCol = 3;

    data = dataToPlot(1,1).(fieldname);
    numOfClusters = size(data, 3);
    
    switch dataStructure
        case 'raw'
            for curClust = 1:numOfClusters
                curData = cell2mat(data(firstRow:end, firstCol:end, curClust));
                plot_cluster_raw(curData, curClust, fileName, 2)
            end
            
        case 'mean'
            for curClust = 1:numOfClusters
                curData = cell2mat(data(firstRow:end, firstCol:end, curClust));
                plot_cluster_group(curData, curClust, fileName, 2)
            end
    end

end

