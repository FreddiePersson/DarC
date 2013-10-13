function apdAll = extractApdArrays(data)
nData = length(data);

maxLen = 0;
for i=1:nData   
    maxLen = max(maxLen,length(data{i}.apd1));
end;
apdAll = zeros(maxLen, nData, 3);
for i=1:nData   
    for j=1:3
        apdAll(1:length(data{i}.apd1),i,j) = data{i}.apds(:,j);
    end;
%     apdAll(1:length(data{i}.apd1),i,1) = data{i}.stageX/max(data{i}.stageX);
%     apdAll(1:length(data{i}.apd1),i,2) = data{i}.stageY/max(data{i}.stageY);
%     apdAll(1:length(data{i}.apd1),i,3) = data{i}.scannerY/max(data{i}.scannerY);
end;




