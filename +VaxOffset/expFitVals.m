function vals = expFitVals(fit1, x)
% evaluate fitting function fit1, at points x.
    if iscell(fit1)
        fit1 = fit1{:};
    end
    vals = feval(fit1, x);
end
