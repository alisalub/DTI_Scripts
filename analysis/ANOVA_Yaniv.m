function Result=ANOVA_Yaniv(Names, savename)


% Names={'ALGA1','ALSI1'}
% parameter - MRI measure ADC, FA, etc.
% the subj array shoul be control before, control after, treated before,treated after
%anova_rm - repeated measure

parameter_name=input('Enter parameter >','s');
C_no=input('Enter no. of C subjects >');
AP_no=input('Enter no. of AP subjects >');
TB_no=input('Enter no. of TB subjects >');
subject_no=(C_no+AP_no+TB_no);
Working_Path='/Volumes/SAMSUNG 1/MSc_PhD/DTI_Analysis/smoothed_allscans';

load_name=Names{1};
full_path_name=strcat(Working_Path,'\swrT',load_name,'_nii_MD_C_native_MD_cropped.nii') ;
nii=load_untouch_nii(full_path_name);
parameter=zeros(nii.hdr.dime.dim(2),nii.hdr.dime.dim(3),nii.hdr.dime.dim(4));
all_subj_arr=zeros((length(Names)), prod(size(parameter)));
nii2=load_untouch_nii('AvFAmask.nii');
mask=nii2.img;
%mask(find(mask<3000))=0;
mask(find(mask>0))=1;
mask=mask(:,:,:);

for i=1:length(Names)
    load_name=Names{i};
full_path_name=strcat(Working_Path,'\swrT',load_name,'_nii_MD_C_native_MD_cropped.nii') ;
    nii=load_untouch_nii(full_path_name);
    nii.img(find(mask==0))=0;
    AllSub(:,:,:,i)=nii.img;
    all_subj_arr(i,:)=nii.img(:);
end

dims=[nii.hdr.dime.dim(2),nii.hdr.dime.dim(3),nii.hdr.dime.dim(4)];
ResultMain1=zeros(dims);
ResultMain2=zeros(dims);
ResultInt=zeros(dims);
ResultTtest=zeros(dims);
ResultTtestAP5M1=zeros(dims);
ResultTtestAP5int=zeros(dims);

for x=1:dims(1)
    x
    tic
    for y=1:dims(2)
        %            disp(y);
        for z=1:dims(3)
            ind=sub2ind([dims(1) dims(2) dims(3)],x,y,z);
            if all_subj_arr(1,ind)~=0
                control(:,1)=all_subj_arr(1:C_no,ind);
                control(:,2)=all_subj_arr(1+C_no:C_no*2,ind);
                AP(:,1)=all_subj_arr(C_no*2+1:C_no*2+AP_no,ind);
                AP(:,2)=all_subj_arr(C_no*2+AP_no+1:C_no*2+AP_no*2,ind);
                TB(:,1)=all_subj_arr(subject_no*2-TB_no*2+1:subject_no*2-TB_no,ind);
                TB(:,2)=all_subj_arr(subject_no*2-TB_no+1:subject_no*2,ind);
                
                GL=[3 4 5 7 8 11 12 13];
                BL=[1 2 6 9 10 14 15 16];
                pco=AP(:,2)-AP(:,1);
                pap=control(:,2)-control(:,1);
                APGL=control(GL,:);
                APBL=control(BL,:);
             
                
                
                [p,table]=anova_rm({AP control TB},'off');
                [H, p2]=ttest(AP(:,1), AP(:,2));
                [p3,table2]=anova_rm({APGL APBL},'off');
                
            ResultMain1(x,y,z)=cell2mat(table(2,6));;
            ResultMain2(x,y,z)=cell2mat(table(3,6));
            ResultInt(x,y,z)=cell2mat(table(4,6));
            ResultTtest(x,y,z)=p2;
            ResultTtestAP5M1(x,y,z)=cell2mat(table(2,6));;
            ResultTtestAP5int(x,y,z)=cell2mat(table(4,6));;

            end             
        end
    end;
    toc
end;
ResultInt(find(ResultInt>0.05))=0;
nii.img=ResultInt.*100000;
savename1=sprintf('%s_int',savename);
nii2=load_untouch_nii('AvFAmask.nii');
mask=nii2.img;
mask=mask(:,:,:);
%mask=mask(:,1:143,:);
mask(find(mask>0))=1;
nii.img(find(mask==0))=0;

nii.hdr.dime.scl_slope=1/100000;
save_untouch_nii(nii, savename1)


ResultMain1(find(ResultMain1>0.05))=0;
nii.img=ResultMain1.*100000;
savename1=sprintf('%s_Main1',savename);
nii2=load_untouch_nii('AvFAmask.nii');
mask=nii2.img;
mask=mask(:,:,:);
%mask=mask(:,1:143,:);
mask(find(mask>0))=1;
nii.img(find(mask==0))=0;

nii.hdr.dime.scl_slope=1/100000;
save_untouch_nii(nii, savename1)



ResultMain2(find(ResultMain2>0.05))=0;
nii.img=ResultMain2.*100000;
savename1=sprintf('%s_Main2',savename);
nii2=load_untouch_nii('AvFAmask.nii');
mask=nii2.img;
mask=mask(:,:,:);
%mask=mask(:,1:143,:);
mask(find(mask>0))=1;
nii.img(find(mask==0))=0;

nii.hdr.dime.scl_slope=1/100000;
save_untouch_nii(nii, savename1)


ResultTtest(find(ResultTtest>0.05))=0;
nii.img=ResultTtest.*100000;
savename1=sprintf('%s_Ttest',savename);
nii2=load_untouch_nii('AvFAmask.nii');
mask=nii2.img;
mask=mask(:,:,:);
%mask=mask(:,1:143,:);
mask(find(mask>0))=1;
nii.img(find(mask==0))=0;

nii.hdr.dime.scl_slope=1/100000;
save_untouch_nii(nii, savename1)

ResultTtestAP5M1(find(ResultTtestAP5M1>0.05))=0;
nii.img=ResultTtestAP5M1.*100000;
savename1=sprintf('%s_TtestAP5M1',savename);
nii2=load_untouch_nii('AvFAmask.nii');
mask=nii2.img;
mask=mask(:,:,:);
%mask=mask(:,1:143,:);
mask(find(mask>0))=1;
nii.img(find(mask==0))=0;

nii.hdr.dime.scl_slope=1/100000;
save_untouch_nii(nii, savename1)

ResultTtestAP5int(find(ResultTtestAP5int>0.05))=0;
nii.img=ResultTtestAP5int.*100000;
savename1=sprintf('%s_TtestAP5int',savename);
nii2=load_untouch_nii('AvFAmask.nii');
mask=nii2.img;
mask=mask(:,:,:);
%mask=mask(:,1:143,:);
mask(find(mask>0))=1;
nii.img(find(mask==0))=0;

nii.hdr.dime.scl_slope=1/100000;
save_untouch_nii(nii, savename1)
