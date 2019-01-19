% <*** 직접 디렉토리 지정해서 파일 한꺼번에 지우기 ***>
% 미리 특정 폴더에서 파일들을 삭제하고, 이 폴더에 없는 이름을 다른 폴더에서도 지우는 작업
% 아마 불량한 이미지는 폰트가 비어있거나 지나치게 독특한 문제일테니 번호가 같을 것으로 예상

F = dir(uigetdir(cd, '비교대상 폴더 지정'));
N0 = {F(3:end).name};

while true
    targetDir = uigetdir(cd, '없애버릴 폴더 지정');
    if ~targetDir, break; end
    F = dir(targetDir);
    N = cellfun(@(fname) [targetDir,'\',fname], setdiff({F(3:end).name}, N0), 'UniformOutput',false);
    delete(N{:})
end