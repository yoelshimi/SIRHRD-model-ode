function [locX,locY] = interpForZeros(data, xVals, yVals)
    n = size(data,1);
    m = length(xVals);
    locX = nan(n,1);
    locY = locX;
    x0 = xVals(round(m / 2));
    for iter = 1 : n
        row = data(iter,:);
        if max(row) > 0 && min(row) < 0
            % there is a zero-crossing
            interpolationFun = @(x) interp1(xVals, row, x, "pchip");
            zeroInd          = fzero(interpolationFun, x0);
            locX(iter)        = zeroInd;
        end
    end
    if nargout == 2
        for iter = 1 : m
            col = data(:,iter);
            if max(col) > 0 && min(col) < 0
                % there is a zero-crossing
                interpolationFun = @(x) interp1(yVals, col, x, "pchip");
                zeroInd          = fzero(interpolationFun, x0);
                locY(iter)       = zeroInd;
            end
        end
    end
end