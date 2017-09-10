function pi10(name);




i1=load_untouch_nii(name);
xfactor=10; %1/i1.hdr.dime.pixdim(2);

i1.hdr.dime.pixdim(2:4)=i1.hdr.dime.pixdim(2:4).*xfactor;
i1.hdr.hist.srow_x=i1.hdr.hist.srow_x.*xfactor;
i1.hdr.hist.srow_y=i1.hdr.hist.srow_y.*xfactor;
i1.hdr.hist.srow_z=i1.hdr.hist.srow_z.*xfactor;


sname1=sprintf('T%s', name);


save_untouch_nii(i1, sname1);


