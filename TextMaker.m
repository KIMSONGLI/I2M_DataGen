close all; clear; clc
% 폰트별로 텍스트 만들기, -10~10deg 회전해서 3개씩

fontList = listfonts;
noIMG = zeros(50);
fig1 = figure;
imshow(noIMG)
nowFolder = cd;

folderNames = char([65:90,65345:65370]); % 폴더명 글자
% '１２３４５６７８９０′＋－＜＝＞±×÷／≠≤≥∞∴∂∇√∝∵∫＾∑＼∼ː│（）'
figureUseNames = char([65:90,97:122]); % figure에 띄울 글자
% '1234567890,+-<=>±×÷/≠≤≥∞∴∂∇√∝∵∫^Σ\~:|()'

for iterFolder = 1:length(folderNames)

    text_write = folderNames(iterFolder);
    try
        cd([nowFolder, '\DigitDataset\', text_write]);
    catch
        mkdir([nowFolder, '\DigitDataset\', text_write]);
        cd([nowFolder, '\DigitDataset\', text_write]);
    end
    
    text_write = figureUseNames(iterFolder);
    iter = 0;
    for font = fontList'
        t = text(25,25, text_write, 'FontSize',20, 'FontName',font{1}, 'Color',[1,1,1], 'HorizontalAlignment','center');
        for rot = [-10, 0, 10]
            iter = iter+1;
            set(t,'Rotation',rot);
            img = rgb2gray(frame2im(getframe(gca)));
            if any(any(img ~= noIMG))
                [r,c] = find(img);
                ru = max(r); rl = min(r); cu = max(c); cl = min(c);
                img = imresize(img(rl:ru, cl:cu), 20/max(ru-rl+1, cu-cl+1));
                imgsize = 0.5*size(img);
                IMG = zeros(28);
                IMG(ceil(14-imgsize(1)):ceil(13+imgsize(1)), ceil(14-imgsize(2)):ceil(13+imgsize(2))) = img;
                imwrite(IMG, sprintf('image%04d.png', iter))
            end
        end
        delete(t)
    end
    
end

cd(nowFolder)
close(fig1)
clear fontList noIMG fig1 nowFolder text_write iter font t rot img_write