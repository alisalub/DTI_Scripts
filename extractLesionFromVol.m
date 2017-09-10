function curMouse = extractLesionFromVol(niiVol, first_slice, last_slice, isSham, curMouse)
% Displays a brain scan for truncation with ROIPOLY. On that volume the
% function computes the mean FA values inside the volume. 

    Temp_img=mat2gray(niiVol);
    ManualMask = false(size(Temp_img)); 

    for z=first_slice:last_slice
        current_slice = Temp_img(:,:,z);
        if any(current_slice(:)<1 & current_slice(:)>0 )
            figure(1);
            set(gcf, 'Position', [200 200 1200 1200]);
            ManualMask(:,:,z) = roipoly(current_slice);
            
        end   
    end
 
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