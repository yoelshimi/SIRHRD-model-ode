function setFieldInChildren(f, fieldName, newValue, subField)
% helper function for children properties.
    res = Utilities.getFieldInChildren(f, fieldName);
    if nargin == 4
        res.(subField) = newValue;
    else
        res = newValue;
    end
end