% Image reading
clear;
img=imread('a.jpg');
gray=rgb2gray(img);

%% Statistical data
sizeimg=size(gray);
% Removing Background
for i=1:sizeimg(1,1)
for j=1:sizeimg(1,2)
if gray(i,j)>100
newgray(i,j)=gray(i,j);
else
newgray(i,j)=0;
end;end;end;
% imshow(newgray,[]);

% Otsu Segmentation
thresh = multithresh(newgray,1);
seg_I = imquantize(newgray,thresh);
OtsuSeg = label2rgb(seg_I); 	 
% imshow(OtsuSeg);

% Extracting features of new test data
imset = imageSet('Test','recursive'); 
bag = bagOfFeatures(imset,'VocabularySize',20,'PointSelection','Detector');
SURF = encode(bag,imset);
hog= extractHOGFeatures(img,'CellSize',[128 128]);
Testdata=[hog SURF];
%Test new data with trained model
load('SVMColorNewData');
yfit = SVMColorNewData.predictFcn(Testdata);
if yfit == 1
yfitname='Carrot'
elseif yfit == 2
yfitname='Garlic'
elseif yfit == 3
yfitname='Potato'
elseif yfit == 4
yfitname='Quince'
end;

% Trace region boundaries
[B,L,N,A] = bwboundaries(newgray);
% imshow(label2rgb(L, @jet, [.9 .5 .5]))
% hold on
% imshow(newgray,[]);
% hold on;
% for k = 1:length(B)
% boundary = B{k};
% plot(boundary(:,2), boundary(:,1), 'g', 'LineWidth', 2)
% end

% Extracting Bounding Box position
s = regionprops(L,'BoundingBox');
% Adding Object Annotation Text
position = [s(1)];
position=position.BoundingBox;
label_str = ['Fruit: ' num2str(yfitname)];
RGB1 = insertObjectAnnotation(newgray,'rectangle',position,label_str,...
    'Color','cyan','TextBoxOpacity',0.9,'FontSize',18);
% imshow(imfuse(RGB1,newgray));
% hold on;
% for k = 1:length(B)
% boundary = B{k};
% plot(boundary(:,2), boundary(:,1), 'g', 'LineWidth', 2)
% end
% title('Detected Fruit');
% hold off;

% Region Properties
RP = regionprops(L,'Area','Centroid','Circularity','ConvexArea','EquivDiameter',...
    'MajorAxisLength','MinorAxisLength','Orientation','Perimeter','Solidity');
temp1=RP.Area;   disp(['Area :   ' num2str(temp1)]);
temp2=RP.Centroid;   disp(['Centroid :   ' num2str(temp2)]);
temp3=RP.Circularity;   disp(['Circularity :   ' num2str(temp3)]);
temp4=RP.ConvexArea;   disp(['ConvexArea :   ' num2str(temp4)]);
temp5=RP.EquivDiameter;   disp(['EquivDiameter :   ' num2str(temp5)]);
temp6=RP.MajorAxisLength;   disp(['MajorAxisLength :   ' num2str(temp6)]);
temp7=RP.MinorAxisLength;   disp(['MinorAxisLength :   ' num2str(temp7)]);
temp8=RP.Orientation;   disp(['Orientation :   ' num2str(temp8)]);
temp9=RP.Perimeter;   disp(['Perimeter :   ' num2str(temp9)]);
temp10=RP.Solidity;   disp(['Solidity :   ' num2str(temp10)]);

% Plot Image Annotation
names=[{['Area = ' num2str(temp1)]},{['Centroid = ' num2str(temp2)]},{['Circularity = ' num2str(temp3)]},{['ConvexArea = ' num2str(temp4)]},...
    {['EquivDiameter = ' num2str(temp5)]},{['MajorAxisLength = ' num2str(temp6)]},{['MinorAxisLength = ' num2str(temp7)]},...
    {['Orientation = ' num2str(temp8)]},{['Perimeter = ' num2str(temp9)]},{['Solidity = ' num2str(temp10)]}];
for ii=1:10
    label_str2{ii} = [num2str(names{ii},'%0.2f') '%'];end;
annot=imread('annot.jpg');
position = [0 500 100 100;0 50 100 100;0 100 100 100;0 150 100 100;0 200 100 100;0 250 100 100;0 300 100 100;0 350 100 100;0 400 100 100;0 450 100 100];
RGB = insertObjectAnnotation(annot,'rectangle',position,label_str2,...
    'Color','green','TextBoxOpacity',0.9,'FontSize',25);
imshow(RGB);

% Plots
figure;
subplot(2,3,1)
imshow(img);title('Original');
subplot(2,3,2)
imshow(gray,[]);title('Gray');
subplot(2,3,3)
imshow(newgray,[]);title('Processed Gray');
subplot(2,3,4)
imshow(OtsuSeg);title('Otsu Segmentation');
subplot(2,3,5)
imshow(label2rgb(L, @jet, [.9 .5 .5]));title('Region Boundaries');hold on;
imshow(newgray,[]);hold on;
for k = 1:length(B)
boundary = B{k};plot(boundary(:,2), boundary(:,1), 'g', 'LineWidth', 2);end;
subplot(2,3,6)
imshow(imfuse(RGB1,newgray));hold on;
for k = 1:length(B)
boundary = B{k};
plot(boundary(:,2), boundary(:,1), 'g', 'LineWidth', 2);
end;title('Detected Fruit');hold off;



