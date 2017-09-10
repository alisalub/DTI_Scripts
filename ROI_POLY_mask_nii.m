function ROI_POLY_mask_nii()
[filename,pathname] = uigetfile('*.nii','Select NIfTI file:');
ff = fullfile(pathname,filename);
nii=load_untouch_nii(ff);
cont = questdlg('Are you continuing an image you''ve already started working on?','!','Yes','No','No');
if strcmp(cont,'Yes')
    [tempfile,temppath] = uigetfile('*.mat','Load temporary MATLAB file:');
    load(fullfile(temppath,tempfile));
    imagesc(new_img(:,:,end));
    title(['Slice number #' num2str(size(new_img,3))])
    cont2 = questdlg('Is this the finished last slice you worked on?','!','Yes','No','Yes');
    if strcmp(cont2,'Yes')
        startInd = size(new_img,3)+1;
    else
        startStr = inputdlg('Enter slice to start:','Slice selection',1,{''});
        startInd = str2double(startStr{1});
    end
else
    startInd = 1;
    dem = figure;
    imagesc(nii.img(:,:,end/2));
    chang = questdlg(['This is the default image. Do you want to change perumtation/rotaion? (number of slices: ' num2str(size(nii.img,3)) ')'],'!','Yes','No','No');
    close(dem);
    if strcmp(chang,'Yes')
        while 1
            permStr = inputdlg('Select permutation (default is: 1 2 3):','Permutation',1,{'1 2 3'});
            permReg = regexp(permStr,'\d');
            perm = [str2double(permStr{1}(permReg{1}(1))) str2double(permStr{1}(permReg{1}(2))) str2double(permStr{1}(permReg{1}(3)))];
            tempIMG = permute(nii.img,perm);
            dem = figure;
            imagesc(tempIMG(:,:,end/2))
            conf = questdlg(['Is the orientation OK? (number of slices: ' num2str(size(tempIMG,3)) ')'],'!','Yes','No','Yes');
            close(dem);
            if strcmp(conf,'Yes')
                break;
            end
        end
        
        while 1
            rotStr = inputdlg('Rotate image *clockwise* (default is 0):','Rotation',1,{'0'});
            rot = 360 - str2double(rotStr{1});
            tempIMG2 = imrotate(tempIMG,rot);
            dem = figure;
            imagesc(tempIMG2(:,:,end/2));
            conf = questdlg(['Is the rotation OK? (number of slices: ' num2str(size(tempIMG,3)) ')'],'!','Yes','No','Yes');
            close(dem);
            
            if strcmp(conf,'Yes')
                break;
            end
        end
    else
        rot = 0;
        perm = [1 2 3];
    end
    img = mat2gray(imrotate(permute(nii.img,perm),rot));
    mask = false(size(img));
end
dem = figure;
for ind=startInd:size(img,3)
    imagesc(img(:,:,ind));
    title(['Slice number #' num2str(ind)])
    temp_poly = roipoly;
    mask(:,:,ind)=temp_poly;
    new_img(:,:,ind) = img(:,:,ind).*mask(:,:,ind);
    save([ff(1:end-4) '_temp.mat'],'img','new_img','mask','perm','rot','ff','nii');
end
close(dem);
revert = questdlg('Revert back to original permutation?','!','Yes','No','Yes');
switch revert
    case 'Yes'
        
        final_img=ipermute(imrotate(new_img,-rot),perm);
        
    case 'No'
        final_img=new_img;
end
nii.img=final_img;
[savename,savepath] = uiputfile('*.nii','Save new NIfTI file as:',[ff(1:end-4) '_masked2.nii']);
save_untouch_nii(nii,fullfile(savepath,savename))
end