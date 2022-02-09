function [res, f1Vals, f2Vals] = retrieve2mat...
    (tab, field1, field2, valueField, idx, constraints)
%  function for retrieving data from table into matrix.
% field1: first index, rows.
% field2: column index.
% valueField: value to retrieve.
% assumes square completeness.
if nargin == 6
    constr = true;
else 
    constr = false;
end
f1Vals = uniquetol(tab.(field1));
f2Vals = uniquetol(tab.(field2));
n = length(f1Vals);
m = length(f2Vals);
k = numel(valueField);
res = zeros(n,m, k);
multipleFields = k > 1;
for iter1 = 1:n
    for iter2 = 1:m
        % get relevant table part
        subTable = tab(tab.(field1) == f1Vals(iter1) & ...
            tab.(field2) == f2Vals(iter2),:);
        if constr
            % use constraints.
            for c = Utilities.flattenToRow(fields(constraints))
                c = c{:};
                val = constraints.(c);
                if exist(val, "builtin")
                    val = feval(val, subTable.(c));
                end
                subTable = subTable(subTable.(c) == val, :);
            end
        end
        if isempty(subTable)
            continue;
        end
        if multipleFields == true
            val = arrayfun(@(x) cell2sum(subTable.(x)), valueField,...
                "UniformOutput", true);
        else
            val = subTable.(valueField);
            if istable(val)
                sbSTR = {'snb','sb','nsnb','nsb'};
                if all(contains(val.Properties.VariableNames,sbSTR)) == true
                    val = mean(table2array(val),"all");
                    val = val * 4;
                else 
                    val = sum(table2array(val),"all");
                end
                    res(iter1,iter2) = val;
                continue;
            else
                val = cell2sum(val);
            end
        end
        % inputs into res matrix
        if numel(val) == 1
            res(iter1,iter2) = val;
        elseif numel(val) == 3
            res(iter1,iter2, :) = val;
        elseif isnan(idx)
            res(iter1,iter2) = sum(val(:));
        else
            res(iter1, iter2, 1) = val(idx);
        end
    end
end      
    
end

function y = cell2sum(x)
    if iscell(x)
        x = x{:};
    end
    y = sum(x);
end