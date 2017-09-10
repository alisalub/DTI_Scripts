function Result=Anova1_TRY_alisa(Names, savename)

% https://www.mathworks.com/help/stats/repeatedmeasuresmodel.ranova.html !!

% Names={'ALGA1','ALSI1'}
% parameter - MRI measure ADC, FA, MD etc.
% the subj array should be control before, control after, treated before,
% treated after
% this is the sript for comparin all the scans, wothout group separation!

s1=input('Enter no. of s1 >'); %number of subjects in scan 1 : 16
s2=input('Enter no. of s2 >'); %16
s3=input('Enter no. of s3 >'); %16
s4=input('Enter no. of s4 >'); %16
s5=input('Enter no. of s5 >'); %16
s6=input('Enter no. of s6 >'); %13
s7=input('Enter no. of s7 >'); %10
Working_Path='/Volumes/SAMSUNG/MSc_PhD/DTI_Analysis/smoothed_allscans';


load_name=Names{1};
full_path_name=strcat(Working_Path,'\sw',load_name,'_nii_regularized_MD_C_native_MD_C_trafo_FA.nii') ;
nii=load_untouch_nii(full_path_name);
parameter=zeros(nii.hdr.dime.dim(2),nii.hdr.dime.dim(3),nii.hdr.dime.dim(4));
all_subj_arr=zeros((length(Names)), prod(size(parameter)));
nii2=load_untouch_nii('/Volumes/SAMSUNG/MSc_PhD/DTI_Analysis/smoothed_allscans/AverageFA.nii');
mask=nii2.img;
%mask(find(mask<3000))=0;
mask(find(mask>0))=1;
mask=mask(:,:,:);

for i=1:length(Names)
    load_name=Names{i};
full_path_name=strcat(Working_Path,'\sw',load_name,'_nii_regularized_MD_C_native_MD_C_trafo_FA.nii') ;
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
%Result(find(Result>0.01))=0;
Result(find(Result>0.05))=0; %P value
nii.img=Result.*100000;
savename1=sprintf('%s_anova1',savename);
nii2=load_untouch_nii('/Volumes/SAMSUNG/MSc_PhD/DTI_Analysis/smoothed_allscans/AverageFA.nii');
mask=nii2.img;
mask=mask(:,:,:);
%mask=mask(:,1:143,:);
mask(find(mask>0))=1;
nii.img(find(mask==0))=0;

nii.hdr.dime.scl_slope=1/100000;
save_untouch_nii(nii, savename1)


