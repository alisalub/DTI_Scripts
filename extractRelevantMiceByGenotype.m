function returnedTable = extractRelevantMiceByGenotype(listOfMice, genotype)
    
    assert(sum(contains(genotype, {'KO', 'sham', 'WT'})) > 0);

    returnedTable = cell(2, size(genotype, 2));
    returnedTable(1, :) = genotype;
    idx = 1;

    miceNames = {listOfMice(:).name};
    for type = genotype
        typeVec = repmat(type, [length(miceNames), 1]);
        relevantCells = logical(cell2mat(strfind(miceNames, type{1})));
        returnedTable{2, idx} = listOfMice(relevantCells);
        idx = idx + 1;
    end

end