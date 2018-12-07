close all; clear; clc;
% 트레이닝

%% 디렉토리 내 폴더명 인덱싱
MyLabel = dir([cd, '\DigitDataset']);
MyLabel = {MyLabel.name};
MyLabel(1:2) = []; % 첫 2개는 .이랑 ..임.

%% 기본 설정
digitDatasetPath = 'D:\Users\LJM\Documents\MATLAB\Machine Learning\My_ML\DigitDataset';
imds = imageDatastore(digitDatasetPath, 'IncludeSubfolders',true, 'LabelSource','foldernames');

numTrainFiles = 0.99; % 0.95 : 각각 1000개 중 950개 트레이닝, 나머지는 확인용으로 구분
[imdsTrain,imdsValidation] = splitEachLabel(imds,numTrainFiles,'randomize');

%% CNN용 설정
layers = [
    imageInputLayer([28 28 1])
    
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
    
    fullyConnectedLayer( length(MyLabel) ) %구분할 개수(폴더 수)
    softmaxLayer
    classificationLayer];

options = trainingOptions('sgdm', ...
    'InitialLearnRate',1e-3, ...
    'MiniBatchSize',128, ...
    'MaxEpochs',30, ...
    'LearnRateSchedule','piecewise', ...
    'LearnRateDropFactor',0.1, ...
    'LearnRateDropPeriod',20, ...
    'Shuffle','every-epoch', ...
    'ValidationData',imdsValidation, ...
    'ValidationFrequency',30, ...
    'Verbose',false, ...
    'Plots','training-progress');

%% 트레이닝 시작
net = trainNetwork(imdsTrain,layers,options);
% 참고로 이거 객체라서, net.Layer를 layers로 꺼내오면, layers(13)=fullyConnectedLayer(5) 이런식으로 수정 가능함
% 이걸로 추가학습 가능

%% 저장
save('test.mat', 'net', '-append')
save('test.mat', 'MyLabel', '-append')