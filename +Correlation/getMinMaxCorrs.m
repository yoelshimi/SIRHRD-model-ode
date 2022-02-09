function resStruct = getMinMaxCorrs(p_risk, p_cautious)
    % returns minimum and maximum values of correlation possible with 
    % current constrints.
    % corr = p(Cautious and Risk), CR group, 
    % case 1: those at risk avoid cautioun, those cautious avoid risk.
    % case 2: all those at risk are cautious.
    lim1 = max(p_risk+p_cautious-1,0);
    lim2 = min(p_risk,p_cautious);
    resStruct.minCR = min(lim1, lim2);
    resStruct.maxCR = max(lim1, lim2);
end