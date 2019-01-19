classdef tableObj < handle
% 정리된 파일을 객체로 사용하기 위한 클래스
    properties (SetAccess = {?FigPopup})
    % 데이터 : FigPopup 클래스에서만 수정 가능하도록 설정
        List table          % table형태로 정리한 리스트
    end
    properties (Hidden, SetAccess = immutable)
    % UI객체 목록 : set이 생성자에서만 기능되도록 설정
        Popup FigPopup      % 팝업클래스 그냥 저장해둠
    end
    properties (Access = 'private')
    % 트레이닝 데이터
        idxChanged          % 수정 이력 : TrainImgData에서의 인덱스 저장
        TrainImgData        % 트레이닝에 사용할 데이터
        TrainCategory       % 트레이닝에 사용할 카테고리
        TrainLayers         % 트레이닝에 사용할 레이어
        TrainOptions        % 트레이닝에 사용할 옵션
    end
    methods
        function this = tableObj(cellobj, popup, netLayers, opt)
        %cell형 데이터를 입력받아 데이터 세트로 만듦
        % cellobj : (cell) {그림, 값(태그),값(인덱스), 원본크기, 원본위치}
        % popup : (FigPopup) 팝업UI 관리 객체
        % netLayers : (Layer) SeriesNetwork.Layers만 있으면 됨
        % opt : (TrainingOptions[훈련모델])
            if size(cellobj,2)==5
                this.List = cell2table(cellobj,...
                      'VariableNames',{'Image','Text_Tag','Text_Index','ImageSize','Position'});
                this.Popup = popup;
                this.TrainLayers = netLayers;
                this.TrainOptions = trainingOptions('sgdm',...
                    'InitialLearnRate', opt.InitialLearnRate,...
                    'LearnRateSchedule', opt.LearnRateScheduleSettings.Method,...
                    'LearnRateDropFactor', opt.LearnRateScheduleSettings.DropRateFactor,...
                    'LearnRateDropPeriod', opt.LearnRateScheduleSettings.DropPeriod,...
                    'MaxEpochs', opt.MaxEpochs,...
                    'MiniBatchSize', opt.MiniBatchSize,...
                    'Verbose', opt.Verbose,...
                    'VerboseFrequency', opt.VerboseFrequency,...
                    'Shuffle', opt.Shuffle);
                this.idxChanged = zeros(size(this.List, 1), 1);
                addlistener(popup, 'ButtonEvt', @this.replaceTag); % 버튼클릭 감지용
                addlistener(this, 'Reset', @this.replaceTag); % 리셋 감지용
                notify(this, 'Reset')
            else
                error('가로 5줄 배열이 필요함')
            end
        end
        
        function reTraining(this)
        % 재교육 함수
            disp('업데이트 시작')
            net = trainNetwork(this.TrainImgData, this.TrainCategory, this.TrainLayers, this.TrainOptions);
            save('test.mat', 'net', '-append')
            this.TrainLayers = net.Layers;
            this.TrainImgData = [];
            this.TrainCategory = [];
            disp('업데이트 완료')
            notify(this, 'Reset')
        end
    end
    methods (Access = private)
    %% 이벤트
        function replaceTag(this, toggleObj, evt)
        % 팝업창에서 바꿈버튼 눌렀을 때 호출 or 리셋 발동시 호출
            persistent idx % 매번 length(find) 계산하기 싫어서 사용하는 영속변수. 몇 개 바꿨는지 저장
            if strcmp(evt.EventName,'Reset')
                idx = 0;
            elseif isa(toggleObj, 'FigPopup')
                targetNum = toggleObj.nowTarget;
                select = toggleObj.CharacterList.Value;
                category = this.TrainLayers(end).Classes( select );
                this.List.Text_Tag{targetNum} = char(category);
                this.List.Text_Index(targetNum) = select;
                if this.idxChanged(targetNum)==0 % 인덱스가 존재하지 않을 때, 새로 넣어
                    this.TrainImgData...
                        = cat(4, this.TrainImgData, this.List.Image{targetNum} );
                    this.TrainCategory...
                        = cat(1, this.TrainCategory, category );
                    idx = idx+1;
                    this.idxChanged(targetNum) = idx;
                else % 기존에 있던거 수정해
                    this.TrainImgData(:,:,:,this.idxChanged(targetNum))...
                        = this.List.Image{targetNum};
                    this.TrainCategory(this.idxChanged(targetNum))...
                        = category;
                end
            end
        end
    end
    events
        Reset % 초기화 또는 재교육 직후 발동
    end
end

