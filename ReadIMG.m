close all; clear; clc
load('test.mat')                                                           % net, MyLabel

%% Load Data
startTime = cputime;

%% Read image data
% tic
im = 255 - rgb2gray(imread('sample.bmp'));
% toc

%% Cut valid Image
% tic
[row, col] = find(im>50);
im = im(min(row):max(row), min(col):max(col));
% toc

%% Divide object
% tic
[nim, num_of_obj] = bwlabel(im);
% toc

%% Remake each object
% regionprops(nim_labeled, 'image'); �� �Լ� �ӵ��� �Ѹ� ����
% tic
obj = cell(num_of_obj,4);                                                  % �׷���, ��, ����� ũ��, ����� ��ġ
for label_num = 1:num_of_obj
    % Get particular label
    [row,col] = find(nim==label_num);
    obj{label_num,4} = median([row,col]);                                  % ��ġ
    row = row-min(row)+1; col = col-min(col)+1;
    obj{label_num,3} = max([row,col]);                                     % ũ��
    % Make new image
    temp_img = zeros(obj{label_num,3});
    temp_img(sub2ind(obj{label_num,3}, row, col)) = 1;
    % Resize each object
    temp_img = imresize(temp_img, 20/max(obj{label_num,3}));               % �� ���� 20����
    temp_size = 0.5*size(temp_img);
    obj{label_num,1} = zeros(28);
    obj{label_num,1}(ceil(14-temp_size(1)):ceil(13+temp_size(1)), ceil(14-temp_size(2)):ceil(13+temp_size(2))) = temp_img;
end
% toc

%% Test NN
% load('test.mat')
% figure
% for label_num = 1:num_of_obj
%     subplot(1,num_of_obj, label_num); imshow(obj{label_num,1})
%     [~, obj{label_num,2}] = max( sigmoid( v * [1; sigmoid( w * [1; reshape((obj{label_num,1})', [], 1)] )] ) );
%     if obj{label_num,2}==10, obj{label_num,2}=0; end
%     text( 3,0, sprintf('�м���� : %1d \n', obj{label_num,2}));
% end
% disp( string(cat(2, obj{:,2})) )

%%
endTime = ['�ҿ�ð� : ', num2str(cputime-startTime),'��'];

%% Test CNN
% tic
% load('test.mat')
figure
subplot(2,1,1); imshow(imread('sample.bmp')); title('����.bmp')
subplot(2,1,2); imshow(0.5*im); title(['�ν��� ��, ', endTime])
for label_num = 1:num_of_obj
    eachProbability = predict(net, 255*obj{label_num,1});
    [~, obj{label_num,2}] = max(eachProbability);
    text( obj{label_num,4}(2),obj{label_num,4}(1), MyLabel{obj{label_num,2}},...
        'Color',[1,0,0],'HorizontalAlignment','center',...
        'FontSize',18, 'FontWeight','bold');
end
% toc

%%
% disp(['�� ', num2str(cputime-t),'��'])