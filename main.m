close all; clear; clc
% <*** �������ϰ� ������ main�� �����ϵ��� ������ ***>

[file,path] = uigetfile({'*.bmp';'*.jpg';'*.png'},'�׸����� �����ϼ�', 'sample.bmp', 'MultiSelect','on');

if ischar(file)
    disp(file)
    ReadIMG([path,file])
    % �۾������� object ��� �̸��� tableObj �������
else
    for f = file
        disp �����׸����Ͽ�����������
        disp(f)
    end
end
clear file path