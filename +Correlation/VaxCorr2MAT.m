function mat = VaxCorr2MAT(pS,pNCgivenV) 
    % eqn 1: pS = a+b
    % eqn 2: all those not vaccinated - don't care
    % eqn 2: a = 0;
    % eqn 3: pNCgivenV = c / (c + d) 
    % eqn 4: a + b + c + d = 1
    % [b a; c d] = [snb sb; nsnb nsb]; => [nvnc nvc; vnc vc];
    %     p(NC|V) = c/(c+d)
    c = pNCgivenV .* (1 - pS);
    d = (1 - pS) - c;
    a = 0;
    b = pS;
    mat = [b a; c d];
    if abs(sum(mat(:))- 1) > eps * 10
        error("sum not 1!");
    end
end