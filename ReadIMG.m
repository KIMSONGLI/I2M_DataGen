function ReadIMG(filename)
% 이미지를 불러서, 글자를 확인하고 재교육 하는 함수
%
%% 모델&이미지 불러오기
load('test.mat', 'net','options')                                          % net, options
[obj, im0, nim, num_of_obj] = ...
    remakeIMG(imread(filename), net.Layers(1).InputSize, 50);

%% 교육된 CNN모델로 확인하기
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

%% 틀린거 재교육하기
answer = questdlg('Do you want update your net?','Re-Training','Yes','No','No');
if strcmp(answer,'Yes')
    popup = FigPopup(obj,nim, figMain, net.Layers,options);
    assignin('caller', 'object', popup.TableObj)
end

end


function [output, IMG, IM, num_of_obj] = remakeIMG(IMG,targetSize,Thread)
%이미지 리사이징 {리사이징한 이미지, [], [], 상대적인 크기, 상대적인 위치}
% regionprops(bwlabel(im), 'image') 이게 생각보다 느려서 새로 만든함수..
% 그냥 라벨넘버에 해당하는 부분 잘라다가 넘버링 다른부분 까맣게 칠하는 게 더 빠를 거 같기는 함.
% 번호 추출해서 새로 만드는 거 조금 낭비인가 싶기도 하고.
    padpix = 6;
    trdpix = 4;
    if ~ismatrix(IMG)
        IM = rgb2gray(IMG);
        targetSize = targetSize([1, 2]);
    else
        IM = IMG;
    end
    IM = 255 - IM;
    [row, col] = find(IM>Thread);                                          % 유효영역 자르기
    IMG = IMG(min(row):max(row), min(col):max(col),:);
    IM = IM(min(row):max(row), min(col):max(col));
    [IM, num_of_obj] = bwlabel(IM);                                        % 각 오브젝트 라벨로 구분하기
    
    C = floor(targetSize/2);
    output = cell(num_of_obj,5);                                           % 그래픽, 값(텍스트),값(인덱스), 상대적 크기, 상대적 위치
    for label_num = 1:num_of_obj
        % 라벨 영역의 각 좌표를 찾고, 위치와 크기를 계산하기
        [row,col] = find(IM==label_num);
        output{label_num,5} = median([row,col]);                           % 위치
        row = row-min(row)+1; col = col-min(col)+1;
        output{label_num,4} = max([row,col]);                              % 크기
        % 라벨 영역만 추출해서 새로운 이미지로 만들기
        temp_img = zeros(output{label_num,4});                             % 검정배경
        temp_img(sub2ind(output{label_num,4}, row, col)) = 255;            % 흰글씨
        % 추출한 이미지를 input사이즈에 맞추기
        temp_img = imresize(temp_img, (min(targetSize)-padpix)/max(output{label_num,4}));
                   % 긴 변을 기준으로 줄이기, 양쪽 패딩은 합쳐서 padpix만큼
        temp_img = (temp_img>trdpix)*255; % 리사이징 해서 흐리멍텅해진 걸 선명하게 만듦 (좀 낭비)
        temp_size = 0.5*size(temp_img);
        % 새로만든 이미지를 중심에 붙여넣기
        output{label_num,1} = zeros(targetSize, 'uint8');
        output{label_num,1}(ceil(C-temp_size(1)):ceil(C-1+temp_size(1)), ceil(C-temp_size(2)):ceil(C-1+temp_size(2))) = temp_img;
    end
end

