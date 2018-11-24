% ���� ���丮 �����ؼ�, rgb�� ����� ��츦 gray�� �����ϱ�
indir = uigetdir(cd, 'Select input folder'); 
outdir = uigetdir(cd, 'Select output folder'); 
directory = dir([indir, '\', '*.png']); 

for iter = 1 : length(directory) 
    filename = directory(iter).name; 
    rgb_img = imread([indir, '\', filename]);  
    if (ndims(rgb_img) == 3) % �ش������� RGB�� ���
        img = rgb2gray(rgb_img); 
        %Save gray image to outdir (keep original name). 
        imwrite(img, [outdir, '\', filename]); 
    end 
end 