classdef FigPopup < handle
%재교육 및 변수 공유를 위한 객체 클래스
% 
    properties (SetObservable, AbortSet = true, Hidden)
    % 관찰용 속성 목록 : 값이 바뀌면 속성 이름으로 event를 발생시킴
        nowTarget           % 현재 타겟의 라벨값 double
        bolLock = false     % 잠금여부 Logical
    end
    properties (SetAccess = immutable)
    % UI객체 목록 : set이 생성자에서만 기능되도록 설정
        TableObj tableObj   % TableObj.List.{Image,Text_Tag,Text_Index,ImageSize,Position}
        figureMain          % 원본 이미지 Figure
        figurePopup         % 타겟 이미지 Figure
        PictureAxes         % 타겟 이미지 Axes
        imgTarget           % 타겟 이미지 Image
        UpdateButten        % 업데이트 버튼 UIControl
        CharacterList       % 글자 리스트 UIControl
        Text                % 글자 화면표시 UIControl
    end
    
    methods (Hidden)
    %% 공통 함수
        function this = FigPopup(cellobj, nim, fig, netLayers, opt)
        %초기화 함수
        % cellobj : (cell) {그림, 값(태그),값(인덱스), 원본크기, 원본위치}
        % nim : (double) 라벨링된 이미지 데이터
        % fig : (figure) 원본 이미지 플로팅된 창
        % netLayers : (Layer) SeriesNetwork.Layers만 있으면 됨
        % opt : (TrainingOptions[훈련모델])
            %%% 저장
            this.TableObj = tableObj(cellobj, this, netLayers, opt);
            this.figureMain = fig;
            %%% 생성
            this.figurePopup = figure(...
                                    'Name','Target',...
                                    'Color',[1 1 1],...
                                    'Units','pixels',...
                                    'NumberTitle','off', 'MenuBar','none', 'ToolBar','none');
            this.PictureAxes = axes('Parent',this.figurePopup);
            this.imgTarget = imshow(zeros(size(this.TableObj.List.Image{1}))); %!! 이상하게 이게 figure.Position에 영향을 주는듯?
            this.figurePopup.Position(3:4) = [200 250];
            this.UpdateButten = uicontrol(this.figurePopup,...
                                    'Style','pushbutton',...
                                    'BackgroundColor',[1 1 1],...
                                    'String',{'Change'},...
                                    'Position',[140 10 50 50], 'Units','pixels');
            this.CharacterList = uicontrol(this.figurePopup,...
                                    'Style','popupmenu',...
                                    'BackgroundColor',[1 1 1],...
                                    'String',cellstr(netLayers(end).Classes),...
                                    'Position',[25 15 100 20], 'Units','pixels');
            this.Text = uicontrol(this.figurePopup,...
                                    'Style','text',...
                                    'BackgroundColor',[1 1 1],...
                                    'String',{'가'},...
                                    'Position',[20 40 115 30], 'Units','pixels');
            %%% 속성
            this.PictureAxes.Units = 'pixels';
            this.PictureAxes.Position = [25 75 150 150];
            this.figureMain.WindowButtonMotionFcn = {@this.takeTxt, nim};
            this.figureMain.WindowButtonDownFcn = @this.lockTxt;
            this.figureMain.DeleteFcn = @(~,~) delete(this);
            this.figurePopup.DeleteFcn = @(~,~) delete(this);
            this.UpdateButten.Callback = {@this.replaceTag, netLayers(end).Classes};
            %%% 이벤트
            addlistener(this, 'nowTarget', 'PostSet', @FigPopup.updateNowTarget); % nowTarget 바뀐 이후에 콜백수행
            this.nowTarget = 1;
            addlistener(this, 'nowTarget', 'PreSet', @FigPopup.updatePastTarget); % nowTarget 바뀌기 직전에 콜백수행
        end
    %% 소멸자
        function delete(this)
        % 자체 소멸자 : figureMain에 설정한 속성을 다 없애고, figurePopup이랑 수명을 같이함
            this.figureMain.WindowButtonMotionFcn = '';
            this.figureMain.WindowButtonDownFcn = '';
            this.figureMain.DeleteFcn = '';
            close(this.figurePopup) % "유효하지 않은 Figure 핸들 오류"나 "DeleteFcn 무한루프" 안생기니까 안심
        end
    %% figureMain용 함수
        function takeTxt(this, figMain, ~, nim)
        %마우스 움직이는 동안 발동할 명령 : nowTarget을 변경함
        % figMain : 감시대상 figure
        % nim : (double) 라벨링된 이미지 데이터
            if ~this.bolLock
                P = figMain.Children(1).CurrentPoint(1, [2 1]);            % figMain에서 처음 생성한 axes(원본이미지)에서 마우스 좌표값 받기
                if all(0<P) && all(P<size(nim))                            % axes 크기 내부에 있는지 확인하기
                    P = round(P); lbl = nim(P(1), P(2));                   % nim에서 라벨 찾기 : P[열 행]을 [행 열]로 입력함에 주의
                    if lbl > 0 && lbl~=this.nowTarget
                        this.nowTarget = lbl;
                    end
                end
            end
        end
        function lockTxt(this, ~, ~)
        % 마우스 클릭할 때 발동할 명령
            this.bolLock = ~this.bolLock;
            % 잠금상태인 거 알기 쉽게 마우스 포인터 바꾸기
        end
    %% figurePopup용 함수
        function replaceTag(this, ~, ~, categ)
        %바꿈버튼 눌렀을 때 발동할 명령
        % categ : (categorical) 레이어에 포함된 class목록
            txt = char(categ( this.CharacterList.Value ));
            if ismember(txt, {'^','\'}) % 에러메시지 안내려고 하는 뻘짓거리ㅂㄷㅂㄷ
                this.figureMain.Children(1).Children(end-this.nowTarget).String...
                    = ['\',txt];
            else
                this.figureMain.Children(1).Children(end-this.nowTarget).String...
                    = txt;
            end
            this.Text.String = [this.Text.String, ' → ', txt];
            notify(this, 'ButtonEvt') % tableObj쪽 변경사항은 그쪽 클래스에서 처리하도록.
        end
    end
    
%% 이벤트
    methods (Static, Hidden)
        function updatePastTarget(~,eventData)
        %타게팅 끝난 대상을 기본상태로 되돌림
            this = eventData.AffectedObject;
            this.figureMain.Children(1).Children(end-this.nowTarget).Color = [1 0 0];
        end
        function updateNowTarget(~,eventData)
        %타게팅된 대상에 변화를 줌
            this = eventData.AffectedObject;
            this.figureMain.Children(1).Children(end-this.nowTarget).Color = [0 1 0];
            this.Text.String = this.TableObj.List.Text_Tag{this.nowTarget};
            this.CharacterList.Value = this.TableObj.List.Text_Index(this.nowTarget);
            this.imgTarget.CData = this.TableObj.List.Image{this.nowTarget};
        end
    end
    
    events
        ButtonEvt % 버튼동작 이벤트
    end
end

