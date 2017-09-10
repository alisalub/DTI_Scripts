function di10(name);




i1=load_untouch_nii(name);
sname1=sprintf('mT%s', name);
i2=load_untouch_nii(sname1);
i1.img=i2.img;
sname2=sprintf('DT%s', name);


save_untouch_nii(i1, sname2);


