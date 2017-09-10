function [A]  = openImage2(fileName)
if ~exist(fileName,'file') 
    errordlg(['File not found '  fileName],'File Error ');        
    %error(['Can not find file ' fileName]);
            [fileName, pathname] = uigetfile('*.*',['Where is ' fileName ' ?']);
            fileName = [pathname fileName];
end
[A,hdr] = readanalyzeimg2(fileName);
A = (A-hdr.offset)*hdr.scale;
A = reshape(A,hdr.dim');
%A = flipdim(permute(A,[2 1 3]),1);



% 
% 
% 
% V=spm_vol(fileName);
% 
% fid1=fopen(fileName, 'rb'); 
% status=fseek(fid1,V.dim(1)*V.dim(2)*V.dim(3)*(-2),1);
% for i=1:V.dim(3)
%     a1=fread(fid1,[V.dim(1) V.dim(2)],'int16');
%     A(:,:,i)=imrotate(a1,90);
% end
% fclose(fid1);
% A=A./100;
