function tab = removeTableNameSuffix(tab, suffix)
% utility function for removing suffixes from table variable names.
% recursive goes over sub-tables because matlab is crap.
    names = tab.Properties.VariableNames;
    bIsTabName = arrayfun(@(x) istable(tab.(x{:})), names);
    for iter = 1:length(names)
        if bIsTabName(iter)
            subTab = tab.(names{iter});
            tab.(names{iter}) = ...
                Utilities.removeTableNameSuffix(subTab, suffix);
        end
    end
    tab.Properties.VariableNames = erase(names,suffix);
end