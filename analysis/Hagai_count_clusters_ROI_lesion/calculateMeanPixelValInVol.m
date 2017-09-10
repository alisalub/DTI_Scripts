function result = calculateMeanPixelValInVol(lesionStruct, vol)
% Calculate the mean pixel values for a given brain volume, in a specific
% area defined by the lesionStruct.
    
    lesionedArea  = lesionStruct.lesionMask .* vol;
    croppedVol = vol(lesionedArea > 0);
    
    result = struct('mean', {}, 'sem', {});
    result(1).mean = mean(croppedVol(:));
    result(1).sem = std(croppedVol(:)) ./ numel(croppedVol);
    
end