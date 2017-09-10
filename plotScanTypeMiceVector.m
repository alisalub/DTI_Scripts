function plotScanTypeMiceVector(segMice, genotypesToDisplay)
    numOfScans = 5;
    typeIdx = 1;
    for scanType = segMice(1, :)
        if ~isempty(segMice{2, typeIdx})
            plotMeanMice(scanType{1}, segMice{2, typeIdx}, genotypesToDisplay, ...
                         numOfScans); 
        end
        typeIdx = typeIdx + 1;
    end

end