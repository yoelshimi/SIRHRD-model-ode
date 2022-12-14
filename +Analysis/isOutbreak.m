function structIsOutbreak = isOutbreak(dataStruct)
    OUTBREAKCRITERION = 0.5;
    FITCRITERION      = 0.8;
    RATIOCRITERION    = 0.1;
    PEAKINFTCRITERION = 10;
    PEAKINFCRITERION  = 0.1;
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
        structIsOutbreak(iter).isGrowth           = getAtInd(dataStruct(iter), "R0matlab", R0growthInd) >= 0;
        % more than R val 0.8 on fit
        structIsOutbreak(iter).isExp              = getAtInd(dataStruct(iter), "R0matlab", qual) > FITCRITERION;
        % ratio of sick at end vs healthy -- more than 10% were infected
        % overall.
        structIsOutbreak(iter).isRatioMoreThan10  = getAtInd(dataStruct(iter), "R0matlab", R0ratioInd) > RATIOCRITERION; 
        % is there more than 10 days to peak infection time.
        structIsOutbreak(iter).isPeakAfter10Days  = getAtInd(dataStruct(iter), "peakInfT", 0, 1) ./ unique([dataStruct(iter).freq]) > PEAKINFTCRITERION; 
        % more than 10% of population were infected at the peak
        structIsOutbreak(iter).isPeakInfMoreThen1 = getAtInd(dataStruct(iter), "peakInf", 0, 1) > PEAKINFCRITERION;
        v = Utilities.getStructVals(structIsOutbreak(iter));
        structIsOutbreak(iter).metrics    = sum(uint8(cat(3, v{:})), 3) / numel(v);
        structIsOutbreak(iter).p_outbreak = mean(structIsOutbreak(iter).metrics);
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
