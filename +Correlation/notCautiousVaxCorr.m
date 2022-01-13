function mat = notCautiousVaxCorr(pS,pB,pNCgivenV) 
    % eqn 1: pS = a+b
    % eqn 2: pB = a+d
    % eqn 3: pNCgivenV = c / (c + d) 
    % eqn 4: a + b + c + d = 1
    % [b a; c d] = [snb sb; nsnb nsb]; => [nvnc nvc; vnc vc];
    %     p(NC|V) = c/(c+d)
    c = pNCgivenV .* (1 - pS);
    d = (1 - pS) - c;
    a = pB - d;
    b = pS - a;
    mat = [b a; c d];
    if abs(sum(mat(:))- 1) > eps * 10
        error("sum not 1!");
    end
end