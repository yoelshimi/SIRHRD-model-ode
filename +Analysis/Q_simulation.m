% see Q variance calc.docx from statistical materials
% num neighbors: d
d = 4;
FAMILY2POP = 3.3;
init_inf = 1e-2; % 1 percent.
N0 = 1e2; % population.
% avg. weight from structured graph
wmean = 1;%  d;%  1 %0.579;
R0 = 3;
gamma = 0.1;
beta = R0 * gamma;
beta_CnC = [1, 0.15, 0.05];
%  is 1 is cautious, the value will be 1.
weight_calc = @(is_C1, is_C2) ... 
    interp1([0, 1, 2], beta_CnC, single(is_C1) + single(is_C2), "linear");
% lambda_infection = @(w_ij) wmean / (beta * w_ij) ;
lambda_infection = @(w_ij) beta * w_ij / wmean;  % larger w_ij means stronger connection means faster infection.
P_infection = @(lmda_inf, lmda_rec) lmda_inf / (lmda_inf + lmda_rec);

P_infections = [P_infection(lambda_infection(weight_calc(true, true)), gamma),...
    P_infection(lambda_infection(weight_calc(true, false)), gamma),...
    P_infection(lambda_infection(weight_calc(false, false)), gamma)];

R0_mean = @(P_cautious)  d * (P_infections(1) * P_cautious ^ 2 + ...
    2 * P_infections(2) * P_cautious * (1 - P_cautious) + ...
    P_infections(3) * (1 - P_cautious) ^ 2);

P_to_Bernoulli_Var_fun = @(P) P .* (1 - P);
% rule of variance for bernoulli variables.

R0_var_old = @(P_cautious) d * (P_to_Bernoulli_Var_fun(P_infections(1)) * P_cautious ^ 2 + ...
    2 * P_to_Bernoulli_Var_fun(P_infections(2)) * P_cautious * (1 - P_cautious) + ...
    P_to_Bernoulli_Var_fun(P_infections (3)) * (1 - P_cautious) ^ 2);

% if we consider the random variable of infecting i.i.d to the random
% variable of being cautious, and that being a binomial variable with 2
% trials and P(C) chance, the V[XY] = V[X]V[Y] + V[X]E[Y]^2 + V[Y]E[X]^2.
var_X = @(P_cautious) (2 * P_cautious * (1 - P_cautious));
% R0_var = mean(var(Y | X)) + var( mean( Y | X))
% Y = a infects b, X = number of cautious: a is cautious + b is cautious.
% mean y | x = [P_infections(1) if x = 2, P_infections(2) if x = 1, P_infections(3), x = 0]
% mean x = P(cautious) * 2
% var y part 1 = var[mean[y given x]] = P(x=2)*(Xmean - mean y | x = 2)^ 2
mean_X = @(p_cautious) 2 * p_cautious;
var_mean_y_given_x = @(p_cautious) d * [p_cautious^2,p_cautious*(1-p_cautious),(1-p_cautious)^2] * ...
    ((mean_X(p_cautious) - P_infections).^2)';
mean_var_y_given_x = @(p_cautious) d * P_to_Bernoulli_Var_fun(P_infections) * ...
    [p_cautious^2,p_cautious*(1-p_cautious),(1-p_cautious)^2]';
% R0_var is var Y.
% law of total variance
R0_var = @(p_cautious) mean_var_y_given_x(p_cautious) + var_mean_y_given_x(p_cautious); 

% assumes: 0 < R0 ? 1 << V
Q = @(R0, V) 2 * (R0 - 1) / (R0^2 + V - R0);
q = @(P_Cautious) Q(R0_mean(P_Cautious), R0_var(P_Cautious));

gamma_decrease = @(P_Cautious) 1 - q(P_Cautious);
extinction_prob = @(P_Cautious) gamma_decrease(P_Cautious)  ^ round(init_inf * N0);

p_cautious = 0 : 0.01 : 1;
p_extinct = arrayfun(@(x) extinction_prob(x), p_cautious);
R0m = arrayfun(@(x) R0_mean(x), p_cautious);
R0v = arrayfun(@(x) R0_var(x), p_cautious);
% P_cautious = 0.3;
%%

disp(p_extinct);
inds = true(size(p_cautious));
f = figure; plot(p_cautious(inds), p_extinct(inds), "k-", "DisplayName", "P(extinct)", "LineWidth", 2);
xlabel("P(Caution)"); ylabel("P(extinct)"); 
hold on;
errorbar(p_cautious(inds), R0m(inds)-1, sqrt(R0v(inds)), "DisplayName", "R_0-1+\sigma(R_0)")
hold on; plot(p_cautious(inds)', zeros(size(p_cautious(inds))), "r--", "DisplayName", "R_0 = 1")
legend();
% ax = gca();
% % ax.Color = "w";
f.Color = "w";
title({'probability of extinction for caution';...
    ['0 < R_0 - 1 << V(infected), ', 'd = ',num2str(d)]})

disp("saved to: "+GraphCode.saveGraph(f))