function newShape = positionToShape(pos)
    % input: position from axes object
    % output: xy polyshape object.
    % utility to translate position to polyshape.
    
    pX = [pos(1) pos(1) + pos(3)];
    pX = [pX(1) pX(2) pX(2) pX(1)];
    pY = [pos(2) pos(2) + pos(4)];
    pY = [pY(1) pY(1) pY(2) pY(2)];
    newShape = polyshape(pX, pY);
end