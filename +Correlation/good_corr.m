function mat = good_corr(C, hyp)
%  correlation matrix for given symmetric relationship 
% assumes bayesian symmetry
% P(sensitive) = a+b = hyp
% P(Believer) = a+d = hyp
% written by Yoel 8.1.20

if nargin==1
    hyp = 0.3;
end
C = (C + 1) / 2;
a = hyp * C;
% a+b = P(S)
b = hyp - a;
% P(B|S) = P(nB|nS), a/a+b = c/c+d, a+b=P(s),c+d=P(nS) = 1-P(S)
c = (1-hyp) * C;
%  d=1-a-b-c, a+b = P(S)
d = 1-a-b-c;
mat = [b a;c d];
mat = mat / sum(mat(:));
