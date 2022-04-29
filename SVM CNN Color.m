
%% Fruit Kinect Code 

clear;
clc;
close all;
warning ('off');

%% Data Reading and Pre-Processing
path='ColorDB';
fileinfo = dir(fullfile(path,'*.jpg'));
filesnumber=size(fileinfo);
for i = 1 : filesnumber(1,1)
images{i} = imread(fullfile(path,fileinfo(i).name));
disp(['Loading image No :   ' num2str(i) ]);
end;

%% Feature Extraction
% Extract SURF Features 
imset = imageSet('ColorCNN','recursive'); 
% Create a bag-of-features from the image database
bag = bagOfFeatures(imset,'VocabularySize',20,'PointSelection','Detector');
% Encode the images as new features
SURF = encode(bag,imset);
%-------------------------------------------------
% Extract HOG Features 
for i = 1 : filesnumber(1,1)
% The less cell size the more accuracy 
hog{i} = extractHOGFeatures(images{i},'CellSize',[128 128]);
disp(['Extract HOG :   ' num2str(i) ]);end;
for i = 1 : filesnumber(1,1)
HOG(i,:)=hog{i};
disp(['HOG To Matrix :   ' num2str(i) ]);end;
% Combining Feature Matrixes
FinalReady=[HOG SURF];
% Labeling for Supervised Learning
sizefinal=size(FinalReady);
sizefinal=sizefinal(1,2);
FinalReady(1:200,sizefinal+1)=1;
FinalReady(201:400,sizefinal+1)=2;
FinalReady(401:600,sizefinal+1)=3;
FinalReady(601:800,sizefinal+1)=4;

%% SVM Classification
lblknn=FinalReady(:,end);
dataknn=FinalReady(:,1:end-1);
tsvm = templateSVM('KernelFunction','polynomial');
svmclass = fitcecoc(dataknn,lblknn,'Learners',tsvm);
svmerror = resubLoss(svmclass);
CVMdl = crossval(svmclass);
genError = kfoldLoss(CVMdl);
% Compute validation accuracy
SVMAccuracy = 1 - kfoldLoss(CVMdl, 'LossFun', 'ClassifError');
% Predict the labels of the training data.
predictedsvm = resubPredict(svmclass);
sizenet=size(FinalReady);
sizenet=sizenet(1,1);
ct=0;
for i = 1 : sizenet(1,1)
if lblknn(i) ~= predictedsvm(i)
    ct=ct+1;
end;
end;
% Compute Accuracy
finsvm=ct*100/ sizenet;
SVMAccuracy=(100-finsvm);
% Plot Confusion Matrix
figure
cmsvm = confusionchart(lblknn,predictedsvm);
cmsvm.Title = ['SVM Classification =  ' num2str(SVMAccuracy) '%'];
cmsvm.RowSummary = 'row-normalized';
cmsvm.ColumnSummary = 'column-normalized';
% ROC
[~,scoresvm] = resubPredict(svmclass);
diffscoresvm = scoresvm(:,2) - max(scoresvm(:,1),scoresvm(:,3));
[Xsvm,Ysvm,T,~,OPTROCPTsvm,suby,subnames] = perfcurve(lblknn,diffscoresvm,1);
% ROC curve plot
figure;
plot(Xsvm,Ysvm)
hold on
plot(OPTROCPTsvm(1),OPTROCPTsvm(2),'ro')
xlabel('False positive rate') 
ylabel('True positive rate')
title('ROC Curve for SVM')
hold off

%% Deep Neural Network
% CNN
deepDatasetPath = fullfile('ColorCNN');
imds = imageDatastore(deepDatasetPath, ...
'IncludeSubfolders',true, ...
'LabelSource','foldernames');
% Number of training (less than number of each class)
numTrainFiles = 160;
[imdsTrain,imdsValidation] = splitEachLabel(imds,numTrainFiles,'randomize');
layers = [
% Input image size for instance: 512 512 3
imageInputLayer([256 256 3])
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
'InitialLearnRate',0.01, ...
'MaxEpochs',10, ...
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

