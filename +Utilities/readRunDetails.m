function [R0struct, R0rand, maxTimes, maxInfs, varInf] = ...
    readRunDetails(fname)
    % mediator function that reads simulation output files structs into
    % graphable information.
    % output filename
    fid = fopen(fname,"r");
    if fid < 3
        error("fileNotFound");
    end
    mode = "text2struct";
    switch mode
        case "local"
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
        case "text2struct"
            % read the files, turn into struct and read the fields.
            txt            = fscanf(fid, "%c");
            valStruct      = Utilities.text2struct(txt);
            % which fields are to be looked for and extracted.
            isDregActive   = any(contains(fields(valStruct), "Dreg"));
            isStructActive = any(contains(fields(valStruct), "struct"));
            R0fields       = ["R0Direct" "R0Ratio" "GrowthRate"];
            maxInfFields   = struct("in", [], "out", []);
            maxTimesFields = maxInfFields;
            infVarFields   = maxInfFields;
            
            R0struct = [];
            R0rand   = [];
            if isStructActive  
                term = "Graph";
                readFields = ["simulationRdirect", ...
                    "Rratio", "Growthrate"];
                readFields = term+readFields;
                for iter = 1 : length(R0fields)
                    R0struct.(R0fields(iter)) = valStruct.(readFields(iter));
                end
                maxTimesFields.out = [maxTimesFields.out, "TmaxInf"];
                maxTimesFields.in  = [maxTimesFields.in, term+"maxTime"];
                maxInfFields.out   = [maxInfFields.out, "MaxInf"];
                maxInfFields.in    = [maxInfFields.in, term+"maxinf"];
                infVarFields.out   = [infVarFields.out, "varInfStruct"];
                infVarFields.in    = [infVarFields.in, "Qvarstructured"];
            end
            if isDregActive
                term = "Dreg";
                termOut = "Rand";
                readFields = ["simulationRdirect", ...
                    "Rratio", "Growthrate"];
                readFields = term+readFields;
                for iter = 1 : length(R0fields)
                    R0rand.(R0fields(iter)) = valStruct.(readFields(iter));
                end
                maxTimesFields.out = [maxTimesFields.out, "TmaxInf"+termOut];
                maxTimesFields.in  = [maxTimesFields.in, term+"maxTime"];
                maxInfFields.out   = [maxInfFields.out, "MaxInf"+termOut];
                maxInfFields.in    = [maxInfFields.in, term+"maxinf"];
                infVarFields.out   = [infVarFields.out, "varInf"+termOut];
                infVarFields.in    = [infVarFields.in, "Qvarrandom"];
            end
            for iter = 1 : numel(maxTimesFields.in)
                maxTimes.(maxTimesFields.out(iter)) = ...
                    valStruct.(maxTimesFields.in(iter));
                maxInfs.(maxInfFields.out(iter)) = ...
                    valStruct.(maxInfFields.in(iter));
                varInf.(infVarFields.out(iter)) = ...
                    valStruct.(infVarFields.in(iter));
            end
    end
    fclose(fid);
end