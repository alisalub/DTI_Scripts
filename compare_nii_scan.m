function compare_nii_scan
scans={     'scan1',...
            'scan2',...
            'scan3',...
            'scan4',...
            'scan5',...
            'scan6',...
            'scan7',...
 };
for subj=1:numel(scans)
    
directory='/Volumes/SAMSUNG 1/MSc_PhD/DTI_Analysis/smoothed_allscans';
files=fuf([directory '/swr*' scans{subj} '*_FA.nii'],'detail');
fig=figure;
slice4examination=25;
for i=1:numel(files)
    tmp=load_nii(files{i});
    data(:,:,:,i)=tmp.img;
    imagesc(data(:,:,slice4examination,i));
  %  saveas(fig,[scans{subj} '_' int2str(i) '.jpeg']);
end
data1=squeeze(data(:,:,slice4examination,:));
a1=make_nii(data1,[0.16 0.16 0.16],[0;0;0],16);
save_nii(a1,[scans{subj} '_QC_scan.nii']);

close all
end
