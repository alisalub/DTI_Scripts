function plotSegregatedMiceVector(segMice, scanTypesToDisplay, genotype)
    numOfScans = 5;
    for scanType = scanTypesToDisplay
        if ~isempty(segMice)
            plotSeparateMice({segMice.(scanType{1})}, {segMice.name}, ...
                             genotype, scanType{1}, numOfScans);         

        end
    end

end