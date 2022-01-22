function t = structs2tables(structMatrix)
    flds = fields(structMatrix);
    [n,m] = size(structMatrix);
    t = table();
    if m == 1
        t = [t, table(structMatrix)];
        return;
    end
    for f = 1:length(flds)
        t = [t, table(reshape([structMatrix.(flds{f})],n,m),...
            'VariableNames',flds(f))];
    end
end