function manualMask = extractMaskFromVol(niiVol, first_slice, last_slice)
% Using ROIPOLY extract a slice from a brain volume
    Temp_img=mat2gray(niiVol);
    manualMask = false(size(Temp_img)); 

    for z=first_slice:last_slice
        current_slice = Temp_img(:,:,z);
        if any(current_slice(:)<1 & current_slice(:)>0 )
            figure(1);
            set(gcf, 'Position', [200 200 1200 1200]);
            manualMask(:,:,z) = roipoly(current_slice);
            
        end   
    end
end