function plotSegregatedMiceVector(segMice, scanTypesToDisplay, genotype)
    numOfScans = 5;
    for scanType = scanTypesToDisplay
        if ~isempty(segMice)
            er = plotSeparateMice({segMice.(scanType{1})}, {segMice.name}, ...
                             genotype, scanType{1}, numOfScans);         
            addMeanLine(er, {segMice.(scanType{1})}, numOfScans);
        end
    end

end