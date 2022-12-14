nTries = 5;
nDims = 10;
d = 17;
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
figure; plot(n, dOvern, "kx", "DisplayName", "d/n")
hold on; plot(n, mean(C, 1), "bo", "DisplayName", "Clustering coefficient")
legend();
xlabel("# nodes");
ylabel("Clst. coeff.");
title("clustering coeff. for random graphs.")
ax = gca;
ax.Color = "white";
GraphCode.saveGraph(gcf);