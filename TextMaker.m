close all; clear; clc
% ��Ʈ���� �ؽ�Ʈ �����, -10~10deg ȸ���ؼ� 3����

% �̹��� ������ : 56*56 ��� uint8����. ��濡 ������ 0~150 ��������.
% �ؽ�Ʈ ������ ���� ��, �������� �ؼ� ������!, �� �е��� 3����Ʈ ������!

fontList = listfonts;
noIMG = zeros(256);
fig1 = figure;
imaxes = imshow(noIMG);
word = text(128,128, '', 'FontSize',55, 'Color',[1,1,1],...
            'HorizontalAlignment','center', 'Interpreter','tex');
        % 'String',text_write, 'FontName',font{1}
nowFolder = cd;
% imaxes.CData = randi([0 150], 256);

folderNames = char([913:937, 945:969]);
% char([65296:65305,65:90,65345:65370]); % ������ ���� '��������������������ABCDEFGHIJKLMNOPQRSTUVWXYZ���������������������������������'
% '�ǣ��������������������¡áġšӡԡ����ޢ�������������'
% char([913:937, 945:969]) % �׸�������
figureUseNames = char([913:937, 945:969]);
% char([48:57,65:90,97:122]); % figure�� ��� ���� '0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz'
% ',+-<=>������/���¡áġšӡԡ����^��\~:|()'
% char([913:937, 945:969])

for iterFolder = 1:length(folderNames)

    text_write = folderNames(iterFolder);
    try
        cd([nowFolder,'\DigitDataset\',text_write]);
    catch
        mkdir([nowFolder,'\DigitDataset\',text_write]);
        cd([nowFolder,'\DigitDataset\',text_write]);
    end
    
    text_write = figureUseNames(iterFolder);
    switch text_write
        case '^'
            text_write = '\^';
        case '\'
            text_write = '\\';
    end
    iter = 0;
    for font = fontList'
        word.String = ['\fontname{',font{1},'}',text_write];
%         word.FontName = font{1};
        for rot = [-10, 0, 10]
            iter = iter+1;
            set(word,'Rotation',rot);
            img = rgb2gray(frame2im(getframe(gca)));
            if any(any(img ~= noIMG))
                [r,c] = find(img);
                ru = max(r); rl = min(r); cu = max(c); cl = min(c);
                img = imresize(img(rl:ru, cl:cu), 50/max(ru-rl+1, cu-cl+1));
                imgsize = 0.5*size(img);
                IMG = zeros(56,'uint8');
                IMG(ceil(28-imgsize(1)):ceil(27+imgsize(1)), ceil(28-imgsize(2)):ceil(27+imgsize(2))) = img;
                if numel(IMG(IMG>150))>258
                    IMG(IMG<=150) = randi([0 150], size(IMG(IMG<=150)));
                    imwrite(IMG, sprintf('image%04d.png', iter))
                end
            end
        end
    end
%     delete(word)
end
winopen([nowFolder,'\DigitDataset']);
cd(nowFolder)
close(fig1)
% clear fontList noIMG fig1 nowFolder text_write iter font t rot img_write