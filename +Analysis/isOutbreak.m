function [bIsOutbreak] = isOutbreak(dataStruct)
    OUTBREAKCRITERION = 0.5;
    FITCRITERION      = 0.8;
    RATIOCRITERION    = 0.1;
    PEAKINFTCRITERION = 10;
    PEAKINFCRITERION  = 1;
    % function for determining if an "outbreak" has taken place.
    % check: 1 -- did peak infection happen after more than 10 days.
    n = size(dataStruct, 1);
    % 2 -- did
    R0growthInd = 1;
    R0ratioInd = 2;
    qual = 3;
    for iter = 1 : n
        % if the R0growth is larger than 0, and a good fit > 0.9, it means
        % there was exponential growth that grew.
        bIsOutbreak(iter).isGrowth           = getAtInd(dataStruct(iter), "R0matlab", R0growthInd) >= 0;
        bIsOutbreak(iter).isExp              = getAtInd(dataStruct(iter), "R0matlab", qual) > FITCRITERION; % more than R val 0.8 on fit
        bIsOutbreak(iter).isRatioMoreThan10  = getAtInd(dataStruct(iter), "R0matlab", R0ratioInd) > RATIOCRITERION; % ratio of sick at end vs healthy
        bIsOutbreak(iter).isPeakAfter10Days  = getAtInd(dataStruct(iter), "peakInfT", 0, 1) ./ unique([dataStruct(iter).freq]) > PEAKINFTCRITERION; 
        bIsOutbreak(iter).isPeakInfMoreThen1 = getAtInd(dataStruct(iter), "peakInf", 0, 1) > PEAKINFCRITERION;
        
        v = Utilities.getStructVals(bIsOutbreak(iter));
        bIsOutbreak(iter).metrics    = sum(uint8(cat(3, v{:})), 3) / numel(v);
        bIsOutbreak(iter).p_outbreak = mean(bIsOutbreak(iter).metrics > OUTBREAKCRITERION);
    end
end

function res = getAtInd(strct, fld, ind, dim)
% helper function for extracting from struct.
    if nargin == 3
        dim = 3;
    end
    x = vertcat(strct.(fld));
    switch dim
        case 1
            res = x(:, :);
        case 3        
            res = x(:, :, ind);
    end
end
