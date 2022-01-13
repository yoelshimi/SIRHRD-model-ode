function resStruct = getMinMaxCorrs(p_risk, p_cautious)
% returns minimum and maximum values of correlation possible with 
% current constrints.

lim1 = max(p_risk+p_cautious-1,0);
lim2 = min(p_risk,p_cautious);
resStruct.minCorr = min(lim1, lim2);
resStruct.maxCorr = max(lim1, lim2);
end