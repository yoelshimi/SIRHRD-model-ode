% script to create graphs and calculations of Disease:
% modeled

tspan=[0,365];
N0 = 9e6;
parts_susc = 0.3;
Niters = 4e2+1;
Niters_susc = length(parts_susc);
corrs = linspace(-1,1,Niters);
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
Hosp = zeros(Niters,Niters_susc ,4);
Dead = zeros(Niters,Niters_susc,4);
TtoMaxParts = zeros(Niters,Niters_susc,4);
TtoMaxHosp = zeros(Niters,Niters_susc);
Correlation = zeros(Niters,Niters_susc,1);

for iter1 = 1:Niters
    for iter2 = 1:Niters_susc
%     [mat,C] = get_corr(1);
        C = corrs(iter1);
        mat = good_corr(C, parts_susc(iter2));
        sb = mat(1,2); snb = mat(1,1); nsnb = mat(2,1);nsb = mat(2,2);
        xinit = [sb*N0; snb*N0; nsnb*N0; nsb*N0; ones(4,1)*init_inf*N0/4; zeros(12,1)];
        xinit = xinit / sum(xinit) * N0; 
        
        [x,t]=SEIRodeSolver_YR(tspan,param,xinit);
        % plot(t,x,'LineWidth',2),grid on, xlabel('days'),shg
        
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
ts = ["sb" "snb" "nsnb" "nsb"];
figure;
for i = 1:4
subplot(2,2,i); pcolor(parts_susc,corrs,Dead(:,:,i)); shading flat ; xlabel("Susceptible Fraction");
ylabel("Correlation");
title(ts(i)+" Dead"); colorbar;caxis([0 1e5]);
end
%%

t_interp = tspan(1):1:tspan(2);
x_interp = interp1(t, x, t_interp);

graph_and_plot;
%%
ts = ["sb" "snb" "nsnb" "nsb"];
S_ind = 13
figure; plot(corrs,squeeze(Dead(:,S_ind,:)));
hold on; plot(corrs,sum(Dead(:,S_ind,:),3));
title("Dead for "+S_ind+" part susctible");
legend([ts, "sum"])
xlabel("Correlation"); ylabel("# Dead");

%%
figure; scatter(corrs,squeeze(Hosp(:,3,:)),'ko');
% hold on; plot(corrs, snb_/0.3*1e5)
title(["Dead and Hosp for Correlations";"Susc: "+part_susceptible+" init inf: "+init_inf])


%% 
if 0
    disp("equality Susc. val for Dead: ")
    d = fminbnd(@(x) abs(RunCorr(x,1,0) - RunCorr(x,-1,0)), 0.01, 1, optimset('TolX', 1e-7))
    % 
end
% disp("equality Susc. val for Hosp: ")
% fminbnd(@(x) RunCorr(x,1,1), 0.01, 1, optimset('TolX', 1e-7))
equality_S_val_dead = 0.348543421210721;
[~,x1,t1]=RunCorr(equality_S_val_dead,1);
[~,x0,t0]=RunCorr(equality_S_val_dead,0);
[~,x_1,t_1]=RunCorr(equality_S_val_dead,-1);
figure; semilogy(t1,x1(:,9:12)); hold on;
semilogy(t0,x0(:,9:12)); hold on;
semilogy(t_1,x_1(:,9:12)); xlim([0,50])

function [d,x,t] = RunCorr(Susc, C, d_or_h, param, N0, init_inf, tspan)
    if nargin == 2
        d_or_h = 0; %dead
    end
    if nargin <= 3
        N0 = 9000000;
        init_inf = 0.01;
        tspan = [0   365];
        param = [1.66e-09,5.00e-09,3.33e-08,0.100,0.0500,0.20,0.020,0.20,0.050];
    end
    
    if(d_or_h)
        inds = 9:12;
    else
        inds = 17:20;
    end
    mat = good_corr(C, Susc);
    sb = mat(1,2); snb = mat(1,1); nsnb = mat(2,1);nsb = mat(2,2);
    xinit = [sb*N0; snb*N0; nsnb*N0; nsb*N0; ones(4,1)*init_inf*N0/4; zeros(12,1)];
    xinit = xinit / sum(xinit) * N0; 
    [x,t]=SEIRodeSolver_YR(tspan,param,xinit);
    
    d = sum(x(end,inds),2);
    
end

