function [mat, valid, err] = nonSymCorr(pS,pB,pCgivenS)
    % pGivenS is between 0 to 1!
    % basic solution of correltaion matrix.
    % given: prob. Susceptible, prob. Cautious/believer, bayesian prob:
    % Cautious given Susceptible, range from 0 to 1!
    % eqn 1: pS = a+b
    % eqn 2: pB = a+d
    % eqn 3: pCgivenS = a / (a + b) 
    % eqn 4: a + b + c + d = 1
    % version as of 29.6.21
    % [1 0 1 0]*[b; c; a; d;] = pS
    % [0 0 1 1]*[b; c; a; d;] = pB
    % [pCgivenS 0 pCgivenS-1 0]*[b;c;a;b] = 0
    % [1 1 1 1]*[b; c; a; d;] = 1
    % [b a] = [RnC RC]
    % [c d] = [nRnC RnC]
    import Utilities.*
    groupVec = ["b" "c" "a" "d"];
    M = [1 0 1 0; ...
        0 0 1 1; ...
        pCgivenS 0 pCgivenS-1 0; ...
        1 1 1 1];
    x = [pS; pB; 0; 1];
    v = M\x;
    [b, c, a, d] = distributeOutputs(v);
    if pCgivenS < 0
        error("error! range is 0 to 1!")
    end
%     a2   = pCgivenS * pS;    % sb 
%     b2   = pS - a2;           % snb
%     d2   = pB - a2;           % nsb
%     c2   = 1 - a2 - b2 - d2;    % nsnb
%     if any(isEqualTol([b2 c2 a2 d2], [b c a d]) == false)
%         error("linalg wrong");
%     end
    mat = [b a;c d];
    v_inds = mat(:) < -eps;
    while any(v_inds)
        invalidInd = find(v_inds);
        if isEqualTol(mat(invalidInd), 0)
            mat(invalidInd) = 0;
            break;
        end
        eqnInd = 1:4;
        M = M([1 2 4], eqnInd(eqnInd~=invalidInd));
        x = x([1 2 4]);
        v = M\x;
        switch(groupVec(invalidInd))
            case "b"
                b = 0;
                [c, a, d] = distributeOutputs(v);
            case "c"
                c = 0;
                [b, a, d] = distributeOutputs(v);
            case "a"
                a = 0;
                [b, c, d] = distributeOutputs(v);
            case "d"
                d = 0;
                [b, c, a] = distributeOutputs(v);
            otherwise
                error("fahrk")
        end
        mat = [b a;c d];
        if any(mat < 0)
            error("still bad");
        end
        v_inds = mat(:) < 0;
    end
    if not(isEqualTol(a+b, pS) & isEqualTol(a+d, pB)...
            & isEqualTol(a+b+c+d, 1))
        valid = false;
        error("wrong");
    else
        valid = true;
    end
    % gives an estimate of how far off we were.
    err = abs(a / (a+b) - pCgivenS);
    if isnan(err)
        err = pCgivenS;
    end
end

