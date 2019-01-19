close all; clear; clc
% <*** 지저분하게 보여서 main만 실행하도록 정리함 ***>

[file,path] = uigetfile({'*.bmp';'*.jpg';'*.png'},'그림파일 선택하셈', 'sample.bmp', 'MultiSelect','on');

if ischar(file)
    disp(file)
    ReadIMG([path,file])
    % 작업공간에 object 라는 이름의 tableObj 만들어짐
else
    for f = file
        disp 아직그림파일여러개ㄴㄴ해
        disp(f)
    end
end
clear file path