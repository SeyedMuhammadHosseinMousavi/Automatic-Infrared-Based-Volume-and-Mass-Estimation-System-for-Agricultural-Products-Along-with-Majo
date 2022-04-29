
clear;

%% Getting Input

camera = videoinput('kinect',1);
net=load('colorstream.mat');
net=net.netmacro;
inputSize = net.Layers(1).InputSize(1:2);
%
ClassNumber=4; % Number of Categories
%
img=imread('a.jpg');
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
%% Start Sensor 
h = figure;
h.Position(3) = 2*h.Position(3);
ax1 = subplot(2,3,1);
ax2 = subplot(2,3,2);
ax3 = subplot(2,3,3);
ax4 = subplot(2,3,4);
ax5 = subplot(2,3,5);
ax6 = subplot(2,3,6);
% In the left subplot, display the image and classification together.
im = getsnapshot(camera);
imagesc(ax1,im)
im = imresize(im,inputSize);
[label,score] = classify(net,im);
title(ax1,{char(label),num2str(max(score),2)});
% Select the top five predictions by selecting the classes with the highest scores.
[~,idx] = sort(score,'descend');
idx = idx(ClassNumber:-1:1);
classes = net.Layers(end).Classes;
classNamesTop = string(classes(idx));
scoreTop = score(idx);

%% Continue
% Continuously display and classify images
% together with a histogram of the top five predictions.
while ishandle(h)
% Display and classify the image
im = getsnapshot(camera);
imagesc(ax1,im);
im = imresize(im,inputSize);
[label,score] = classify(net,im);
title(ax1,{char(label),num2str(max(score),2)},'FontSize',20,'FontWeight','bold','Color','r');
% Select the top five predictions
[~,idx] = sort(score,'descend');
idx = idx(ClassNumber:-1:1);
scoreTop = score(idx);
classNamesTop = string(classes(idx));
% Plot the histogram
barh(ax2,scoreTop)
title(ax2,'Recognition')
xlabel(ax2,'Probability','FontSize',17)
xlim(ax2,[0 1])
yticklabels(ax2,classNamesTop)
ax2.YAxisLocation = 'right';
drawnow
% Gray image
image(ax3,rgb2gray(im));
% Processed image
imgray=rgb2gray(im);
for i=1:256
for j=1:256
if imgray(i,j)>100
newim(i,j)=imgray(i,j);
else
newim(i,j)=0;
end;end;end;
image(ax4,newim);
% Otsu segmented
thresh = multithresh(imgray,1);
seg_I = imquantize(imgray,thresh);
OtsuSeg = label2rgb(seg_I); 
image(ax5,OtsuSeg);

% Trace region boundaries
[B,L,N,A] = bwboundaries(imgray);
% Extracting Bounding Box position
s = regionprops(L,'BoundingBox');
% Adding Object Annotation Text
position = [s(1)];
position=position.BoundingBox;
label_str = ['Fruit: ' num2str(yfitname)];
RGB1 = insertObjectAnnotation(imgray,'rectangle',position,label_str,...
    'Color','cyan','TextBoxOpacity',0.9,'FontSize',18);
% image(ax6,RGB1);

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
image(ax6,RGB);
end
%% Termination
% In order to close the Kinect sensor
% clear('camera');



