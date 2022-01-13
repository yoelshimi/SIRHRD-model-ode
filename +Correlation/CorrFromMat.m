function [corr, fakeCorr] = CorrFromMat(mat)
    a = mat(1,2); b = mat(1,1); c = mat(2,1); d = mat(2,2);
    p = a + b; 
    q = a + d;
    corr = (a - p * q) / sqrt((p * (1 - p)) * (q * (1 - q)));
    fakeCorr = 2 * (a / (a + b)) - 1;
end