function [f0,gof] = calcGrowth(t, x, tspan, calcFactor)
    % function for calculation of growth rate of infection.
    sampling = tspan(1):0.02:tspan(end);
    [~,uniqInd,~] = unique(t);
    vals = interp1(t(uniqInd), x(uniqInd), sampling,"pchip");
    [~,tmax] = max(vals);
    stopind = floor(max(tmax * calcFactor, 3));
    [f0,gof] = fit(sampling(1:stopind)',vals(1:stopind)','exp1');
    
end