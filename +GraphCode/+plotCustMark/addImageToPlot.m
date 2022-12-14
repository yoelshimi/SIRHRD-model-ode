function ax2 = addImageToPlot(ax1, x, y, im, lbl, sz)
    % plot on large axes
    if isnan(im)
        ax2 = nan;
        return
    end
    if nargin <= 5
        sz = [0.1 0.1];
    end
    f = ax1.Parent;
    p = plot(ax1, x, y, 'kp', "DisplayName", lbl, "MarkerSize", 1);
    p.Visible = "off";
    grid on;
    imSize = sz;
    % Put images at every (x,y) location.
    dfun = @(v, d) [v - d, v + d];  
    for k = 1 : numel(x)
        % Create smaller axes on top of figure.

        [xLoc, yLoc] = GraphCode.Coords.coord2norm(ax1, ...
            x(k),y(k));
        % make the y lined up
        newPosition = [xLoc(1)-imSize(2)/2 yLoc(1)-imSize(2)/2 imSize(1) imSize(2)];
%         newPosition = GraphCode.Coords.outerToInnerPosition(ax1, newPosition);
        % removed overlap test! 
        if false %  checkIsOverlap(f, newPosition) == true
            disp(lbl+" cannot be plotted due to overlap");
            ax2 = [];
            continue;
        else
%             annotation('arrow', [xLoc, xLoc+0.1], [yLoc, yLoc+0.1]);
            ax2 = axes('Position', newPosition, ...
                "Box", "off");
            imshow(im);
            axis('off', 'image');
            t = title(ax2, lbl, "BackgroundColor", "white");
            t.FontSize = 7;
            t.VerticalAlignment = "bottom";
            t.Clipping = "on";
            
        end
    end
end


function isOverLap = checkIsOverlap(f, newPosition)
    % function checks whether there is an overlap with other countries.
    ax       = f.Children(1 : end - 1);
    newShape = GraphCode.Coords.positionToShape(newPosition);   
    isOverLap = false;
    iter = 0;
    n = numel(ax);
    
    while iter < n & isOverLap == false
        existing_p = ax.Position;
        shp        = GraphCode.Coords.positionToShape(existing_p);
        isOverLap  = overlaps([shp newShape]);
        isOverLap  = any(isOverLap(~eye(size(isOverLap))));
%         disp(isOverLap);
        iter = iter + 1;
    end
    if isOverLap
        disp("overlap")
    end
end