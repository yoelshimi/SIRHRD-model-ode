nTries = 5;
nDims = 25;
d = 12;
C = zeros(nTries, nDims);
lmda = zeros(nTries, nDims, 2);
for iter = 1 : nTries
    for iter2 = 1 : nDims
        n = round(10^(2+iter2/10));
        A = Classical.createRandRegGraph(n, d);
%         s = sum(A);
%         C(iter, iter2) = trace(A^3) / (s * (s - 1)');
        C(iter, iter2) = trace(A^3) / (d * (d - 1) * n);
        lmda(iter, iter2, :) = eigs(A, 2);
    end
    disp(iter)
end

% note that d / n -> clustering coefficient for random graphs.
% also, that the spectral gap -> 0 for random graphs, and thus is a measure
% of randomness of a graph.x
n = round(10.^(2+(1:nDims)/10));
dOvern = d ./ n;
figure; plot(dOvern, "kx")
hold on; plot(mean(C, 1), "bo")