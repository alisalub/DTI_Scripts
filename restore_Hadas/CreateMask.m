function CreateMask(Dir)
% create mask at the size of your DTI dimensions
%Add_OpenBruker
%Add_Nifti
% Dir='E:\Hadas\To_MD2';

find_mask=fuf([Dir '\*mask.nii'],'detail');
for i=1:length(find_mask)
    tmp=load_untouch_nii(find_mask{i});
    tmp_img=tmp.img;
    tmp_img(tmp_img~=0)=1;
%   tmp_img_DTI=repmat(tmp_img,[1 1 1 num_directions]);
    tmp.img=permute(tmp_img,[2 1 3]);
    [xdim,ydim,zdim]=size(tmp.img);
    tmp.hdr.dime.dim(2)=xdim;
    tmp.hdr.dime.dim(3)=ydim;
    save_untouch_nii(tmp,[find_mask{i}(1:end-4) '_DTImask.nii']);
end
end