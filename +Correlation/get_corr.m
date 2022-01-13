function [mat,C] = get_corr(is_symmetric)
if nargin < 1
    is_symmetric = 0;
end
test_func = @(x) x<=1 && x>=0;
C_func = @(x) (x(1,2)*x(2,1) - x(1,1)*x(2,2)) / (x(1,2)*x(2,1) + x(1,1)*x(2,2));
a = rand();
b = rand();
d = rand();
mat(1,1:2) = [b a];
if is_symmetric
    c = a;
else
    c = rand();
end
mat = [b a; c d;];
mat = mat ./ sum(mat(:));
C = C_func(mat);
end