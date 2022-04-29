clc;
clear;;
path='DB';
fileinfo = dir(fullfile(path,'*.png'));
filesnumber=size(fileinfo);
fsize=filesnumber(1,1);
for i = 1 : fsize
images{i} = imread(fullfile(path,fileinfo(i).name));
    disp(['Loading image No :   ' num2str(i) ]);
end;

%% Adjust
for i = 1:fsize   
sizee{i} = imadjust(images{i});
    disp(['Adjusting intensity value :   ' num2str(i) ]);
end;
% imshow(sizee{7});


% Crop
for i = 1:fsize   
Crop{i} = imcrop(sizee{i},[220 220 160 160]);
    disp(['CROP :   ' num2str(i) ]);
end;
% imshow(Crop{7});

% Channels
for i = 1:fsize   
Crop{i} = cat(3,Crop{i},Crop{i},Crop{i});
end;

%% Resize
for i = 1:fsize   
Crop{i} = imresize(Crop{i},[256 256]);
end;

% Double
for i = 1:fsize   
Crop{i} = im2double(Crop{i});
end;


% Save to disk
for i = 1:fsize   
   imwrite(Crop{i},strcat('my_new',num2str(i),'.jpg'));
end

