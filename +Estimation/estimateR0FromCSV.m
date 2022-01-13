function [R0growth, R0Ratio, qual] = ...
    estimateR0FromCSV(csvData,iterPerDay, gammaRate)
    k               = 1:7;
    vals            = ["S","E","I","R","Q","H","D"];
    rowInds         = containers.Map(vals,k);
    infections      = csvData(rowInds("I"),:);
    [~, TtoMaxInf]  = max(infections);
    %  to remove initial noise, count: two gamma / one day
    [~,initMax]     = max(infections(1:2/gammaRate));
    s_ind           = max(iterPerDay, initMax);
    croppingFactor  = 2;
    % if it's too short:
    if TtoMaxInf < s_ind * 4
        f_ind       = size(csvData,2) / (4 * croppingFactor);
    else
        f_ind       = s_ind + (TtoMaxInf - s_ind) / croppingFactor;
    end

    try
        [bestR2, val]   = maximiseExpFit(1:TtoMaxInf,...
            infections(1:TtoMaxInf), [s_ind, f_ind]);
        
        validTimes = round(bestR2(1)) : round(bestR2(2));
    catch ME
        disp("bracket retry");
        validTimes      = s_ind:f_ind;
        % ideally, we get a good ~50 data points for fit. however, we can still
        % add data by expanding slowly.
        while length(validTimes) < 50
            s_ind       = s_ind - 5;
            f_ind       = f_ind + 5;
            validTimes  = s_ind:f_ind;
        end
        s_ind = max(s_ind, 1);
        validTimes  = s_ind:f_ind;
    end
    
    [f0,gof]        = fit(validTimes' / iterPerDay, ...
        infections(validTimes)','exp1');
    
    R0growth        = f0.b;
    qual            = gof.adjrsquare;
    finalInf        = csvData(rowInds("S"),end) / sum(csvData(:,1));
    R0Ratio         = 1 / finalInf;
end