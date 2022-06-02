function [val, err] = fitSIHRDparams(xinit, param, tdata,...
    dataToFit, DataName, ParamName)
    % function that finds the best value for paramToFit.
    f = @(x) getErrorFromParam(xinit, param, tdata,...
    dataToFit, DataName, ParamName, x);
    [val, err] = fminbnd(f, 0, 1);
end

function err = getErrorFromParam(xinit, param, tdata,...
    dataToFit, DataName, ParamName, value)
    switch(lower(ParamName))
        case "efficiency"
            base_beta = param(3);
            param(1:3) = base_beta * [1 value value.^2];
        case "caution"

    end
    [x,t]=SEIR.SEIRodeSolver_YR([min(tdata) max(tdata)],param,xinit);

    switch(lower(DataName))
        case "inf"
            newData = sum(x(:, 5:8), 2);
            newData = interp1(t, newData, tdata);
        case "hosp"
            newData = sum(x(:, 9:12), 2);
            newData = interp1(newData, t, tdata);
    end

    err = sum((newData - dataToFit) .^2 ./ dataToFit);
end