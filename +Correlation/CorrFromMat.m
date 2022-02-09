function [pCifR, RnC, RC] = CorrFromMat(mat)
    a = mat(1,2); b = mat(1,1); c = mat(2,1); d = mat(2,2);
    RC = a;
    RnC = b;
    pCifR = a / (a + b);
end