vv=load_untouch_nii('HL3_C4S5_COND_2Repit_nii_cropped.nii');
da=vv.img;
name='HL3_C4S5_COND_2Repit_nii_cropped.nii';

for k=1:24


mda=da(:,:,k,:);
for i=1:68
b=mda(:,:,1,i);
mb=mean(mean(mean(b)));
vic(i)=mb;
end

P=polyfit(1:4,vic(1:4),5);
newy=P(1).*(1:4).^5+ P(2).*(1:4).^4+ P(3).*(1:4).^3+P(4).*(1:4).^2+P(5).*(1:4)+P(6);
newy=newy./newy(1);

for i=1:4
im1=da(:,:,k,i);
im1=im1./newy(i);
da(:,:,k,i)=im1;
end


da(:,:,k,5:36)=da(:,:,k,5:36)./mean(newy(1:2));
da(:,:,k,37:68)=da(:,:,k,37:68)./mean(newy(3:4));

mda=da(:,:,k,:);
for i=1:68
b=mda(:,:,1,i);
mb=mean(mean(mean(b)));
vic(i)=mb;
end


P=polyfit(5:68,vic(5:68),3);
newy=P(1).*(5:68).^3+P(2).*(5:68).^2+P(3).*(5:68)+P(4);
newy=newy./newy(1);
for i=5:68
im1=da(:,:,k,i);
im1=im1./newy(i-4);
da(:,:,k,i)=im1;
i;
end
k;
end
vv.img=da;
save_untouch_nii(vv,[name(1:end-4),'_drift.nii']);