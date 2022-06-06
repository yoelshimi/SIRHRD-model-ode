function [bIsOutbreak] = isOutbreak(susceptibles, validTimes, n)
    % function for determining if an "outbreak" has taken place.
    if nargin == 1
        validTimes = 1 : length(susceptibles);
    end
    numberInf =  - diff(susceptibles([1 end]));
    [f0,~]        = fit(validTimes' / iterPerDay, ...
        susceptibles(validTimes)','exp1');
    rate = f0.b;
    ratio = numberInf / susceptibles(1);
    disp("growth rate: "+rate)
    disp("ratio: "+ratio)
    criteria1 = @(x) x > 0.1;
    criteria2 = @(x) x >= 0;
    bIsOutbreak = criteria1(ratio) && criteria2(rate);
end
