
%% Fruit Kinect Code 

clear;
clc;
close all;
warning ('off');

%% Data Reading and Pre-Processing
path='DepthDB';
fileinfo = dir(fullfile(path,'*.png'));
filesnumber=size(fileinfo);
for i = 1 : filesnumber(1,1)
images{i} = imread(fullfile(path,fileinfo(i).name));
disp(['Loading image No :   ' num2str(i) ]);
end;

%% Feature Extraction
% Extract SURF Features 
% imset = imageSet('DepthCNN','recursive'); 
% % Create a bag-of-features from the image database
% bag = bagOfFeatures(imset,'VocabularySize',40,'PointSelection','Detector');
% % Encode the images as new features
% SURF = encode(bag,imset);

%-------------------------------------------------
% Extract LPQ Features 
% More value for winsize, better result
winsize=19;
for i = 1 : filesnumber(1,1)
tmp{i}=lpq(images{i},winsize);
disp(['Extract LPQ :   ' num2str(i) ]);end;
for i = 1 : filesnumber(1,1)
LPQ(i,:)=tmp{i};end;

% Combining Feature Matrixes
FinalReady=LPQ;
% Labeling for Supervised Learning
sizefinal=size(FinalReady);
sizefinal=sizefinal(1,2);
FinalReady(1:200,sizefinal+1)=1;
FinalReady(201:400,sizefinal+1)=2;
FinalReady(401:600,sizefinal+1)=3;
FinalReady(601:800,sizefinal+1)=4;

%% KNN Classification
lblknn=FinalReady(:,end);
dataknn=FinalReady(:,1:end-1);
Mdl = fitcknn(dataknn,lblknn,'NumNeighbors',5,'Standardize',1)
rng(1); % For reproducibility
knndat = crossval(Mdl);
classError = kfoldLoss(knndat);
Lknn = resubLoss(Mdl,'LossFun','classiferror'); 
KNNAccuracy = 1 - kfoldLoss(knndat, 'LossFun', 'ClassifError');
% Predict the labels of the training data.
predictedknn = resubPredict(Mdl);
sizenet=size(FinalReady);
sizenet=sizenet(1,1);
ct=0;
for i = 1 : sizenet(1,1)
if lblknn(i) ~= predictedknn(i)
    ct=ct+1;
end;end;
% Compute Accuracy
finsvm=ct*100/ sizenet;
SVMAccuracy=(100-finsvm);
% Confusion Matrix
figure
cmknn = confusionchart(lblknn,predictedknn);
cmknn.Title = ['KNN Classification =  ' num2str(SVMAccuracy) '%'];
cmknn.RowSummary = 'row-normalized';
cmknn.ColumnSummary = 'column-normalized';
% ROC
[~,scoreknn] = resubPredict(Mdl);
diffscoreknn = scoreknn(:,2) - max(scoreknn(:,1),scoreknn(:,3));
[Xknn,Yknn,T,~,OPTROCPTknn,suby,subnames] = perfcurve(lblknn,diffscoreknn,1);
figure;
plot(Xknn,Yknn)
hold on
plot(OPTROCPTknn(1),OPTROCPTknn(2),'ro')
xlabel('False positive rate') 
ylabel('True positive rate')
title('ROC Curve for KNN')
hold off
%

%% Deep Neural Network
% CNN
deepDatasetPath = fullfile('DepthCNN');
imds = imageDatastore(deepDatasetPath, ...
'IncludeSubfolders',true, ...
'LabelSource','foldernames');
% Number of training (less than number of each class)
numTrainFiles = 160;
[imdsTrain,imdsValidation] = splitEachLabel(imds,numTrainFiles,'randomize');
layers = [
% Input image size for instance: 512 512 3
imageInputLayer([256 256 1])
convolution2dLayer(3,8,'Padding','same')
batchNormalizationLayer
reluLayer
maxPooling2dLayer(2,'Stride',2)
convolution2dLayer(3,16,'Padding','same')
batchNormalizationLayer
reluLayer
maxPooling2dLayer(2,'Stride',2)
convolution2dLayer(3,32,'Padding','same')
batchNormalizationLayer
reluLayer
% Number of classes
fullyConnectedLayer(4)
softmaxLayer
classificationLayer];
options = trainingOptions('sgdm', ...
'InitialLearnRate',0.001, ...
'MaxEpochs',15, ...
'MiniBatchSize',32, ...
'Shuffle','every-epoch', ...
'ValidationData',imdsValidation, ...
'ValidationFrequency',9, ...
'Verbose',false, ...
'Plots','training-progress');
netmacro = trainNetwork(imdsTrain,layers,options);
YPred = classify(netmacro,imdsValidation);
YValidation = imdsValidation.Labels;
accuracy = sum(YPred == YValidation)/numel(YValidation) *100;
disp(['CNN Macro Recognition Accuracy Is =   ' num2str(accuracy) ]);

