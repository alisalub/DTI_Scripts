function allMouseScans = groupMiceInFolder(workDir, mouseName)
% In the given directory, group all different types of scans of the same
% mouse into one struct array

allMouseScans = struct('T2', {}, 'FA', {}, 'MD', {});
allMouseScans(1).FA = dir([workDir, 's*', mouseName, '*FA.nii']);
allMouseScans(1).MD = dir([workDir, 's*', mouseName, '*native_MD.nii']);
allMouseScans(1).T2 = dir([workDir, 's*', mouseName, '*T2.nii']);

end