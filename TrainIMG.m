close all; clear; clc;
% <*** �⺻ Ʈ���̴� ***>

%% ���丮 �� ������ �ε���, �⺻ ����
imds = imageDatastore([cd,'\DigitDataset'],...
                      'IncludeSubfolders',true,...
                      'LabelSource','foldernames');
% Count = countEachLabel(imds)

MyLabel = dir([cd, '\DigitDataset']);
MyLabel = {MyLabel.name};
MyLabel(1:2) = []; % ù 2���� .�̶� ..��.

%%% �� ����
folderChr = ['��������������������',... % ����Ǵ� �����̸�
             'ABCDEFGHIJKLMNOPQRSTUVWXYZ',...
             '���������������������������������',...
             '�ǣ��������������������¡áġšӡԡ����ޢ�������������',...
             '���¥åĥťƥǥȥɥʥ˥̥ͥΥϥХ�?�ҥӥԥե֥ץ�',...
             '������������������?������������'];
wordChr = ['0123456789',... % �����̸��� �����ϴ� �ؽ�Ʈ : ��ġ�� �� ���ֵ� �������
           'ABCDEFGHIJKLMNOPQRSTUVWXYZ',...
           'abcdefghijklmnopqrstuvwxyz',...
           ',+-<=>������/���¡áġšӡԡ����^��\~:|()',...
           '���¥åĥťƥǥȥɥʥ˥̥ͥΥϥХ�?�ҥӥԥե֥ץ�',...
           '������������������?������������'];
idx = ismember(folderChr, char(MyLabel));
folderChr = folderChr(idx); wordChr = wordChr(idx); % ���� ���� �߿� �����ϴ� ���ڸ�
idx = ~ismember(wordChr, folderChr); % ������� ���� �ؽ�Ʈ�� ���� ��ġ�� �ʴ� ���� �߸���
imds.Labels = renamecats(imds.Labels, cellstr(folderChr(idx).'),cellstr(wordChr(idx).')); % �� �ٲٱ�

%%% ������ ������
numTrainFiles = 0.8; % 0.8���� ��ŭ�� Ʈ���̴׿� ���, �������� Ȯ�ο����� ����
[imdsTrain,imdsValidation] = splitEachLabel(imds,numTrainFiles,'randomize');

%% CNN�� ����
layers = [
    imageInputLayer([56 56 1], 'Name','input')
        % 2���� ������� ���̾� #1
    convolution2dLayer(3,16,'Padding','same', 'Name','convInp')
    batchNormalizationLayer('Name','BNInp')
    reluLayer('Name','reluInp')
    
    maxPooling2dLayer(2,'Stride',2, 'Name','maxPoolInp')
    dropoutLayer(0.2, 'Name','dropInp')
    
        % 2���� ������� ���̾� #2
    convolution2dLayer(3,8,'Padding','same', 'Name','conv1')
    batchNormalizationLayer('Name','BN1')
    reluLayer('Name','relu1')
    
    maxPooling2dLayer(2,'Stride',2, 'Name','maxPool1')
    
        % 2���� ������� ���̾� #3
    convolution2dLayer(3,8,'Padding','same', 'Name','conv2')
    batchNormalizationLayer('Name','BN2')
    reluLayer('Name','relu2')
    
    averagePooling2dLayer(8, 'Name','globalPool')
    
        % ������ ����
    fullyConnectedLayer( length(MyLabel), 'Name','fcFinal') %������ ����(���� ��)
    softmaxLayer('Name','softmax')
    classificationLayer('Name','output')];

options = trainingOptions('sgdm', ... % ���� : sgdm, rmsprop, adam ��
    'ExecutionEnvironment','parallel', ... % ��ƼCPU ������ GPU ���
    'InitialLearnRate',1e-3, ...
    'MiniBatchSize',128, ...
    'MaxEpochs',15, ...
    'LearnRateSchedule','piecewise', ...
    'LearnRateDropFactor',0.1, ...
    'LearnRateDropPeriod',20, ...
    'Shuffle','every-epoch', ...
    'ValidationData',imdsValidation, ...
    'ValidationFrequency',30, ...
    'Verbose',false, ...
    'VerboseFrequency',floor( size(imdsTrain.Files,1)/128 ), ...
    'Plots','training-progress');

%% Ʈ���̴� ����
% �ܼ� Network���� SeriesNetwork�� Ȯ�强�� ���Ƽ� �̰� �����
net = trainNetwork(imdsTrain,layers,options);
% analyzeNetwork(net)

%% ����
if isfile('test.mat')
    save('test.mat', 'net','options', '-append')
else
    save('test.mat', 'net','options')
end