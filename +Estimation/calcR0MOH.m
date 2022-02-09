function R0 =  calcR0MOH(infected, t, t0)
    import Estimation.*
    % function that determines the R0 according to MOH calculation.
    % function considers 7 points for calc.
    %  R_0 = I_t / (sum(I_{t-s} * w_s) for s from 0 to t
    timePeriod = 1:7;
    if nargin == 2
        % we want a general value over time
        R0vals = calcR0MOH(infected, t, min(t) : max(t));
        R0 = prctile(R0vals, 95);
        return
    end
    if length(t0) > 1
        % if this is a vector- run recursively.
        R0 = arrayfun(@(t1) calcR0MOH(infected, t, t1), t0);
        return;
    end
    
    if  all(ismembertol(t0 + timePeriod, t, 1e-9)) == true
        thisInf = infected(t0 + timePeriod);
    else
        thisInf = interp1(t,infected, t0 + timePeriod);
    end
    % their parameters
    gmean = 4.5;
    gstd = 3.5;
    scale = gmean / gstd;
    shape = gmean / scale;
    % fixed
    ws = diff(gamcdf(0:length(timePeriod), shape, scale));
    % normalize ws:
    ws = ws ./ sum(ws);
    
    R0 = thisInf(7) ./ dot(flip(thisInf), ws);
end

