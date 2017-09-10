function The_Real_Restore(Dir)
% Add_OpenBruker
% Dir='E:\Hadas\To_MD2';
find_mat=fuf([Dir '\*.mat'],'detail');
for i=1:length(find_mat)
    find_mask=fuf([find_mat{i}(1:end-4) '*DTI2mask.nii'],'detail');
    if ~isempty(find_mask)
        tmp=load_untouch_nii(find_mask{1});
        mask=tmp.img;
        Restore_DTI(find_mat{i},[find_mat{i}(1:end-4) '_restored.mat'],mask);
    else
        Restore_DTI(find_mat{i});
    end
end
