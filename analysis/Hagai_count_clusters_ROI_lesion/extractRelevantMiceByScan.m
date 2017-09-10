function returnedTable = extractRelevantMiceByScan(typesToDisplay, genotypesToDisplay, segregatedMice)
    % For each scan number (only up to 7 scans) find the values of each
    % type of scan per mouse, and add them to one struct of container.Map
    assert(sum(contains(typesToDisplay, {'FA', 'MD', 'T2'})) > 0); 

    MAX_NUM_OF_MICE = 7;
    returnedTable = struct();
    prelimValues = {[], [], []};
    for type = typesToDisplay
        returnedTable.(type{1}) = containers.Map(genotypesToDisplay, prelimValues);
    end
    % Column for every scan in data.FA('KO')
    
    genotype_idx = 1;
    for genotype = segregatedMice(1, :)
       allMice = segregatedMice{2, genotype_idx};
       for mouseNum = 1:size(allMice, 2)
           for type = typesToDisplay
               try
                   oneMouseAllScans = [allMice(mouseNum).(type{1}).mean];
                   missingZeros = MAX_NUM_OF_MICE - size(oneMouseAllScans, 2);
                   oneMouseAllScans = padarray(oneMouseAllScans, [0, missingZeros], 'post');
               catch
                   continue
               end
               returnedTable.(type{1})(genotype{1}) = [returnedTable.(type{1})(genotype{1}); oneMouseAllScans];
           end
       end
       genotype_idx = genotype_idx + 1;
    end
    
end