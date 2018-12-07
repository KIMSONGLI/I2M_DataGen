% 직접 디렉토리 지정해서, rgb로 저장된 경우를 gray로 변경하기
indir = uigetdir(cd, 'Select input folder'); 
outdir = uigetdir(cd, 'Select output folder'); 
directory = dir([indir, '\', '*.png']); 

for iter = 1 : length(directory) 
    filename = directory(iter).name; 
    rgb_img = imread([indir, '\', filename]);  
    if (ndims(rgb_img) == 3) % 해당파일이 RGB인 경우
        img = rgb2gray(rgb_img); 
        %Save gray image to outdir (keep original name). 
        imwrite(img, [outdir, '\', filename]); 
    end 
end 