function ReadIMG(filename)
% �̹����� �ҷ���, ���ڸ� Ȯ���ϰ� �米�� �ϴ� �Լ�
%
%% ��&�̹��� �ҷ�����
load('test.mat', 'net','options')                                          % net, options
[obj, im0, nim, num_of_obj] = ...
    remakeIMG(imread(filename), net.Layers(1).InputSize, 50);

%% ������ CNN�𵨷� Ȯ���ϱ�
figMain = figure('Name','Result',...
                 'Units','pixels',...
                 'NumberTitle','off', 'MenuBar','none', 'ToolBar','none');
subplot(2,1,1); imshow(im0); title('Original.bmp')
subplot(2,1,2); imshow((nim>0)*0.25); title('Detected');
for label_num = 1:num_of_obj
    [~, obj{label_num,3}] = max( predict(net, obj{label_num,1}) );
    obj{label_num,2} = char(net.Layers(end).Classes( obj{label_num,3} ));
    txt = obj{label_num,2};
    if ismember(obj{label_num,2}, {'^','\'})
        txt = ['\', obj{label_num,2}];
    end
    text( obj{label_num,5}(2),obj{label_num,5}(1), txt,...
        'Color',[1,0,0],'HorizontalAlignment','center',...
        'FontSize',12, 'FontWeight','bold');
end

%% Ʋ���� �米���ϱ�
answer = questdlg('Do you want update your net?','Re-Training','Yes','No','No');
if strcmp(answer,'Yes')
    popup = FigPopup(obj,nim, figMain, net.Layers,options);
    assignin('caller', 'object', popup.TableObj)
end

end


function [output, IMG, IM, num_of_obj] = remakeIMG(IMG,targetSize,Thread)
%�̹��� ������¡ {������¡�� �̹���, [], [], ������� ũ��, ������� ��ġ}
% regionprops(bwlabel(im), 'image') �̰� �������� ������ ���� �����Լ�..
% �׳� �󺧳ѹ��� �ش��ϴ� �κ� �߶�ٰ� �ѹ��� �ٸ��κ� ��İ� ĥ�ϴ� �� �� ���� �� ����� ��.
% ��ȣ �����ؼ� ���� ����� �� ���� �����ΰ� �ͱ⵵ �ϰ�.
    padpix = 6;
    trdpix = 4;
    if ~ismatrix(IMG)
        IM = rgb2gray(IMG);
        targetSize = targetSize([1, 2]);
    else
        IM = IMG;
    end
    IM = 255 - IM;
    [row, col] = find(IM>Thread);                                          % ��ȿ���� �ڸ���
    IMG = IMG(min(row):max(row), min(col):max(col),:);
    IM = IM(min(row):max(row), min(col):max(col));
    [IM, num_of_obj] = bwlabel(IM);                                        % �� ������Ʈ �󺧷� �����ϱ�
    
    C = floor(targetSize/2);
    output = cell(num_of_obj,5);                                           % �׷���, ��(�ؽ�Ʈ),��(�ε���), ����� ũ��, ����� ��ġ
    for label_num = 1:num_of_obj
        % �� ������ �� ��ǥ�� ã��, ��ġ�� ũ�⸦ ����ϱ�
        [row,col] = find(IM==label_num);
        output{label_num,5} = median([row,col]);                           % ��ġ
        row = row-min(row)+1; col = col-min(col)+1;
        output{label_num,4} = max([row,col]);                              % ũ��
        % �� ������ �����ؼ� ���ο� �̹����� �����
        temp_img = zeros(output{label_num,4});                             % �������
        temp_img(sub2ind(output{label_num,4}, row, col)) = 255;            % ��۾�
        % ������ �̹����� input����� ���߱�
        temp_img = imresize(temp_img, (min(targetSize)-padpix)/max(output{label_num,4}));
                   % �� ���� �������� ���̱�, ���� �е��� ���ļ� padpix��ŭ
        temp_img = (temp_img>trdpix)*255; % ������¡ �ؼ� �帮�������� �� �����ϰ� ���� (�� ����)
        temp_size = 0.5*size(temp_img);
        % ���θ��� �̹����� �߽ɿ� �ٿ��ֱ�
        output{label_num,1} = zeros(targetSize, 'uint8');
        output{label_num,1}(ceil(C-temp_size(1)):ceil(C-1+temp_size(1)), ceil(C-temp_size(2)):ceil(C-1+temp_size(2))) = temp_img;
    end
end

