close all; clear; clc;
% Ʈ���̴�

%% ���丮 �� ������ �ε���
MyLabel = dir([cd, '\DigitDataset']);
MyLabel = {MyLabel.name};
MyLabel(1:2) = []; % ù 2���� .�̶� ..��.

%% �⺻ ����
digitDatasetPath = 'D:\Users\LJM\Documents\MATLAB\Machine Learning\My_ML\DigitDataset';
imds = imageDatastore(digitDatasetPath, 'IncludeSubfolders',true, 'LabelSource','foldernames');

numTrainFiles = 0.99; % 0.95 : ���� 1000�� �� 950�� Ʈ���̴�, �������� Ȯ�ο����� ����
[imdsTrain,imdsValidation] = splitEachLabel(imds,numTrainFiles,'randomize');

%% CNN�� ����
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
    
    fullyConnectedLayer( length(MyLabel) ) %������ ����(���� ��)
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

%% Ʈ���̴� ����
net = trainNetwork(imdsTrain,layers,options);
% ����� �̰� ��ü��, net.Layer�� layers�� ��������, layers(13)=fullyConnectedLayer(5) �̷������� ���� ������
% �̰ɷ� �߰��н� ����

%% ����
save('test.mat', 'net', '-append')
save('test.mat', 'MyLabel', '-append')