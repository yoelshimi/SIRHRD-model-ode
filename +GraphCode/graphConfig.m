oldDir = cd;
here = fileparts(which(mfilename));
% matlab path
cd(here)
here = split(here,'\');
addpath(genpath(fullfile(here{1:end-2})));
cd(oldDir)
close all
%   script to create graphs and calculations of Disease:
%  modeled
%  
tspan=[0,365];
N0 = 9e6;
parts_susc = [0.1:0.02:1];
Niters = 1e2+1;
Niters_susc = length(parts_susc);
corrs = linspace(-1,1,Niters);
init_inf = 1e-2;
gamma=1/10;
gammaH=1/20;
R=3;
%% 
% config conplete: 
% 
% Split into Params for ODE model.

beta=[0.05*R*gamma 0.15*R*gamma R*gamma];
% params(6:7):
% P_H: probability to move into hospital once finished with I.
% P_H(1): probability of hospitalization from Susceptible.
% P_H(2): probability of hospitalization from non-Susceptible.
pH=[0.2 0.2/10]
% params(8:9):
% P_D: probability of death from hospital.
% P_D(1): death from Susceptible.
% P_D(2): death from non-susceptible.
pD=[0.2 0.05]
%param=[beta,gamma, gamma_H,P_H,P_D];
% param=[1e-1.*[0.1 0.4 0.98 0.5 0.8] 0.1 0.01 0.1 0.01];
% param=[1/N0.*[0.015 0.045 0.3] 0.1 0.05 0.2 0.02 0.2 0.05];
param=[beta/N0 gamma gammaH pH pD]
% betas = R*gamma/N0
%% 
% config complete. initialize storage variables:
pop2percent = 100/N0;
Hosp = zeros(Niters,Niters_susc ,4);
Dead = zeros(Niters,Niters_susc,4);
TtoMaxParts = zeros(Niters,Niters_susc,4);
TtoMaxHosp = zeros(Niters,Niters_susc);
Correlation = zeros(Niters,Niters_susc,1);
not_s = zeros(Niters,Niters_susc,4);
%% 
% Main part: loop over Susceptible portion, and correlation.

for iter1 = 1:Niters
    for iter2 = 1:Niters_susc
%     [mat,C] = get_corr(1);
        C = corrs(iter1);
        mat = good_corr(C, parts_susc(iter2));
        sb = mat(1,2); snb = mat(1,1); nsnb = mat(2,1);nsb = mat(2,2);
        xinit_s = [sb*N0; snb*N0; nsnb*N0; nsb*N0;];
        xinit = [xinit_s; xinit_s*init_inf; zeros(12,1)];
        xinit = xinit / sum(xinit) * N0; 
        
        [x,t]=SEIRodeSolver_YR(tspan,param,xinit);
        % plot(t,x,'LineWidth',2),grid on, xlabel('days'),shg
        not_s(iter1,iter2,:) = xinit(1:4)' - x(end,1:4);
        % measure hospitalization for compartments
        [max_h,t_max_ind] = max(x(:,9:12));
        t_max_h = t(t_max_ind);
        Hosp(iter1,iter2,:) = max_h; %  ./ (x(1,1:4) + x(1,5:8));
        TtoMaxParts(iter1,iter2,:) = t_max_h;
        
        % measure hospitalization overall
         [~,t_max_ind] = max(sum(x(:,9:12),2));
        t_max_h = t(t_max_ind);
        TtoMaxHosp(iter1,iter2,:) = t_max_h;
        % 
        Dead(iter1,iter2,:) = x(end,17:20); %  ./ ((x(1,1:4) + x(1,5:8)).*reshape([pD;pD].*[pH;pH],1,4));
        Correlation(iter1,iter2) = (sb*nsnb - snb*nsb) / (sb*nsnb + snb*nsb);
%         snb_(iter1, iter2) = mat(1,1); sb_(iter1) = mat(1,2);
    end
end
%% 
sval_to_plot = [0.3 0.4];
prefix = ["rand";"agent"];
run_ind = 1:2
structure_fname = "test\"+prefix(run_ind)+"2 res for alpha 0 "+sval_to_plot+" susc.mat";
%     prefix(run_ind(1))+" res for alpha 0 "+sval_to_plot+" susc.mat";
% if length(run_ind)>1
%     structure_fname = [structure_fname "test\"+...
%         prefix(run_ind(2))+" res for alpha 0 "+sval_to_plot+" susc.mat"]
% end
colourcode = ["ks", "bo";"kd", "rx"]';
colourcode = colourcode(run_ind,:)

%%
% configs colormaps
Ncolours = 15;
c1       = [112 172 105]/1.2;
c2       = [255 220 140];
c3       = [97 82 52]/1.2;
cmap     = arrayfun(@(x) linspace(single(c1(x))/256, single(c2(x))/256, Ncolours/2+1), 1:length(c2), 'UniformOutput', false);
cmap     = cell2mat(cmap')';
tcmp     = arrayfun(@(x) linspace(single(c2(x))/256, single(c3(x))/256, Ncolours/2+1), 1:length(c2), 'UniformOutput', false);
tcmp     = cell2mat(tcmp')';
cmap     = [cmap; tcmp(2:end,:)];