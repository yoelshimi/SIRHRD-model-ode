tspan=[0,365];
N0 = 9e6;
%x vec:
%  X: [S I H R D]
% x(1:4) = S,
% x(1) = Ssb, x(2)=Ssnb, x(3)= Snsnb, x(4) = Snsb
% x(5:8) = I,
% x(5) = Isb, x(6) = Isnb, x(7) = Insnb, x(8) = Insb
% x(9:12) = H,
% x(9) = Hsb, x(10) = Hsnb, x(11) = Hnsnb, H(12) = Hnsb
% x(13:16) = R,
% x(13) = Rsb, x(14) = Rsnb, x(15) = Rnsnb, x(16) = Rnsb
% x(17:20) = D.
% x(17) = Dsb, x(18) = Dsnb, x(19) = Dnsnb, x(20) = Dnsb

% params: [beta, gamma, gamma_H, P_H, P_D]
% params(1:3):
% beta = [beta1, beta2, beta3],  infection rates.
% beta(1) = infection from believer-believer.
% beta(2) = infection rate believer-non believer.
% beta(3) = infection rate non-believer - non-believer.

% params(4:5):
% gamma: rate to transition out of I.
% gamma_H: rate to transition out of hospital.
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
    xinit=[N0; N0; N0; N0; ones(4,1)*1e-3*N0/4; zeros(12,1)];
    xinit = xinit / sum(xinit) * N0; 
end
[x,t]=SEIRodeSolver_YR(tspan,param,xinit);
% plot(t,x,'LineWidth',2),grid on, xlabel('days'),shg

t_interp = tspan(1):1:tspan(2);
x_interp = interp1(t, x, t_interp);

graph_and_plot;