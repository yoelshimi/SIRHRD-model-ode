function vals = getStructVals(strct)
    % utility functoin gives the values of a struct, returns in cellArray
    flds = fields(strct);
    vals = cell(1, numel(flds));
    for iter = 1 : numel(flds)
        vals{iter} = strct.(flds{iter});
    end
end