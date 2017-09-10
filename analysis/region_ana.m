function [mKloc npix nregi] = region_ana(Names, imblobs)

C_no=input('Enter no. of subjects >');
Working_Path='F:\NY\analysis';

subject_no=C_no;

load_name=Names{1};
full_path_name=strcat(Working_Path,'\Sub_swrNYR',load_name,'_nii_regularized_MD_C_native_MD.nii') ;
nii=load_untouch_nii(full_path_name);
parameter=zeros(nii.hdr.dime.dim(2),nii.hdr.dime.dim(3),nii.hdr.dime.dim(4));
all_subj_arr=zeros((length(Names)), prod(size(parameter)));
nii2=load_untouch_nii('AvFAmask.nii');
mask=nii2.img;
%mask(find(mask<3000))=0;
mask(find(mask>0))=1;

for i=1:length(Names)
    load_name=Names{i};
    full_path_name=strcat(Working_Path,'\Sub_swrNYR',load_name,'_nii_regularized_MD_C_native_MD.nii') ;
    nii=load_untouch_nii(full_path_name);
    nii.img(find(mask==0))=0;
    AllSub(:,:,:,i)=nii.img;
    all_subj_arr(i,:)=nii.img(:);
end


[sx sy sz sk]=size(AllSub);
for i=1:sx
    for j=1:sy
        for k=1:sz
            for l=1:sk
                if isnan(AllSub(i,j,k,l))==1
                    AllSub(i,j,k,l)=0;
                end
            end
        end
    end
end

AllSub(find(AllSub<-30))=0;
AllSub(find(AllSub>30))=0;
% sAPb=AllSub(:,:,:,1:13);
% sAPa=AllSub(:,:,:,14:26);
% sCOb=AllSub(:,:,:,27:35);
% sCOa=AllSub(:,:,:,36:44);
% sTBb=AllSub(:,:,:,54:65);
% sTBa=AllSub(:,:,:,66:77);
% dCO=sAPa-sAPb;
% mdCO=mean(dCO,4);
% mdCO(find(mdCO>0))=0;

% mdCO=mean(AllSub(:,:,:,14:23),4);
% mdCO(find(mdCO>0))=0;


atlas=load_untouch_nii('SMratlas.nii');
NA=atlas.img;
Aimg=NA;
nareas=max(max(max(Aimg)));


mKloc=zeros(subject_no, nareas);

for na=1:nareas
    Ablobs=imblobs;
    Ablobs(find(Aimg~=na))=0;
%    Ablobs(find(mdCO==0))=0;
    RAblobs=repmat(Ablobs, [1 1 1 subject_no]);
    RAblobs(find(RAblobs>0))=1;
    loc=find(Ablobs>0);
    regi=Aimg;
    regi(find(Aimg~=na))=0;
    regi(find(regi>0))=1;
    nregi(na)=sum(sum(sum(regi)));
    npix(na)=length(loc);
    if npix(na)>5
        RegAllsub=AllSub.*RAblobs;
        for nsub=1:subject_no
            singsub=RegAllsub(:,:,:,nsub);
            singsub=singsub(find(singsub~=0));
            singsub=sort(singsub);
            round(0.2*length(singsub))
            round(0.7*length(singsub))            
            singsub=singsub(round(1+0.2*length(singsub)):round(0.7*length(singsub)));
            mKloc(nsub,na)=mean(singsub);
        end
    end
end






