close all; clear; clc;
% <*** 기본 트레이닝 ***>

%% 디렉토리 내 폴더명 인덱싱, 기본 설정
imds = imageDatastore([cd,'\DigitDataset'],...
                      'IncludeSubfolders',true,...
                      'LabelSource','foldernames');
% Count = countEachLabel(imds)

MyLabel = dir([cd, '\DigitDataset']);
MyLabel = {MyLabel.name};
MyLabel(1:2) = []; % 첫 2개는 .이랑 ..임.

%%% 라벨 수정
folderChr = ['０１２３４５６７８９',... % 예상되는 폴더이름
             'ABCDEFGHIJKLMNOPQRSTUVWXYZ',...
             'ａｂｃｄｅｆｇｈｉｊｋｌｍｎｏｐｑｒｓｔｕｖｗｘｙｚ',...
             '′＋－＜＝＞±×÷／≠≤≥∞∴∂∇√∝∵∫＾∑＼∼ː│（）',...
             'ΑΒΓΔΕΖΗΘΙΚΛΜΝΞΟΠΡ?ΣΤΥΦΧΨΩ',...
             'αβγδεζηθικλμνξοπρ?στυφχψω'];
wordChr = ['0123456789',... % 폴더이름에 대응하는 텍스트 : 겹치는 건 없애도 상관없음
           'ABCDEFGHIJKLMNOPQRSTUVWXYZ',...
           'abcdefghijklmnopqrstuvwxyz',...
           ',+-<=>±×÷/≠≤≥∞∴∂∇√∝∵∫^Σ\~:|()',...
           'ΑΒΓΔΕΖΗΘΙΚΛΜΝΞΟΠΡ?ΣΤΥΦΧΨΩ',...
           'αβγδεζηθικλμνξοπρ?στυφχψω'];
idx = ismember(folderChr, char(MyLabel));
folderChr = folderChr(idx); wordChr = wordChr(idx); % 현재 폴더 중에 존재하는 글자만
idx = ~ismember(wordChr, folderChr); % 폴더명과 실제 텍스트가 서로 겹치지 않는 범위 추리기
imds.Labels = renamecats(imds.Labels, cellstr(folderChr(idx).'),cellstr(wordChr(idx).')); % 라벨 바꾸기

%%% 데이터 나누기
numTrainFiles = 0.8; % 0.8비율 만큼만 트레이닝에 사용, 나머지는 확인용으로 구분
[imdsTrain,imdsValidation] = splitEachLabel(imds,numTrainFiles,'randomize');

%% CNN용 설정
layers = [
    imageInputLayer([56 56 1], 'Name','input')
        % 2차원 컨볼루션 레이어 #1
    convolution2dLayer(3,16,'Padding','same', 'Name','convInp')
    batchNormalizationLayer('Name','BNInp')
    reluLayer('Name','reluInp')
    
    maxPooling2dLayer(2,'Stride',2, 'Name','maxPoolInp')
    dropoutLayer(0.2, 'Name','dropInp')
    
        % 2차원 컨볼루션 레이어 #2
    convolution2dLayer(3,8,'Padding','same', 'Name','conv1')
    batchNormalizationLayer('Name','BN1')
    reluLayer('Name','relu1')
    
    maxPooling2dLayer(2,'Stride',2, 'Name','maxPool1')
    
        % 2차원 컨볼루션 레이어 #3
    convolution2dLayer(3,8,'Padding','same', 'Name','conv2')
    batchNormalizationLayer('Name','BN2')
    reluLayer('Name','relu2')
    
    averagePooling2dLayer(8, 'Name','globalPool')
    
        % 마무리 연결
    fullyConnectedLayer( length(MyLabel), 'Name','fcFinal') %구분할 개수(폴더 수)
    softmaxLayer('Name','softmax')
    classificationLayer('Name','output')];

options = trainingOptions('sgdm', ... % 종류 : sgdm, rmsprop, adam 등
    'ExecutionEnvironment','parallel', ... % 멀티CPU 내지는 GPU 허용
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

%% 트레이닝 시작
% 단순 Network보다 SeriesNetwork이 확장성이 좋아서 이걸 사용함
net = trainNetwork(imdsTrain,layers,options);
% analyzeNetwork(net)

%% 저장
if isfile('test.mat')
    save('test.mat', 'net','options', '-append')
else
    save('test.mat', 'net','options')
end