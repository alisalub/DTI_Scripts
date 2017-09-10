function Batch_di10(T2path)

if isempty(T2path)
    relevantDir = uigetdir();
else
    relevantDir =T2path;
end

% find the T2.nii files in this directory
d1 = dir([relevantDir,'/H*T2*']); %FA img 
for i = 1:length(d1)
    di10(d1(i).name);
end

end