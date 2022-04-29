clear;
%% Getting Input

camera = videoinput('kinect',2);
net=load('depthstream.mat');
net=net.netmacro;
inputSize = net.Layers(1).InputSize(1:2);
%
ClassNumber=4; % Number of Categories

%% Start Sensor 
h = figure;
h.Position(3) = 2*h.Position(3);
ax1 = subplot(2,2,1);
ax2 = subplot(2,2,2);
ax3 = subplot(2,2,3);
ax4 = subplot(2,2,4);
% In the left subplot, display the image and classification together.
im = getsnapshot(camera);
imagesc(ax1,im);
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
% Continuously display and classify images together with a histogram of the top five predictions.
while ishandle(h)
% Display and classify the image
im = getsnapshot(camera);
imagesc(ax1,im)
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
mesh(ax3,im');
view(ax3,[180 90]);
imnew=imadjust(im);

% Thickness or Height (distance between top of object and ground) 
sizeimg=size(imnew);
sizeimg=sizeimg(1,1)/2;
newimg=imnew(32:200,32:200);
top=imnew(sizeimg,sizeimg);
surface=max(max(imnew));
Thickness=surface-top; % This value is in millimetre

% Volume is sum of prisms
f2 = figure;
m = surf(imnew);
vol=m.FaceNormals;
Volume=sum(sum(sum(vol)))/10;
close(f2);

% Mass = Density * Volume
% Carrot density is 1.40 g/cm3
% Garlic density is 0.47 g/cm3
% Potato density is 0.63 g/cm3
% Quince density is 0.91 g/cm3
Mass = 0.63 * Volume;
% Region Properties
thresh = multithresh(imnew,1);
seg_I = imquantize(imnew,thresh);
% SurfaceArea Distance around the boundary of the region 
SurfaceArea = regionprops3(seg_I,"SurfaceArea");
SurfaceArea = SurfaceArea{:,:};

RP = regionprops(seg_I,'Area','ConvexArea','ConvexHull',...
'MajorAxisLength','MinorAxisLength','Solidity');
temp1=RP.Area;   disp(['Area :   ' num2str(temp1)]);
disp(['Surface Area :   ' num2str(SurfaceArea(1,1))]);
temp2=RP.ConvexArea;   disp(['ConvexArea :   ' num2str(temp2)]);
% temp3=RP.ConvexHull;   disp(['ConvexHull :   ' num2str(temp3)]);
temp5=RP.MajorAxisLength;   disp(['MajorAxisLength :   ' num2str(temp5)]);
temp6=RP.MinorAxisLength;   disp(['MinorAxisLength :   ' num2str(temp6)]);
temp7=RP.Solidity;   disp(['Solidity :   ' num2str(temp7)]);
temp8=Thickness;   disp(['Thickness In Millimetre :   ' num2str(temp8)]);
temp9=Volume;   disp(['Volume In Milliliter :   ' num2str(temp9)]);
temp10=Mass;   disp(['Mass in Gram :   ' num2str(temp10)]);
end

%% Termination
% In order to close the Kinect sensor
% clear('camera');



