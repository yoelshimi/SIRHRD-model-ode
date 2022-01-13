function varargout = distributeOutputs(x)
    % function returns for each varargout a value from x.
    for iter = 1 : nargout
        varargout{iter} = x(iter);
    end
end