%%
N0 = 9e6;
parts_susc = linspace(0,1,101);
% union(0.1:0.1:1,0.25:0.05:0.4);
% parts_cautious = 0:0.1:1;
NitersRisk = length(parts_susc);
% assumes caution == risk
parts_cautious = nan;
NitersCautious = length(parts_cautious);
NitersCorr = 201;
pBfromS = linspace(0, 1, NitersCorr);
init_inf = 1e-6;
alpha = 0;
gamma=1/10;
gammaH=1/20;
R=3;
tspan = [0 365];
calcFactor = 0.1;
model = "SEIR";
%% 
% config conplete: 
% 
% Split into Params for ODE model.

beta=[0.05*R*gamma 0.15*R*gamma R*gamma];
% params(6:7):
% P_H: probability to move into hospital once finished with I.
% P_H(1): probability of hospitalization from Susceptible.
% P_H(2): probability of hospitalization from non-Susceptible.
pH=[0.2 0.2/10];
% params(8:9):
% P_D: probability of death from hospital.
% P_D(1): death from Susceptible.
% P_D(2): death from non-susceptible.
pD=[0.2 0.05];
%param=[beta,gamma, gamma_H,P_H,P_D];
% param=[1e-1.*[0.1 0.4 0.98 0.5 0.8] 0.1 0.01 0.1 0.01];
% param=[1/N0.*[0.015 0.045 0.3] 0.1 0.05 0.2 0.02 0.2 0.05];
param=[beta/N0 gamma gammaH pH pD]
% betas = R*gamma/N0
%% 
% config complete. initialize storage variables:
pop2percent = 100 / N0;
Hosp        = zeros(NitersRisk, NitersCautious, NitersCorr,4);
Dead        = zeros(NitersRisk, NitersCautious, NitersCorr,4);
TtoMaxParts = zeros(NitersRisk, NitersCautious, NitersCorr,4);
TtoMaxHosp  = zeros(NitersRisk, NitersCautious, NitersCorr);
Correlation = zeros(NitersRisk, NitersCautious, NitersCorr,1);
not_s       = zeros(NitersRisk, NitersCautious, NitersCorr,4);
grRate      = zeros(NitersRisk, NitersCautious, NitersCorr,3);
%% 
% Main part: loop over Susceptible portion, and correlation.
tic;
cnt = 1;
for iter1 = 1:NitersRisk
    for iter2 = 1:NitersCautious
        parts_cautious =  1 - parts_susc(iter1); 
        % !! NOTICE this 29.12.21
        validCorrs   = getMinMaxCorrs(parts_susc(iter1), parts_cautious);
        pBfromSvalid = pBfromS(pBfromS >= validCorrs.minCorr & ...
            pBfromS <= validCorrs.maxCorr);
        NitersCorrValid = numel(pBfromSvalid);
        for iter3 = 1:NitersCorrValid
             %     [mat,C] = get_corr(1);
            
            % probability of cautious if not at risk.
            mat      = nonSymCorr(parts_susc(iter1), parts_cautious, pBfromSvalid(iter3));
            sb       = mat(1,2); snb = mat(1,1); nsnb = mat(2,1);nsb = mat(2,2);
            notation = ["RnC" "RC"; "nRnC" "nRC"];
            xinit_s  = [sb*N0; snb*N0; nsnb*N0; nsb*N0;];
            xinit    = [xinit_s; xinit_s*init_inf; zeros(12,1)];
            xinit    = xinit / sum(xinit) * N0; 

            % call numerical function.
            switch model
                case "quarantineReact"
                    param(10) = 0.8; % connection factor
                    [x,t] = runSEIRDotanReact(xinit, param);
                case "quarantineNoReact"
                    [x,t] = runSEIRDotanNotReact(xinit,param);
                otherwise
                    [x,t]=SEIRodeSolver_YR(tspan,param,xinit);
            end
            
            % plot(t,x,'LineWidth',2),grid on, xlabel('days'),shg
            not_s(iter1,iter2,iter3,:) = xinit(1:4)' - x(end,1:4);
            % measure hospitalization for compartments
            [max_i,t_max_ind] = max(x(:,5:8));
            t_max_i = t(t_max_ind);
            
            TtoMaxParts(iter1,iter2,iter3,:) = t_max_i;
%             infected(iter1) = {sum(x(:,5:8),2)};
            % measure hospitalization overall
             [~,t_max_ind] = max(sum(x(:,9:12),2));
            t_max_h = t(t_max_ind);
            TtoMaxHosp(iter1,iter2,iter3,:) = t_max_h;
            Hosp(iter1,iter2,iter3,:) = x(t_max_ind,9:12);...
                %  ./ (x(1,1:4) + x(1,5:8));
            % 
            Dead(iter1,iter2,iter3,:) = x(end,17:20); 
            %  ./ ((x(1,1:4) + x(1,5:8)).*reshape([pD;pD].*[pH;pH],1,4));
            Correlation(iter1,iter2,iter3) = (sb*nsnb - snb*nsb);
    %         snb_(iter1, iter2) = mat(1,1); sb_(iter1) = mat(1,2);
            infs = sum(x(:,5:8),2);
            [f0,gof] = calcGrowth(t, infs,  tspan, calcFactor);
            grRate(iter1,iter2,iter3,:) = [f0.a, f0.b, gof.adjrsquare];
            R0MOH = calcR0MOH(infs, t);
            cfg = struct("corr",pBfromSvalid(iter3),...
                "pop",mat,"notation", notation, ...
                "sim_duration",tspan,"p_risk",parts_susc(iter1),...
                "p_cautious",parts_cautious(iter2),"alpha",alpha,...
                "beta",R,"gamma",gamma,"b_l",beta,"gammaH",gammaH,...
                "p_h_l",pH,"pD_l",pD,"R0",squeeze(grRate(iter1,iter2,iter3,:)),...
                "hosp",squeeze(Hosp(iter1,iter2,iter3,:)),"dead",...
                squeeze(Dead(iter1,iter2,iter3,:)),"peakInfT",...
                squeeze(TtoMaxParts(iter1,iter2,iter3,:)),"peakInf",max_i,...
                "sick",squeeze(not_s(iter1,iter2,iter3,:)),...
                "inf", init_inf,"N0",N0, "R0matlab", R0MOH);
            
            fixed2table();
            cnt = cnt + 1;
        end
    end
end
SimT.nCifR = 1 - SimT.corr;
toc
%%
figure; 
cautiousInd = 1;
% pcolor(pBfromS', parts_susc', squeeze(grRate(:,:,cautiousInd,2))')
plot(pBfromS', squeeze(grRate(:,:,cautiousInd,2))',"p")
title("R0 rate for corr and susc, caution: "+parts_cautious(cautiousInd))
xlabel("corr");
ylabel("susc");
% clear f
% clear q
% for iter = 1:length(sizes)
% t1 = t(1:sizes(iter));
% I1 = I(1:sizes(iter));
% [f{iter},q{iter}] = fit(t1,I1,'exp1');
% end
% for iter = 1:5
% for iter2 = 1:length(sizes)
% subplot(5,1,iter); hold on;
% loglog(sizes(iter2),q{iter2}.(ps{iter}), 'kx');
% title(ps{iter});
% hold on;
% end
% end