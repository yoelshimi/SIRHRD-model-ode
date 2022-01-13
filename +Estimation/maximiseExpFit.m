function [bestR2, val]   = maximiseExpFit(x, y, initGuess)
    opts    = optimset("Display","off","FunValCheck","on",...
        "TolX", 1e-2,"MaxIter",100,"MaxFunEvals",100);
    getRfit         = @(s,e) getRsquared(s,e,x,y);
    fittingFunc     = @(x) -getRfit(x(1),x(2));
    [bestR2, val]   = fminsearch(fittingFunc, initGuess, opts);
%     A = [-1 0; 0 1; 1 -1]; 
%     b = [0; length(x); 0];
%     % we have: s' >= 0, e' <= xvals, s <= e, s-e >= 50
%     [bestR2, val]   = ga(fittingFunc,2,A,b,[],[],[],[],[],1:2,opts);
end

function adR2 = getRsquared(s, e, x, y)
        if isrow(x)
            x = x';
            y = y';
        end
        [r,gof] = fit(x(s:e),y(s:e),'exp1');
        adR2    = gof.adjrsquare;
%         disp(r);
end