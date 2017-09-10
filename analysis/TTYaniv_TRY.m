function Result=TTYaniv(Names, savename)


% Names={'ALGA1','ALSI1'}
% parameter - MRI measure ADC, FA, etc.
% the subj array shoul be control before, control after, treated before,
% treated after

s1=input('Enter no. of s1 >');
s2=input('Enter no. of s2 >');
s3=input('Enter no. of s3 >');
s4=input('Enter no. of s4 >');
s5=input('Enter no. of s5 >');
s6=input('Enter no. of s6 >');
Working_Path='C:\Users\user\Desktop\Alisa\Smoothed';


load_name=Names{1};
full_path_name=strcat(Working_Path,'\swPB',load_name,'_nii_regularized_MD_C_native_DWIs_MD_C_trafo_MD.nii') ;
nii=load_untouch_nii(full_path_name);
parameter=zeros(nii.hdr.dime.dim(2),nii.hdr.dime.dim(3),nii.hdr.dime.dim(4));
all_subj_arr=zeros((length(Names)), prod(size(parameter)));
nii2=load_untouch_nii('C:\Users\user\Desktop\Alisa\Smoothed\PBmask.nii');
mask=nii2.img;
%mask(find(mask<3000))=0;
mask(find(mask>0))=1;
mask=mask(:,:,:);

for i=1:length(Names)
    load_name=Names{i};
full_path_name=strcat(Working_Path,'\swPB',load_name,'_nii_regularized_MD_C_native_DWIs_MD_C_trafo_MD.nii') ;
    nii=load_untouch_nii(full_path_name);
    nii.img(find(mask==0))=0;
    AllSub(:,:,:,i)=nii.img;
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
                %                d0=all_subj_arr(1:d0_no,ind);
                %                d1=all_subj_arr(d0_no+1:d0_no+d1_no,ind);
                %                d4=all_subj_arr(d0_no+d1_no+1:d0_no+d1_no+d4_no,ind);
                %                d14=all_subj_arr(d0_no+d1_no+d4_no+1:d0_no+d1_no+d4_no+d14_no,ind);
                %                d30=all_subj_arr(d0_no+d1_no+d4_no+d14_no+1:d0_no+d1_no+d4_no+d14_no+d30_no,ind);
                
                data=all_subj_arr(:,ind);
 %               groups = {'d0','d0','d0','d0','d0','d0','d0','d0', 'd0', 'd0', 'd0', 'd0', 'd0',...
  %                  'd1','d1','d1','d1','d1','d1','d1','d1', 'd1',...
  %                  'd4','d4','d4','d4','d4','d4','d4','d4', 'd4', 'd4', 'd4', 'd4',...
  %                  'd14','d14','d14','d14','d14','d14','d14','d14', 'd14',...
  %                  'd30','d30','d30','d30','d30','d30','d30','d30', 'd30', 'd30', 'd30', 'd30'};
%                groups = {'d0','d0','d0','d0','d0','d0','d0','d0', 'd0', 'd0', 'd0', 'd0', 'd0',...
%                    'd1','d1','d1','d1','d1','d1','d1','d1', 'd1',...
%                    'd4','d4','d4','d4','d4','d4','d4','d4', 'd4', 'd4', 'd4', 'd4'};   

                groups = {'s1', 's1', 's1','s1', 's1', 's2', 's2', 's2', 's2', 's2', 's3', 's3', 's3', 's3' 's3', 's4', 's4', 's4', 's4', 's4', 's5', 's5', 's5', 's5', 's5', 's6', 's6', 's6', 's6', 's6' };
                       
                [p,table]=anova1(data, groups, 'off');
                
                
                Result(x,y,z)=p(1);
                
                
            end
        end
    end;
    toc
end;
%Result(find(Result>0.05))=0;
Result(find(Result>0.03))=0;
nii.img=Result.*100000;
savename1=sprintf('%s_ttest1',savename);
nii2=load_untouch_nii('C:\Users\user\Desktop\Alisa\Smoothed\PBmask.nii');
mask=nii2.img;
mask=mask(:,:,:);
%mask=mask(:,1:143,:);
mask(find(mask>0))=1;
nii.img(find(mask==0))=0;

nii.hdr.dime.scl_slope=1/100000;
save_untouch_nii(nii, savename1)


