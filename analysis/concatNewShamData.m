function finalData = concatNewShamData(data, shamFilename, scanType, dataStructure)
% Concatenate the new data from the sham mice to the old data that includes
% only the WT and KO mice.
% Params:
% data - old data to concatenate to
% shamFilename - file containing new data
% scanType - 'MD', 'FA' or 'T2'
% dataStructure - whether we're after the 'mean' or 'raw' data.

finalData = data;
newData = load(shamFilename);
fieldname = fieldnames(newData);
fieldname = fieldname{1};
newData = newData.(fieldname)(scanType);
if strcmp(dataStructure, 'mean') || strcmp(dataStructure, 'bar')
    newData = newData{1, 2};
elseif strcmp(dataStructure, 'raw')
    newData = newData{1, 1};
end

finalData = cat(1, finalData, newData(2:end, 1:size(finalData, 2), :));

end