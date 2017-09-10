function Result=ttestYaniv(Names, savename)


% Names={'ALGA1','ALSI1'}
% parameter - MRI measure ADC, FA, etc.
% the subj array shoul be control before, control after, treated before,
% treated after

parameter_name=input('Enter parameter >','s');
%subject_no=14;
Working_Path='D:\YanivDropbox\Dropbox\Tamar_data\12m_Before_After';

load_name=Names{1};
full_path_name=strcat(Working_Path,'\s',load_name, '.nii') ;
nii=load_untouch_nii(full_path_name);
parameter=zeros(nii.hdr.dime.dim(2),nii.hdr.dime.dim(3),nii.hdr.dime.dim(4));
all_subj_arr=zeros((length(Names)), prod(size(parameter)));
nii2=load_untouch_nii('AtlaS_T2_masked.nii');
mask=nii2.img;
mask(find(mask>0))=1;

for i=1:length(Names)
    load_name=Names{i};
full_path_name=strcat(Working_Path,'\s',load_name, '.nii') ;
    nii=load_untouch_nii(full_path_name);
    nii.img(find(mask==0))=0;
    all_subj_arr(i,:)=nii.img(:);
end

dims=[nii.hdr.dime.dim(2),nii.hdr.dime.dim(3),nii.hdr.dime.dim(4)];
Result=zeros(dims);

for x=1:dims(1)
    x
    tic
    for y=1:dims(2)
        %            disp(y);
        for z=1:dims(3)
            ind=sub2ind([dims(1) dims(2) dims(3)],x,y,z);
            if all_subj_arr(1,ind)~=0

                learning(:,1)=all_subj_arr(1:14,ind);
                learning(:,2)=all_subj_arr(15:end,ind);

                
            [p,table]=anova_rm({learning  } ,'off');
            Result(x,y,z)=p(1);
            end             
        end
    end;
    toc
end;
Result(find(Result>0.05))=0;
nii.img=Result.*100000;

nii2=load_untouch_nii('AtlaS_T2_masked.nii');
mask=nii2.img;
mask(find(mask>0))=1;

nii.hdr.dime.scl_slope=1/100000;
save_untouch_nii(nii, savename);


