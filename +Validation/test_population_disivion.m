n = 21; m = 26; k = 51;
p_susc = linspace(0, 1, n);
p_cautious = linspace(0, 1, m);
p_not_cautious_if_at_risk = linspace(0, 1, k);
p_cautious_if_at_risk = 1 - p_not_cautious_if_at_risk;
% 4 for population, 1 for checking if valid.
pop_matrix = zeros(n, m, k, 6, "single"); 
n_combs = prod([n m k]);

blank = zeros(n_combs, 1, "single");
[x, y, z] = meshgrid(p_susc, p_cautious, p_not_cautious_if_at_risk);
resStruct = struct("p_susc", 0, "p_cautious", 0,...
    "p_not_cautious_if_at_risk", 0,...
    "RC", 0, "RnC", 0, "nRnC", 0, "nRC", 0, ...
    "isValid", 0);

for iter = 1 : n_combs
    [pop, isValid, err]           = nonSymCorr(x(iter), y(iter), z(iter));
    resStruct(iter).isValid       = isValid;
    resStruct(iter).RC            = pop(1, 2);
    resStruct(iter).RnC           = pop(1, 1);
    resStruct(iter).nRC           = pop(2, 2);
    resStruct(iter).nRnC          = pop(2, 1); 
    resStruct(iter).err           = err;
    resStruct(iter).p_susc        = x(iter);
    resStruct(iter).p_cautious    = y(iter);
    resStruct(iter).p_not_cautious_if_at_risk = z(iter);
end

for iter1 = 1 : n
    for iter2 = 1 : m
        for iter3 = 1 : k
            [pop, isValid, err] = nonSymCorr(p_susc(iter1),...
                p_cautious(iter2), p_not_cautious_if_at_risk(iter3));
            pop_matrix(iter1, iter2, iter3, :) = [pop(:); isValid; err];
        end
    end
end

close all
for iter = 1 : 5: n
    figure; imagesc(squeeze(pop_matrix(iter, :, :, 6)));
    title(p_susc(iter) * 100 + "% part Risk");
end