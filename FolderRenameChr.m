% <*** ���� ���丮 �����ؼ� ���� �Ѳ����� ����� ***>
% �̸� Ư�� �������� ���ϵ��� �����ϰ�, �� ������ ���� �̸��� �ٸ� ���������� ����� �۾�
% �Ƹ� �ҷ��� �̹����� ��Ʈ�� ����ְų� ����ġ�� ��Ư�� �������״� ��ȣ�� ���� ������ ����

F = dir(uigetdir(cd, '�񱳴�� ���� ����'));
N0 = {F(3:end).name};

while true
    targetDir = uigetdir(cd, '���ֹ��� ���� ����');
    if ~targetDir, break; end
    F = dir(targetDir);
    N = cellfun(@(fname) [targetDir,'\',fname], setdiff({F(3:end).name}, N0), 'UniformOutput',false);
    delete(N{:})
end