function inPos = outerToInnerPosition(ax1, outPos)
    % gets : axis, outer position
    % returns : inner position relative to axis.
    if all(outPos([3 4]) >= outPos([1 2]) )
        % actual values, and not the offsets for axis creation.
        outPos([3 4]) = outPos([3 4]) - outPos([1 2]);
    end
    
    scaleX = (ax1.Position(3) - ax1.Position(1))...
        / (ax1.OuterPosition(3) - ax1.OuterPosition(1));
    scaleY = (ax1.Position(4) - ax1.Position(2))...
        / (ax1.OuterPosition(4) - ax1.OuterPosition(2));
    
    inPos = [(outPos(1) - ax1.OuterPosition(1)) * scaleX + ax1.Position(1) ...
        (outPos(2) - ax1.OuterPosition(2)) * scaleY + ax1.Position(2) ...
        outPos(3) * scaleX ...
        outPos(4) * scaleY ];
end