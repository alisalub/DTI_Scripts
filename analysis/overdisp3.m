% display images
function [mKloc npix nregi]=overdisp3(blobs,temp, clusize, subj_name);

atlas=load_untouch_nii('SMratlas.nii');
% for i=1:18
%     NA2(:,:,i)=fliplr(NA2(:,:,i));
%     NA(:,:,i)=fliplr(NA(:,:,i));
%     BW(:,:,i)=fliplr(BW(:,:,i));
% end
load('new_ratlas_outline');
img3=BW;

NA=atlas.img;


niitemp=load_untouch_nii(temp);
%imtemp=niitemp.img;
imtemp=double(niitemp.img);
niiblobs=load_untouch_nii(blobs);
imblobs(:,:,:)=niiblobs.img.*niiblobs.hdr.dime.scl_slope;
imblobs(find(NA==0))=0;
%img3=BW;
%NA(find(NA==22))=25;
%imblobs(find(NA==0))=0;
%imblobs(find(NA~=25))=0;
imblobs(find(imblobs>0.05))=0;

imblobs2=zeros(size(imblobs));
imblobs2(find(imblobs>0.005))=0;
imblobs2(find(imblobs<0.0025))=1;
imblobs2(find(imblobs<0.001))=2;
imblobs2(find(imblobs<0.0005))=3;
imblobs2(find(imblobs<0.00025))=4;
imblobs2(find(imblobs<0.0001))=5;
imblobs2(find(imblobs<0.00009))=6;
imblobs2(find(imblobs<0.00008))=7;
imblobs2(find(imblobs<0.00007))=8;
imblobs2(find(imblobs<0.00006))=9;
imblobs2(find(imblobs<0.00005))=10;
imblobs2(find(imblobs<0.00004))=11;
imblobs2(find(imblobs<0.00003))=12;
imblobs2(find(imblobs<0.00002))=13;
imblobs2(find(imblobs<0.00001))=14;
imblobs2(find(imblobs<0.000005))=15;
imblobs2(find(imblobs<0.000001))=16;
imblobs2(find(imblobs==0))=0;
imblobs=imblobs2;

for idx=1:size(imblobs,3)
    mask1=logical(imblobs(:,:,idx));
    labels = bwlabel(mask1);
    areas = regionprops(labels,'area');
    areas = struct2cell(areas);
    areas = cell2mat(areas);
    mAreas = find(areas > clusize);
    for ind = 1:length(mAreas)
     labels(labels==mAreas(ind))=-1;
    end
    labels(labels~=-1)=0;
    labels=labels.*-1;
%     imagesc(imblobs(:,:,5).*labels);
    imblobs(:,:,idx)=imblobs(:,:,idx).*labels;
end
imtemp(find(imtemp>0.5))=0.5;
imtemp=round(256.*imtemp./max(max(max(imtemp))));

imtemp_RGB=ind2rgb2(imtemp,gray(256));

rgblist=[0.875 0 0; 1 0 0; 1 0.125 0; 1 0.25 0; 1 0.375 0; 1 0.5 0; 1 0.625 0; 1 0.75 0; 1 0.875 0; 1 1 0; 1 1 0.1667; 1 1 0.333; 1 1 0.5; 1 1 0.667; 1 1 0.833; 1 1 1];

C1=imtemp_RGB(:,:,:,1);
C2=imtemp_RGB(:,:,:,2);
C3=imtemp_RGB(:,:,:,3);

C1(find(imblobs==1))=0.875;
C1(find(imblobs==2))=1;
C1(find(imblobs==3))=1;
C1(find(imblobs==4))=1;
C1(find(imblobs==5))=1;
C1(find(imblobs==6))=1;
C1(find(imblobs==7))=1;
C1(find(imblobs==8))=1;
C1(find(imblobs==9))=1;
C1(find(imblobs==10))=1;
C1(find(imblobs==11))=1;
C1(find(imblobs==12))=1;
C1(find(imblobs==13))=1;
C1(find(imblobs==14))=1;
C1(find(imblobs==15))=1;
C1(find(imblobs==16))=1;

C2(find(imblobs==1))=0;
C2(find(imblobs==2))=0;
C2(find(imblobs==3))=0.125;
C2(find(imblobs==4))=0.25;
C2(find(imblobs==5))=0.375;
C2(find(imblobs==6))=0.5;
C2(find(imblobs==7))=0.625;
C2(find(imblobs==8))=0.75;
C2(find(imblobs==9))=0.875;
C2(find(imblobs==10))=1;
C2(find(imblobs==11))=1;
C2(find(imblobs==12))=1;
C2(find(imblobs==13))=1;
C2(find(imblobs==14))=1;
C2(find(imblobs==15))=1;
C2(find(imblobs==16))=1;

C3(find(imblobs==1))=0.0;
C3(find(imblobs==2))=0.0;
C3(find(imblobs==3))=0.0;
C3(find(imblobs==4))=0;
C3(find(imblobs==5))=0;
C3(find(imblobs==6))=0;
C3(find(imblobs==7))=0;
C3(find(imblobs==8))=0;
C3(find(imblobs==9))=0;
C3(find(imblobs==10))=0;
C3(find(imblobs==11))=0.1667;
C3(find(imblobs==12))=0.3333;
C3(find(imblobs==13))=0.5;
C3(find(imblobs==14))=0.6667;
C3(find(imblobs==15))=0.8333;
C3(find(imblobs==16))=1;

imblobshdr.dim=niiblobs.hdr.dime.dim(2:4);

 C1=imresize(C1,[imblobshdr.dim(1)*4 imblobshdr.dim(2)*4], 'nearest');
 C2=imresize(C2,[imblobshdr.dim(1)*4 imblobshdr.dim(2)*4], 'nearest');
 C3=imresize(C3,[imblobshdr.dim(1)*4 imblobshdr.dim(2)*4], 'nearest');
% 
 C1(find(img3==1))=0;
 C2(find(img3==1))=0;
 C3(find(img3==1))=0.5;

totrgb(:,:,:,1)=C1;
totrgb(:,:,:,2)=C2;
totrgb(:,:,:,3)=C3;

   for i=1:28
 %      %subplot(4, 6, i-2); imshow(imrotate(squeeze(totrgb(:,:,i,:)), -90)); axis tight; axis off
      figure; imshow(imrotate(squeeze(totrgb(:,:,i,:)),-90)); title(i); axis tight; axis off
   end
pause; close all
[mKloc npix nregi]=region_ana(subj_name, imblobs);
