function curMouse = extractLesionFromVol(niiVol, isSham, curMouse, ManualMask)
% On a volume defined by ManualMask
% compute the mean FA values inside the volume. 

    CroppedVolume = ManualMask .* niiVol;

    if isSham
        LesionBinaryMask = logical(CroppedVolume > 0);
        LesionOnly = LesionBinaryMask .* niiVol;
    else
        BrightestLesionVoxel =  max(CroppedVolume(:));
        HalfMedianGrayVoxel = 0.5 .* median(CroppedVolume(CroppedVolume>100)); % Excluding pitch black voxels from this metric.
        if(HalfMedianGrayVoxel > BrightestLesionVoxel)
            disp('Gray background brighter than lesion!')
        end
        %     GlobalThreshold = DarkestGrayVoxel + (1-1/exp(1)) * (BrightestLesionVoxel-DarkestGrayVoxel);
        GlobalThreshold = HalfMedianGrayVoxel + 0.5 * (BrightestLesionVoxel-HalfMedianGrayVoxel);

        LesionBinaryMask = logical(CroppedVolume > GlobalThreshold);

        LesionOnly = LesionBinaryMask .* niiVol; % for verification purposes only.
    end
                      
    curMouse(1).summedVol = sum(LesionBinaryMask(:));
    curMouse(1).manualMask = ManualMask;
    curMouse(1).lesionOnly = LesionOnly;
    curMouse(1).croppedVol = CroppedVolume;
    curMouse(1).lesionMask = LesionBinaryMask;    
end