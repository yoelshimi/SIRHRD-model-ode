function res = getFieldInChildren(f, fieldName, subField)
% helper function for children properties.
% currently goes up to 2 layers down.
    res = [];
    ch = f.Children;
    for iter = 1 : numel(ch)
        if any(contains(fields(ch(iter)), fieldName))
            if nargin == 3 && any(contains(...
                    fields(ch(iter).(fieldName)), subField))
                res = [res ch(iter).(fieldName).(subField)];
            else
                res = [res ch(iter).(fieldName)];
            end
        end
    end
end