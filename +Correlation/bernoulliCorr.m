function mat = bernoulliCorr(varargin)

%     function for generating matrix for susceptible, believers from
%     probabilities of susceptibility and caution or believerness.
%     pS = probability of susceptible.
%     pB = "           "  believer.
%     covariance (B, S) = mean(B*S) - P(B) * P(S).
%     [SB SnB; nSB nSnB] = [a b; d c]
%     mat = [b a; c d];
    [rho,pS,pB] = fillValues(varargin);
    stdS = sqrt(pS * (1 - pS));
    stdB = sqrt(pB * (1 - pB));
    
    a = (pS - pS^2 - pS * pB) / (1 - 2 * pS)%  rho * stdS * stdB + pS * pB
    b = pS - a
    c = 1 - pS - pB + a
    d = pB - a

    mat = [b a; c d];
    if ~ all(verifyProb(mat(:)))
        mat = nan(2);
    end
%     mat  = fliplr([a b; d c])
end

function [rho,pS,pB] = fillValues(inputs)
%     auxiliary function for completion of pS or pB if missing.
% calls complete vals function.
    t = 0;
    rho = inputs{1};
    pS = inputs{2};
    if length(inputs) < 3
        % pB missing - solve q for p.
        pB = completeVals(rho, pS, "pB");
        t = pB;
    else
        pB = inputs{3};
    end
    
    
    if ~ verifyProb(pS)
        % pS wrong or missing - complete.
        pS = completeVals(rho, pB,"pS");
        t = pS;
    end
    
    if ~ verifyProb(t)
        throw("wrong values encountered");
    end
end

function y = completeVals(r, x, toSolve)
%  function for finding p or q from rho + p/q. returns valid result.
if ~ (verifyProb((r + 1) / 2) && verifyProb(x))
    throw("wrong value");
end

x2 = x^2;
r2 = r^2;
switch toSolve
    case "pS"
        q = x; q2 = x2; q3 = q^3; q4 = q2 ^ 2;
        numerator = 4 * q2 * r2 - 4 * q2 - 4 * q * r2 + 4 * q - 1;
        denumerator = 4 * q2 * r2 - 4 * q2 - 4 * q * r2 + 4 * q - 1;
        t = sqrt( -16 * q4 * r2 + 16 * q4 + 32 * q3 * r2 - 32 * q3...
            - 20 * q2 * r2 + 24 * q2 + 4 * q * r2 - 8 * q + 1);
    case "pB"
        p = x; p2 = p^2; r2 = r^2;
        numerator = 4 * p2 * r2 - 4 * p2 - 4 * p * r2 + 4 * p + r2;
        t = ((2 * p - 1) * r) ^ 2 * (4 * p2 * r2 - 4 * p2 - 4 * p * r2 + 4 * p + r2);
        denumerator = 4 * p2 * r2 - 4 * p2 - 4 * p * r2 + 4 * p + r2;
    otherwise
        throw("amskdmfls");
end
% numerator = x2 * r2 + 2 * x2 - x * r2 - 2; % fixed part of mone "b".
% denumerator = 2 *(x2  * r2 - r2 - x  * r2 - 2 * r - 1);
% t = (x2 - x) * r * sqrt(r2 + 8);
% two solutions - one probably valid.
y1 = (numerator + sqrt(t)) / (2 * denumerator);
y2 = (numerator - sqrt(t)) / (2 * denumerator);
% valid indices
valids = verifyProb([y1,y2]);
% final values
y = [y1 y2];
y = y(valids);
if diff(y) == 0
    y = y(1);
end
end


function bIsValid = verifyProb(x)
% function for checking if x is legal for probability.
    
    bIsValid = (x >= 0) & (x <=1);
end