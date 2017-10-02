function loadDataAndPlot(fileName, dataStructure, shamFilename)
    % Name of .mat file to load and plot
%example: loadDataAndPlot('Interact_ResCell_MD.mat', 'mean')
%         loadDataAndPlot('Within_meanValuesFA_subj.mat', 'raw')  
% loadDataAndPlot('Interact_ResCell_MD.mat', 'single') 
    %% Load all .mat files containing data
   % close all;

    dataToPlot = load(fileName);
    fieldname = fieldnames(dataToPlot);
    fieldname = fieldname{1};

    firstRow = 2;
    firstCol = 3;

    data = dataToPlot(1,1).(fieldname);
    numOfClusters = size(data, 3);
    numOfGroups = 2;  % WT and KO. To make it 3 specify a filename with the data from the sham mice
    
    if nargin == 3
       typesToParse = {'FA', 'MD', 'T2'};
       for type = typesToParse
          res = strfind(fileName, type{1});
          if res
              break
          end
       end
       data = concatNewShamData(data, shamFilename, type{1}, dataStructure); 
       numOfGroups = 3;
       
    end
    switch dataStructure
        case 'raw' %show each mouse as a separate plot
            for curClust = 1:numOfClusters
                curData = cell2mat(data(firstRow:end, firstCol:end, curClust));
                plot_cluster_raw(curData, curClust, fileName, 1) %change num of groups
                set(gca,'FontSize',15);
                %save each plot as a separate file 
      %             temp=['fig_' ,num2str(curClust),'_',fileName,'.png']; 
       %         saveas(gca,temp);
            end
            
        case 'mean'
            for curClust = 1:numOfClusters
                curData = cell2mat(data(firstRow:end, firstCol:end, curClust));
                plot_cluster_group(curData, curClust, fileName, numOfGroups) % 2 if there are only 2 groups, 3 if there are 3
                set(gca,'FontSize',15, 'LineWidth', 6);

                 %save each plot as a separate file 
               % temp=['fig_' ,num2str(curClust),'_',fileName,'.png']; 
               % saveas(gca,temp);

            end
            
        case 'single' %mean for one group, insert the ResCellof a chosen group
            for curClust = 1:numOfClusters
                curData = cell2mat(data(firstRow:end, firstCol:end, curClust));
                plot_cluster_group(curData, curClust, fileName, 1)
                set(gca,'FontSize',15);

                %save each plot as a separate file 
                  temp=['fig_' ,num2str(curClust),'_',fileName,'.png']; 
                  saveas(gca,temp);
            end
            
        case 'bar'
            for curClust = 1:numOfClusters
                curData = cell2mat(data(firstRow:end, firstCol:end, curClust));
                plot_bar_graph(curData, curClust, fileName, numOfGroups);
                set(gca,'FontSize',15);
                temp=['fig_' ,num2str(curClust),'_',fileName,'.png']; 
                saveas(gca,temp);
            end
    end

end


