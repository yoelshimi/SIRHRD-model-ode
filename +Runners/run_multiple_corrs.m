tspan=[0,365];
N0 = 9e6;
Niters = 1e3+1;
corrs = linspace(-1,1,Niters);
part_susceptible = 0.3;
init_inf = 1e-2;
gamma=1/10;
gammaH=1/20;
R=3;
beta=[0.05*R*gamma,0.15*R*gamma,R*gamma];
% params(6:7):
% P_H: probability to move into hospital once finished with I.
% P_H(1): probability of hospitalization from Susceptible.
% P_H(2): probability of hospitalization from non-Susceptible.
pH=[0.2,0.2/10]
% params(8:9):
% P_D: probability of death from hospital.
% P_D(1): death from Susceptible.
% P_D(2): death from non-susceptible.
pD=[0.2,0.05]
%param=[beta,gamma, gamma_H,P_H,P_D];
% param=[1e-1.*[0.1 0.4 0.98 0.5 0.8] 0.1 0.01 0.1 0.01];
% param=[1/N0.*[0.015 0.045 0.3] 0.1 0.05 0.2 0.02 0.2 0.05];
param=[beta/N0 gamma gammaH pH pD]
% betas = R*gamma/N0
if ~exist('xinit','var')
    xinit=[N0; N0; N0; N0; ones(4,1)*init_inf*N0/4; zeros(12,1)];
    xinit = xinit / sum(xinit) * N0;
end
Hosp = zeros(Niters,2);
Dead = zeros(Niters,1);
Correlation = zeros(Niters,1);
for iter = 1:Niters
%     [mat,C] = get_corr(1);
    C = corrs(iter);
    mat = good_corr(C, part_susceptible);
    sb = mat(1,2); snb = mat(1,1); nsnb = mat(2,1);nsb = mat(2,2);
    xinit = [sb*N0; snb*N0; nsnb*N0; nsb*N0; ones(4,1)*init_inf*N0/4; zeros(12,1)];
    xinit = xinit / sum(xinit) * N0; 
    [x,t]=SEIRodeSolver_YR(tspan,param,xinit);
    % plot(t,x,'LineWidth',2),grid on, xlabel('days'),shg
    [max_h,t_max_ind] = max(sum(x(:,9:12),2));
    t_max_h = t(t_max_ind);
    dead_overall = sum(x(end,17:20),2);
    Hosp(iter,:) = [t_max_h,max_h];
    Dead(iter) = dead_overall;
    Correlation(iter) = (sb*nsnb - snb*nsb) / (sb*nsnb + snb*nsb);
    snb_(iter) = mat(1,1); sb_(iter) = mat(1,2);
end

%%

t_interp = tsp;
x_interp = interp1(t, x, t_interp);

graph_and_plot;
%%
figure; scatter(corrs,Hosp(:,2),'rx'); hold on; scatter(corrs,Dead,'ko');
hold on; plot(corrs, snb_/0.3*1e5)
title(["Dead and Hosp for Correlations";"Susc: "+part_susceptible+" init inf: "+init_inf])

