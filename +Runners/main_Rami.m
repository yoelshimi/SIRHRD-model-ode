tspan=[0,30*6];
N0 = 9e6;
i0=1000;
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
% beta = [beta1, beta2, beta3], infection rates.
% beta(1) = infection from believer-believer.
% beta(2) = infection rate believer-non believer.
% beta(3) = infection rate non-believer - non-believer.
%non-believer thinks corona is a hoax...
%believer take corona seriously
gamma=1/10;
gammaH=1/20;
R=3;
beta=[0.05*R*gamma,0.15*R*gamma,R*gamma];
% params(4:5):
% gamma: rate to transition out of I.
% gamma_H: rate to transition out of hospital.

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
param=[beta/N0 gamma gammaH pH pD]
%param=[1/N0.*[0 0.3 0] 0.1 0.1 0.1 0.1 0 0];
xinit=[(N0/4-i0)*ones(4,1); i0*ones(4,1); zeros(20-8,1)];
[x,t]=SEIRodeSolver_YR(tspan,param,xinit);
plot(t,x(:,9:12),'LineWidth',2),grid on, xlabel('days'),shg
%semilogy(t,sum(x(:,1:4),2),'LineWidth',2),hold all
%semilogy(t,sum(x(:,5:8),2),'LineWidth',2),grid on, xlabel('days'),shg
legend
