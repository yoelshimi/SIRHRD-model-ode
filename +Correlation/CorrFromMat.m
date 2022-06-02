function [RnC, RC, pCifR] = CorrFromMat(mat)
% retrieves correlation data from matrix or vector.
    if isvector(mat)
        a = mat(1); % RC
        b = mat(2); % RnC
        N0 = sum(mat);
    else
        a = mat(1,2); % RC
        b = mat(1,1); % RnC
        c = mat(2,1); % nRnC
        d = mat(2,2); % nRC
        N0 = sum(mat(:));
    end
    RC = a / N0;
    RnC = b / N0;
    pCifR = a / (a + b);
end