function correctim(filename)

fname=sprintf('%s.nii', filename);

i1=load_untouch_nii(fname);
im=i1.img;

for i=1:50
im1((i-1)*118+1:i*118,:)=im(:,:,i);
end

im2 = histeq(uint16(im1), 16384);
im2=im2-min(min(min(im2)));

for i=1:50
    im3(:,:,i)=im2((i-1)*118+1:i*118,:);
end

i1.img=im3;

fname=sprintf('H%s.nii', filename);
save_untouch_nii(i1,fname);

