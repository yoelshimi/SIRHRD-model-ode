function mat = berSymCorrFromPS(rho, pS)
%     eqn 1: a / p = c / (1 - p)
%     eqn 2: corr(S,B) = cov(S, B) / (std(S) * std(B)) = a+pq /
%     (sqrt(p(1-p)*q(1-q));
%     eqn 3: a + b + c + d = 1
%   p = p(S) = a+b
%   q = p(B) = a+d
% we get from the eqn the following:
% q^2*p + q * (2pa + p^2 - p) + a^2 = 0
p = pS;
q = roots([p, 2 * p * a + p^2 - p, a^2]);
    
end