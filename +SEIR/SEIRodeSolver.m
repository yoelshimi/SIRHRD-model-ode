function [x,t]=SEIRodeSolver(tspan,param,xinit)
%param=[beta,gammaE,gammaR];
%xinit=x(t=0)=[100 0 1 0 (for example)
%options1 = odeset('Refine',50,'NonNegative',5);
%to run call [x,t]=SEIRodeSolver(tspan,param,xinit)
%then plot(x,t,'LineWidth',2),grid on, xlabel(time)
options1 = odeset('NonNegative',20,"Refine",10);%all 20 parameters in the state vector are non-negative
Tmx=max(tspan);
Tmn=min(tspan);
[t,x] = ode45(@(t,x) SEIRode(t,x,param),[Tmn Tmx],xinit(:),options1);
end

function dxdt = SEIRode(t,x,params)
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

% params(6:7):
% P_H: probability to move into hospital once finished with I.
% P_H(1): probability of hospitalization from Susceptible.
% P_H(2): probability of hospitalization from non-Susceptible.

% params(8:9):
% P_D: probability of death from hospital.
% P_D(1): death from Susceptible.
% P_D(2): death from non-susceptible.

%param=[beta,gamma, gamma_H,P_H,P_D];

%---- definitions ---%
% DS
% dsb = - newly infected: beta(1:2)* Suscptible bb bnb * infected b nb
dSsb    = x(1)*(params(1)*(x(5)+x(8))+params(2)*(x(6)+x(7))); % x(1,4)
dSsnb   = x(2)*(params(2)*(x(5)+x(8))+params(3)*(x(6)+x(7))); % x(2)
dSnsnb  = x(3)*(params(2)*(x(5)+x(8))+params(3)*(x(6)+x(7))); % x(3)
dSnsb   = x(4)*(params(1)*(x(5)+x(8))+params(2)*(x(6)+x(7))); % x(4)
dSdt    = [-dSsb; -dSsnb; -dSnsnb; -dSnsb];

%DI
dIsb    = dSsb - x(5)*params(4); % x(5)
dIsnb   = dSsnb - x(6)*params(4); % x(6)
dInsnb  = dSnsnb - x(7)*params(4); % x(7)
dInsb   = dSnsb - x(8)*params(4); % x(8)

dI = [dIsb; dIsnb; dInsnb; dInsb];

% dH
dHsb    = +params(4)*params(6)*x(5) - params(5)*(params(8)*x(9) + (1-params(8))*x(9)); % x(9)
dHsnb   = +params(4)*params(6)*x(6) - params(5)*x(10); % x(10)
dHnsnb  = +params(4)*params(7)*x(7) - params(5)*x(11); % x(11)
dHnsb   = +params(4)*params(7)*x(8) - params(5)*x(12); % x(12)

dH = [dHsb; dHsnb; dHnsnb; dHnsb];

% dR
dRsb    = +params(4)*(1-params(6))*x(5) + params(5)*(1-params(8))*x(9); % x(13)
dRsnb   = +params(4)*(1-params(6))*x(6) + params(5)*(1-params(8))*x(10); % x(14)
dRnsnb  = +params(4)*(1-params(7))*x(7) + params(5)*(1-params(9))*x(11); % x(15)
dRnsb   = +params(4)*(1-params(7))*x(8) + params(5)*(1-params(9))*x(12); % x(16)

dR = [dRsb; dRsnb; dRnsnb; dRnsb];

%dD
dDsb    = +params(5)*params(8)*x(9); % x(17)
dDsnb   = +params(5)*params(8)*x(10); % x(18)
dDnsnb  = +params(5)*params(9)*x(11); % x(19)
dDnsb   = +params(5)*params(9)*x(12); % x(20)

dD = [dDsb; dDsnb; dDnsnb; dDnsb];
dxdt = [dSdt; dI; dH; dR; dD];
disp(sum(dxdt));

dxdt = [-x(1)*(params(1)*(x(5)+x(8))+params(2)*(x(6)+x(7)));... % x(1,4)
-x(2)*(params(2)*(x(5)+x(8))+params(3)*(x(6)+x(7))); ...% x(2)
-x(3)*(params(2)*(x(5)+x(8))+params(3)*(x(6)+x(7))); ...% x(3)
-x(4)*(params(1)*(x(5)+x(8))+params(2)*(x(6)+x(7))); ...% x(4)
x(1)*(params(1)*(x(5)+x(8))+params(2)*(x(6)+x(7)))- x(5)*params(4);... % x(5)
x(2)*(params(2)*(x(5)+x(8))+params(3)*(x(6)+x(7))) - x(6)*params(4);... % x(6)
x(3)*(params(2)*(x(5)+x(8))+params(3)*(x(6)+x(7))) - x(7)*params(4);... % x(7)
x(4)*(params(1)*(x(5)+x(8))+params(2)*(x(6)+x(7))) - x(8)*params(4);... % x(8)
params(4)*params(6)*x(5) - params(5)*(params(8)*x(9) + (1-params(8))*x(9));... % x(9)
 +params(4)*params(6)*x(6) - params(5)*x(10);... % x(10)
 +params(4)*params(7)*x(7) - params(5)*x(11); ...% x(11)
+params(4)*params(7)*x(8) - params(5)*x(12); ...% x(12)
+params(4)*(1-params(6))*x(5) + params(5)*(1-params(8))*x(9);... % x(13)
params(4)*(1-params(6))*x(6) + params(5)*(1-params(8))*x(10); ...% x(14)
+params(4)*(1-params(7))*x(7) + params(5)*(1-params(9))*x(11); ...% x(15)
 +params(4)*(1-params(7))*x(8) + params(5)*(1-params(9))*x(12);... % x(16)
+params(5)*params(8)*x(9);... % x(17)
 +params(5)*params(8)*x(10);... % x(18)
 +params(5)*params(9)*x(11);... % x(19)
 +params(5)*params(9)*x(12);]; % x(20)

% dxdt =[-param(1)*x(1)*x(3);params(1)*x(1)*x(3)-params(2)*x(2);params(2)*x(2)-params(3)*x(3);param(3)*x(3)];
end

