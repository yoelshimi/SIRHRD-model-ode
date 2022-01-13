function res = isEqualTol(x, y)
    % function checks if they are equal to within tolerance of values.
    mx = max(x,[], "all");
    my = max(y,[], "all");
    res = abs(x - y) < 1.2*max([eps(mx), eps(my), eps, ...
        eps * mx, eps * my]);
end