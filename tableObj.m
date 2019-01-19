classdef tableObj < handle
% ������ ������ ��ü�� ����ϱ� ���� Ŭ����
    properties (SetAccess = {?FigPopup})
    % ������ : FigPopup Ŭ���������� ���� �����ϵ��� ����
        List table          % table���·� ������ ����Ʈ
    end
    properties (Hidden, SetAccess = immutable)
    % UI��ü ��� : set�� �����ڿ����� ��ɵǵ��� ����
        Popup FigPopup      % �˾�Ŭ���� �׳� �����ص�
    end
    properties (Access = 'private')
    % Ʈ���̴� ������
        idxChanged          % ���� �̷� : TrainImgData������ �ε��� ����
        TrainImgData        % Ʈ���̴׿� ����� ������
        TrainCategory       % Ʈ���̴׿� ����� ī�װ�
        TrainLayers         % Ʈ���̴׿� ����� ���̾�
        TrainOptions        % Ʈ���̴׿� ����� �ɼ�
    end
    methods
        function this = tableObj(cellobj, popup, netLayers, opt)
        %cell�� �����͸� �Է¹޾� ������ ��Ʈ�� ����
        % cellobj : (cell) {�׸�, ��(�±�),��(�ε���), ����ũ��, ������ġ}
        % popup : (FigPopup) �˾�UI ���� ��ü
        % netLayers : (Layer) SeriesNetwork.Layers�� ������ ��
        % opt : (TrainingOptions[�Ʒø�])
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
                addlistener(popup, 'ButtonEvt', @this.replaceTag); % ��ưŬ�� ������
                addlistener(this, 'Reset', @this.replaceTag); % ���� ������
                notify(this, 'Reset')
            else
                error('���� 5�� �迭�� �ʿ���')
            end
        end
        
        function reTraining(this)
        % �米�� �Լ�
            disp('������Ʈ ����')
            net = trainNetwork(this.TrainImgData, this.TrainCategory, this.TrainLayers, this.TrainOptions);
            save('test.mat', 'net', '-append')
            this.TrainLayers = net.Layers;
            this.TrainImgData = [];
            this.TrainCategory = [];
            disp('������Ʈ �Ϸ�')
            notify(this, 'Reset')
        end
    end
    methods (Access = private)
    %% �̺�Ʈ
        function replaceTag(this, toggleObj, evt)
        % �˾�â���� �ٲ޹�ư ������ �� ȣ�� or ���� �ߵ��� ȣ��
            persistent idx % �Ź� length(find) ����ϱ� �Ⱦ ����ϴ� ���Ӻ���. �� �� �ٲ���� ����
            if strcmp(evt.EventName,'Reset')
                idx = 0;
            elseif isa(toggleObj, 'FigPopup')
                targetNum = toggleObj.nowTarget;
                select = toggleObj.CharacterList.Value;
                category = this.TrainLayers(end).Classes( select );
                this.List.Text_Tag{targetNum} = char(category);
                this.List.Text_Index(targetNum) = select;
                if this.idxChanged(targetNum)==0 % �ε����� �������� ���� ��, ���� �־�
                    this.TrainImgData...
                        = cat(4, this.TrainImgData, this.List.Image{targetNum} );
                    this.TrainCategory...
                        = cat(1, this.TrainCategory, category );
                    idx = idx+1;
                    this.idxChanged(targetNum) = idx;
                else % ������ �ִ��� ������
                    this.TrainImgData(:,:,:,this.idxChanged(targetNum))...
                        = this.List.Image{targetNum};
                    this.TrainCategory(this.idxChanged(targetNum))...
                        = category;
                end
            end
        end
    end
    events
        Reset % �ʱ�ȭ �Ǵ� �米�� ���� �ߵ�
    end
end

