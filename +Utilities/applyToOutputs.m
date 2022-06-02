function applyToOutputs(hdl, childName, field, value)
    % applies to all childrenm, good for multiple outputs, forks like
    % cellfun.
    res = {hdl.(childName)};
    for iter = 1 : numel(res)
            if iscell(res(iter))
                set(res{iter}(isprop(res{iter}, field)), field, value)
            else
                r = res(iter);
                set(r(isprop(r, field)), field, value)
            end
    end
    
end