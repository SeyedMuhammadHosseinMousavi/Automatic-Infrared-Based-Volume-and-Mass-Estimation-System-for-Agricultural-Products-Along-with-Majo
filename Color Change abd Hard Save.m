clc;
clear;;
path='DB';
fileinfo = dir(fullfile(path,'*.jpg'));
filesnumber=size(fileinfo);
fsize=filesnumber(1,1);
for i = 1 : fsize
images{i} = imread(fullfile(path,fileinfo(i).name));
    disp(['Loading image No :   ' num2str(i) ]);
end;

%% Adjust
% for i = 1:fsize   
% sizee{i} = imadjust(images{i});
%     disp(['Adjusting intensity value :   ' num2str(i) ]);
% end;
% imshow(sizee{7});
%% Histogram eq
% for i = 1:fsize   
% hist{i} = histeq(images{i});
%     disp(['Histogram eq :   ' num2str(i) ]);
% end;

% crop
for i = 1:fsize   
sizee{i} = imcrop(images{i},[900 600 512 512]);
    disp(['CROP :   ' num2str(i) ]);
end;
imshow(sizee{7});

%% Resize
for i = 1:fsize   
sizee{i} = imresize(sizee{i},[256 256]);
end;
% 
% for i = 1:fsize   
% sizee{i} = uint8(sizee{i});
% end;

%save to disk
for i = 1:fsize   
   imwrite(sizee{i},strcat('my_new',num2str(i),'.jpg'));
end