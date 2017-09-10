function Temp_img_After = rotateBrain(vol)
    Temp_img=permute(vol,[1 3 2]);
    Temp_img=imrotate(Temp_img,90);
    Temp_img_After=Temp_img;
end