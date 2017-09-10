function SaveBmat(nii_Bmat,path,filename)


ExploreDTIBmat=nii_Bmat(:,[1 2 3 5 6 9]);
multiplier=repmat([1 2 2 1 2 1],[size(ExploreDTIBmat,1) 1]);
ExploreDTIBmat=ExploreDTIBmat.*multiplier;

% save B mat ( bxx , 2bxy , 2bxz , byy , 2byz , bzz )
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

save([path '\' filename  '_6Bmat.txt'],'ExploreDTIBmat','-ASCII');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
