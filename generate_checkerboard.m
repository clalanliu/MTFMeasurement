width = 8;
height = 4;
I = checkerboard(120,height/2,width/2);
K = (I > 0.5);
imshow(K);
imwrite(K, ['checkerboard_120p_',num2str(width),'_',num2str(height),'.bmp'])