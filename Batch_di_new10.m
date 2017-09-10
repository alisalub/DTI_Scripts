function Batch_di_new10(T2path)

if isempty(T2path)
    relevantDir = uigetdir();
else
    relevantDir =T2path;
end

% find the DWI.nii files in this directory
d1 = dir([relevantDir,'/swrT*.nii']); %FA img 
for i = 1:length(d1)
    di_new10(d1(i).name);
end

end

