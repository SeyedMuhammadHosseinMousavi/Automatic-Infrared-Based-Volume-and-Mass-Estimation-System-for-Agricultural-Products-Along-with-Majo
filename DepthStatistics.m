% Image reading
clear;
img=imread('c.png');

% Extracting features of new test data
winsize=19;
tmp=lpq(img,winsize);
Testdata=tmp;
%Test new data with trained model
load('KNNDepthNewData');
yfit = trainedModel.predictFcn(Testdata);
if yfit == 1
yfitname='Carrot'
elseif yfit == 2
yfitname='Garlic'
elseif yfit == 3
yfitname='Potato'
elseif yfit == 4
yfitname='Quince'
end;

% Thickness or Height (distance between top of object and ground) 
sizeimg=size(img);
sizeimg=sizeimg(1,1)/2;
newimg=img(32:200,32:200);
top=img(sizeimg,sizeimg);
surface=max(max(img));
Thickness=surface-top; % This value is in millimetre

% Mesh plot
s=meshz(double(imcomplement(newimg)));
s.EdgeColor = 'k';

% Volume is sum of prisms
f2 = figure;
m = surf(newimg);
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
thresh = multithresh(newimg,1);
seg_I = imquantize(newimg,thresh);

% SurfaceArea Distance around the boundary of the region 
SurfaceArea = regionprops3(seg_I,"SurfaceArea");
SurfaceArea = SurfaceArea{:,:}

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








