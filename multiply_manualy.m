filename1 = dir('*GS_resampled.nii');
filename2 = dir('*MD_C_native_T2.nii');
for ind=1:length(filename1)
    maskCorrection(filename1(ind).name,filename2(ind).name);
end

