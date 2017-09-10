function returnedTable = extractRelevantMiceByScan(listOfMice, scanType, genotypesToDisplay)
    
    assert(sum(contains(scanType, {'FA', 'MD', 'T2'})) > 0);

    returnedTable = cell(2, size(scanType, 2));
    returnedTable(1, :) = scanType;
    segregatedMice = extractRelevantMiceByGenotype(listOfMice, genotypesToDisplay);
    scanTypeIdx = 1;
    for type = scanType
        genotype_idx = 1;
        dataPerGenotype = cell(2, length(genotypesToDisplay));
        for genotype = genotypesToDisplay
            curData = {segregatedMice{2, genotype_idx}.(type{1})};
            if ~isempty(curData)
                dataPerGenotype{1, genotype_idx} = genotype{1};
                dataPerGenotype{2, genotype_idx} = [[curData.mean]', [curData.sem]'];
                genotype_idx = genotype_idx + 1;
            end
        end
        returnedTable{2, scanTypeIdx} = dataPerGenotype;
    end
    

end