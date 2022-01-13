tic;
X = random('gamma',25.68946395563771, 10.33643812300134,6e3,6e3);
toc

%  X = np.random.random((10000,10000))
X = X * X';
toc

for i = 1:1e1
    tic
    big_evals = eigs(X, i*3);
    disp(i)
    disp(big_evals)
    T(i) = toc;
end

[evals_all, evecs_all] = eig(X);
toc


% 
% #  print(np.sort(evals_all))
% #  print(time.perf_counter())
