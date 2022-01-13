% load("C:\Users\yoel\Dropbox\SocialStructureGraph\"+...
% "results from yoel\result tables\tables.mat")

subTable    = T(T.p_risk == T.p_cautious &...
    T.graphType == "DregGraph",:);

sbString    = ["s" "ns"]+["b" "nb"]';
sbHospMat   = arrayfun(@(x) subTable.hosp.(x), ...
    sbString, 'UniformOutput', false);
a = cat(3,sbHospMat{:});
hospSum     = sum(cat(3,sbHospMat{:}),3);
hospSumCV   = std(hospSum,[],2)./mean(hospSum,2);
hospSumMean = mean(hospSum,2);
[G,ID]      = findgroups(subTable.corr);
figure; boxplot(hospSumCV,G,"Labels",ID);
hospByPrisk = reshape(hospSumCV,[],length(ID));

figure; plot(subTable.corr, hospSumCV,"k.");