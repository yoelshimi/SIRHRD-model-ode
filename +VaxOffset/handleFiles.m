
function tab = handleFiles(tab)
    numFields = width(tab) - 1;
    flds = ["t","x"+(1:numFields)];
    tab.Properties.VariableNames = flds;
    tab = tab(2:end, :);
    tab.t = datetime(datevec(cell2mat(tab.t),"dd-mm-yyyy"));
    % hosp.t(:,4:6) = 0;
    for iter = 2 : numFields + 1
        firstPoint = tab.(flds(iter)){1};
        if all(isstrprop(firstPoint, "digit") |...
                isstrprop(firstPoint,"punct"))
            tab.(flds(iter)) = cellfun(@(x) str2double(x),...
                tab.(flds(iter)));
        else
            tab.(flds(iter)) =categorical(tab.(flds(iter)));
        end
    end
end