%remove the background from the resampled T2 masks
%500 was chosen based on the values in the back

files = dir('*T2.nii');
for i=1:length(files)
    im=load_untouch_nii(files(i).name);
    im.img(im.img<0.01)=0;

new_name = [files(i).name(1:end-4) '_zero.nii'];
save_untouch_nii(im, new_name);


end




