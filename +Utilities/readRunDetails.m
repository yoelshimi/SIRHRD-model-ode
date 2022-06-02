function [R0struct, R0rand, maxTimes, maxInfs, varInf] = ...
    readRunDetails(fname, isRng)
    % output filename
    fid = fopen(fname,"r");
    if fid < 3
        error("fileNotFound");
    end
    s = textscan(fid,"%s");
    s = s{1};
    inds = struct("R0Direct",54,"GrowthRate",57,"R0Ratio",63,...
        "MaxInf",66,"TmaxInf",68,...
        "R0DirectRand",74,"GrowthRateRand",77,"R0RatioRand",83,...
        "MaxInfRand",86,"TmaxInfRand", 88, ...
        "varInfStruct", 91, "varInfRand", 94);
    R0fields = ["R0Direct" "R0Ratio" "GrowthRate"];
    
    vals = cellfun(@(x) str2double(x), ...
        s(arrayfun(@(x) inds.(x), R0fields)));
    for iter=1:length(vals)
        R0struct.(R0fields(iter)) = vals(iter);
    end
    
    R0fieldsRand = R0fields+"Rand";
    vals = cellfun(@(x) str2double(x), ...
        s(arrayfun(@(x) inds.(x), R0fieldsRand)));
    for iter=1:length(vals)
        R0rand.(R0fieldsRand(iter)) = vals(iter);
    end
    
    maxTimesFields = ["TmaxInf" "TmaxInfRand"];
    vals = cellfun(@(x) str2double(x), ...
        s(arrayfun(@(x) inds.(x), maxTimesFields)));
    for iter=1:length(vals)
        maxTimes.(maxTimesFields(iter)) = vals(iter);
    end
    
    maxInfFields = ["MaxInf" "MaxInfRand"];
    vals = cellfun(@(x) str2double(x), ...
        s(arrayfun(@(x) inds.(x), maxInfFields)));
    for iter=1:length(vals)
        maxInfs.(maxInfFields(iter)) = vals(iter);
    end
    
    varInfFields = ["varInfStruct" "varInfRand"];
    vals = cellfun(@(x) str2double(x), ...
        s(arrayfun(@(x) inds.(x), varInfFields)));
    for iter=1:length(vals)
        varInf.(varInfFields(iter)) = vals(iter);
    end
    fclose(fid);
end