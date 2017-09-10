function Batch_pi10(T2path)

if isempty(T2path)
    relevantDir = uigetdir();
else
    relevantDir =T2path;
end

% find the T2.nii files in this directory
d1 = dir([relevantDir,'/*mean_DWIs.nii']); %DWI img 
for i = 1:length(d1)
    pi10(d1(i).name);
end

end