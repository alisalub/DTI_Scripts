cluster_nii = load_untouch_nii('WT_VS_KO_16mice_p_main_Between_WTvsKO_0.01_FA_FAcluster10.nii');
fa_nii = load_untouch_nii('AverageFA.nii');
cluster_map = cluster_nii.img;
fa_map = fa_nii.img;
for cluster=1:max(cluster_map(:))
figure
mask = cluster_map == cluster;
linear_index = find (mask);
[x,y,z] = ind2sub(size(mask),linear_index);
x_slice = mode(x);
y_slice = mode(y);
z_slice = mode(z);
x_map = mat2gray(imrotate(squeeze(fa_map(x_slice,:,:)),90));
x_mask = imrotate(squeeze(mask(x_slice,:,:)),90);
subplot(1,3,1)
imshow(imoverlay(x_map,x_mask,[1 0 1]));
title(['X slice: ' num2str(x_slice)])

y_map = mat2gray(imrotate(squeeze(fa_map(:,y_slice,:)),90));
y_mask = imrotate(squeeze(mask(:,y_slice,:)),90);
subplot(1,3,2)
imshow(imoverlay(y_map,y_mask,[1 0 1]));
title(['Y slice: ' num2str(y_slice)])

z_map = imrotate(mat2gray(fa_map(:,:,z_slice)),90);
z_mask = imrotate(mask(:,:,z_slice),90);
subplot(1,3,3)
imshow(imoverlay(z_map,z_mask,[1 0 1]));
title(['Z slice: ' num2str(z_slice)])

% suptitle(['Cluster #' num2str(cluster)])

drawnow
end

