function C = getDregClustering(n, d)
    %utility function that returns the clustering coefficient of d-regulat
    %graph.
    if  ismembertol(d, round(d), 1e-3) == false
        % this means the values arent whole integers.
        dlower = floor(d);
        dupper = ceil(d);
        clower = Classical.getDregClustering(n, dlower);
        cupper = Classical.getDregClustering(n, dupper);
        C      = interp1([dlower dupper], [clower cupper], d);
    else
        A = Classical.createRandRegGraph(n, d);
        C = trace(A^3) / (d * (d - 1) * n);
    end
    % lambda is the spectral gap.
%     lmda(iter, iter2, :) = eigs(A, 2);
end