classdef FigPopup < handle
%�米�� �� ���� ������ ���� ��ü Ŭ����
% 
    properties (SetObservable, AbortSet = true, Hidden)
    % ������ �Ӽ� ��� : ���� �ٲ�� �Ӽ� �̸����� event�� �߻���Ŵ
        nowTarget           % ���� Ÿ���� �󺧰� double
        bolLock = false     % ��ݿ��� Logical
    end
    properties (SetAccess = immutable)
    % UI��ü ��� : set�� �����ڿ����� ��ɵǵ��� ����
        TableObj tableObj   % TableObj.List.{Image,Text_Tag,Text_Index,ImageSize,Position}
        figureMain          % ���� �̹��� Figure
        figurePopup         % Ÿ�� �̹��� Figure
        PictureAxes         % Ÿ�� �̹��� Axes
        imgTarget           % Ÿ�� �̹��� Image
        UpdateButten        % ������Ʈ ��ư UIControl
        CharacterList       % ���� ����Ʈ UIControl
        Text                % ���� ȭ��ǥ�� UIControl
    end
    
    methods (Hidden)
    %% ���� �Լ�
        function this = FigPopup(cellobj, nim, fig, netLayers, opt)
        %�ʱ�ȭ �Լ�
        % cellobj : (cell) {�׸�, ��(�±�),��(�ε���), ����ũ��, ������ġ}
        % nim : (double) �󺧸��� �̹��� ������
        % fig : (figure) ���� �̹��� �÷��õ� â
        % netLayers : (Layer) SeriesNetwork.Layers�� ������ ��
        % opt : (TrainingOptions[�Ʒø�])
            %%% ����
            this.TableObj = tableObj(cellobj, this, netLayers, opt);
            this.figureMain = fig;
            %%% ����
            this.figurePopup = figure(...
                                    'Name','Target',...
                                    'Color',[1 1 1],...
                                    'Units','pixels',...
                                    'NumberTitle','off', 'MenuBar','none', 'ToolBar','none');
            this.PictureAxes = axes('Parent',this.figurePopup);
            this.imgTarget = imshow(zeros(size(this.TableObj.List.Image{1}))); %!! �̻��ϰ� �̰� figure.Position�� ������ �ִµ�?
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
                                    'String',{'��'},...
                                    'Position',[20 40 115 30], 'Units','pixels');
            %%% �Ӽ�
            this.PictureAxes.Units = 'pixels';
            this.PictureAxes.Position = [25 75 150 150];
            this.figureMain.WindowButtonMotionFcn = {@this.takeTxt, nim};
            this.figureMain.WindowButtonDownFcn = @this.lockTxt;
            this.figureMain.DeleteFcn = @(~,~) delete(this);
            this.figurePopup.DeleteFcn = @(~,~) delete(this);
            this.UpdateButten.Callback = {@this.replaceTag, netLayers(end).Classes};
            %%% �̺�Ʈ
            addlistener(this, 'nowTarget', 'PostSet', @FigPopup.updateNowTarget); % nowTarget �ٲ� ���Ŀ� �ݹ����
            this.nowTarget = 1;
            addlistener(this, 'nowTarget', 'PreSet', @FigPopup.updatePastTarget); % nowTarget �ٲ�� ������ �ݹ����
        end
    %% �Ҹ���
        function delete(this)
        % ��ü �Ҹ��� : figureMain�� ������ �Ӽ��� �� ���ְ�, figurePopup�̶� ������ ������
            this.figureMain.WindowButtonMotionFcn = '';
            this.figureMain.WindowButtonDownFcn = '';
            this.figureMain.DeleteFcn = '';
            close(this.figurePopup) % "��ȿ���� ���� Figure �ڵ� ����"�� "DeleteFcn ���ѷ���" �Ȼ���ϱ� �Ƚ�
        end
    %% figureMain�� �Լ�
        function takeTxt(this, figMain, ~, nim)
        %���콺 �����̴� ���� �ߵ��� ��� : nowTarget�� ������
        % figMain : ���ô�� figure
        % nim : (double) �󺧸��� �̹��� ������
            if ~this.bolLock
                P = figMain.Children(1).CurrentPoint(1, [2 1]);            % figMain���� ó�� ������ axes(�����̹���)���� ���콺 ��ǥ�� �ޱ�
                if all(0<P) && all(P<size(nim))                            % axes ũ�� ���ο� �ִ��� Ȯ���ϱ�
                    P = round(P); lbl = nim(P(1), P(2));                   % nim���� �� ã�� : P[�� ��]�� [�� ��]�� �Է��Կ� ����
                    if lbl > 0 && lbl~=this.nowTarget
                        this.nowTarget = lbl;
                    end
                end
            end
        end
        function lockTxt(this, ~, ~)
        % ���콺 Ŭ���� �� �ߵ��� ���
            this.bolLock = ~this.bolLock;
            % ��ݻ����� �� �˱� ���� ���콺 ������ �ٲٱ�
        end
    %% figurePopup�� �Լ�
        function replaceTag(this, ~, ~, categ)
        %�ٲ޹�ư ������ �� �ߵ��� ���
        % categ : (categorical) ���̾ ���Ե� class���
            txt = char(categ( this.CharacterList.Value ));
            if ismember(txt, {'^','\'}) % �����޽��� �ȳ����� �ϴ� �����Ÿ���������
                this.figureMain.Children(1).Children(end-this.nowTarget).String...
                    = ['\',txt];
            else
                this.figureMain.Children(1).Children(end-this.nowTarget).String...
                    = txt;
            end
            this.Text.String = [this.Text.String, ' �� ', txt];
            notify(this, 'ButtonEvt') % tableObj�� ��������� ���� Ŭ�������� ó���ϵ���.
        end
    end
    
%% �̺�Ʈ
    methods (Static, Hidden)
        function updatePastTarget(~,eventData)
        %Ÿ���� ���� ����� �⺻���·� �ǵ���
            this = eventData.AffectedObject;
            this.figureMain.Children(1).Children(end-this.nowTarget).Color = [1 0 0];
        end
        function updateNowTarget(~,eventData)
        %Ÿ���õ� ��� ��ȭ�� ��
            this = eventData.AffectedObject;
            this.figureMain.Children(1).Children(end-this.nowTarget).Color = [0 1 0];
            this.Text.String = this.TableObj.List.Text_Tag{this.nowTarget};
            this.CharacterList.Value = this.TableObj.List.Text_Index(this.nowTarget);
            this.imgTarget.CData = this.TableObj.List.Image{this.nowTarget};
        end
    end
    
    events
        ButtonEvt % ��ư���� �̺�Ʈ
    end
end

