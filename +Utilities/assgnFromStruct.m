function assgnFromStruct(strct)
%     function that assigns the struct field variables into the workspace
%     WS.
    for fld = fields(strct)'
        assignin("caller", fld{:}, strct.(fld{:}));
    end
end