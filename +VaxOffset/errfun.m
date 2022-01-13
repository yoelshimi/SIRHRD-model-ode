
function err = errfun(input, f)
% returns second variable of testFun.
    [~, err] = f(input(1), input(2));
end