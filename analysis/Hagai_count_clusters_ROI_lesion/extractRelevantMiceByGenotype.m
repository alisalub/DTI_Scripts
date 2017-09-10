function returnedTable = extractRelevantMiceByGenotype(listOfMice, genotype)
    
    assert(sum(contains(genotype, {'KO', 'sham', 'WT'})) > 0);

    returnedTable = cell(2, size(genotype, 2));
    returnedTable(1, :) = genotype;
    idx = 1;

    miceNames = {listOfMice(:).name};
    for type = genotype
        relevantCells = cellfun(@mean, strfind(miceNames, type{1}));
        relevantCells(isnan(relevantCells)) = 0;
        returnedTable{2, idx} = listOfMice(logical(relevantCells));
        idx = idx + 1;
    end

end