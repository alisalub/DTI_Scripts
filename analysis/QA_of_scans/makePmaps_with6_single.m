function makePmaps_with6(niifile, thresh, numGaus)


niifile1=sprintf('%s.nii', niifile);

im=load_untouch_nii(niifile1);
zi=single(im.img);
zi(find(zi<thresh))=0;
zi0=zi(find(zi>0));
% zi0(find(zi0>max(zi0)/2.0))=max(zi0/2.0);
if (numGaus == 6)
    s=struct('mu', [0.02*max(zi0) 0.05*max(zi0) 0.12*max(zi0) 0.24*max(zi0) 0.30*max(zi0)  0.58*max(zi0) ]', 'Sigma', [20 20 20 20 20 20]', 'PCcomponents', [0.01 0.01 0.3 0.4 0.28]');
else
    s=struct('mu', [0.02*max(zi0) 0.05*max(zi0) 0.12*max(zi0) 0.24*max(zi0) ]', 'Sigma', [20 20 20 20 ]', 'PCcomponents', [0.01 0.01 0.3 ]');
end

sigma(1,1,1)=20*max(zi0);
sigma(1,1,2)=20*max(zi0);
sigma(1,1,3)=20*max(zi0);
sigma(1,1,4)=20*max(zi0);

if (numGaus==6)
    sigma(1,1,5)=20*max(zi0);
    sigma(1,1,6)=20*max(zi0);
end

s.Sigma=sigma;
options = statset('MaxIter', 10000, 'TolFun', 1e-7, 'Display', 'final');

if (numGaus==6)
    obj=gmdistribution.fit(zi0, 6, 'Options', options, 'Start', s, 'Regularize', 1e-5);
else
    obj=gmdistribution.fit(zi0, 4, 'Options', options, 'Start', s);
end

objC=gmdistribution(obj.mu, obj.Sigma, obj.PComponents);
x=min(zi0):(max(zi0)-min(zi0))/99:max(zi0);
B=pdf(objC,[x']);
histi=hist(double(zi0),100);
% figure;
% plot(B/sum(B));
% hold on
% plot(histi/sum(histi),'r')
% hold off
%
% pause

p1=zeros(size(zi));
p2=zeros(size(zi));
p3=zeros(size(zi));
p4=zeros(size(zi));
if (numGaus==6)
    p5=zeros(size(zi));
    p6=zeros(size(zi));
end

objp1=gmdistribution(obj.mu(1), obj.Sigma(1,1,1), 1);
objp2=gmdistribution(obj.mu(2), obj.Sigma(1,1,2), 1);
objp3=gmdistribution(obj.mu(3), obj.Sigma(1,1,3), 1);
objp4=gmdistribution(obj.mu(4), obj.Sigma(1,1,4), 1);
if (numGaus==6)
    objp5=gmdistribution(obj.mu(5), obj.Sigma(1,1,5), 1);
    objp6=gmdistribution(obj.mu(6), obj.Sigma(1,1,6), 1);
end

sizeim=size(zi);


for i=1:sizeim(1)
    for j=1:sizeim(2)
        for k=1:sizeim(3)
            if zi(i,j,k)>0
                p1(i,j,k)=pdf(objp1, zi(i,j,k));
                p2(i,j,k)=pdf(objp2, zi(i,j,k));
                p3(i,j,k)=pdf(objp3, zi(i,j,k));
                p4(i,j,k)=pdf(objp4, zi(i,j,k));
                if (numGaus==6)
                    p5(i,j,k)=pdf(objp5, zi(i,j,k));
                    p6(i,j,k)=pdf(objp6, zi(i,j,k));
                end
            end
        end
    end
end
im.hdr.dime.scl_slope=1/32768;

if (numGaus==6)
    niifile1=sprintf('%s_p1.nii', niifile);
    im.img=32768*p1./(p1+p2+p3+p4+p5+p6);
    save_untouch_nii(im,niifile1);
    niifile1=sprintf('%s_p2.nii', niifile);
    
    im.img=32768*p2./(p1+p2+p3+p4+p5+p6);
    save_untouch_nii(im,niifile1);
    niifile1=sprintf('%s_p3.nii', niifile);
    
    im.img=32768*(p3)./(p1+p2+p3+p4+p5+p6);
    save_untouch_nii(im,niifile1);
    niifile1=sprintf('%s_p4.nii', niifile);
    
    im.img=32768*p4./(p1+p2+p3+p4+p5+p6);
    save_untouch_nii(im,niifile1);
    niifile1=sprintf('%s_p5.nii', niifile);
    
    im.img=32768*(p5)./(p1+p2+p3+p4+p5+p6);
    save_untouch_nii(im,niifile1);
    niifile1=sprintf('%s_p6.nii', niifile);
    
    im.img=32768*p6./(p1+p2+p3+p4+p5+p6);
    save_untouch_nii(im,niifile1);
else
    im.img=32768*p1./(p1+p2+p3+p4);
    save_untouch_nii(im,'p1.nii');
    
    im.img=32768*p2./(p1+p2+p3+p4);
    save_untouch_nii(im,'p2.nii');
    
    im.img=32768*p3./(p1+p2+p3+p4);
    save_untouch_nii(im,'p3.nii');
    
    im.img=32768*p4./(p1+p2+p3+p4);
    save_untouch_nii(im,'p4.nii');
    
end
end

