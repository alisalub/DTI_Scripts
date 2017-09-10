
%  we need to change it and name the new file seg2.


files = dir('*seg.nii');
for i=1:length(files)
    i1=load_untouch_nii(files(i).name);
    im=i1.img;
    im(find(im==2))=1;
    im(find(im==3))=2;
    im(find(im==4))=2;
    im(find(im==5))=3;
    i1.img=im;

new_name = [files(i).name(1:end-4) '2.nii'];
save_untouch_nii(i1, new_name);
end
