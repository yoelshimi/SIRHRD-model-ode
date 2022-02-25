function y = flattenToRow(x)
% helper function - flattens data to fixed shape.
if isrow(x)
    y = x;
else
    y = x';
end