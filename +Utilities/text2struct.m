function endStruct = text2struct(rawtext)
% function that reads raw rext file from sim to make struct of results.
    FIELDMARKER = ":";
    TEXTMARKER  = "[^0-9.,]+";
    NUMMARKER   = "(nan)||[+-]?([0-9]*[.])?[0-9]+";
    lines = splitlines(rawtext);
    n = size(lines, 1);
    for iter = 1 : n
        parts = split(lines{iter}, FIELDMARKER);
        parts = strrep(parts, "nan", "000"); % removes nan.
        parts = erase(regexp([parts{:}], TEXTMARKER, "match")', " ");
        nums  = cellfun(@(x) str2double(x), ...
            regexp(lines{iter}, NUMMARKER, "match"));
        m = min(size(parts, 1), numel(nums));
        if isempty(parts) || isempty(parts{1})
            continue;
        end
        for iter2 = 1 : m
            fieldName = matlab.lang.makeValidName(parts{iter2});
            endStruct.(fieldName) = nums(iter2);
        end
    end
end