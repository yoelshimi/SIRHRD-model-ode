function J = getJacobeanSIRHD(param, x)
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
b1 = param(1); b2 = param(2); b3 = param(3);
gamma = param(4);
gammaH = param(5);
pH1 = param(6); pH2 = param(7);
pD1 = param(8); pD2 = param(9);
S = x(1:4);
I = x(5:8);
H = x(9:12);
R = x(13:16);
D = x(17:20);
% -------dS/dx------%
%  ds/dt = -s*(b1/2*(I1+I4) + b2/3*(I2 + I3)) 
dS2dS = -diag([b1*(I(1)+I(4))+b2*(I(2)+I(3)),...
             b2*(I(1)+I(4))+b3*(I(2)+I(3)),...
             b2*(I(1)+I(4))+b3*(I(2)+I(3)),...
             b1*(I(1)+I(4))+b2*(I(2)+I(3))]);

dS2dI = -[b1*S(1) b2*S(2) b2*S(3) b1*S(4);...
         b2*S(1) b3*S(2) b3*S(3) b2*S(4);...
         b2*S(1) b3*S(2) b3*S(3) b2*S(4);...
         b1*S(1) b2*S(2) b2*S(3) b1*S(4)];

dS2dH = zeros(4);
dS2dR = zeros(4);
dS2dD = zeros(4);
% -------dI/dx------%
dI2dS =  [b1*I(1) b2*I(2) b2*I(3) b1*I(4);...
         b2*I(1) b3*I(2) b3*I(3) b2*I(4);...
         b2*I(1) b3*I(2) b3*I(3) b2*I(4);...
         b1*I(1) b2*I(2) b2*I(3) b1*I(4)];

dI2dI = diag([b1*(S(1)+S(4))+b2*(S(2)+S(3)),...
            b2*(S(1)+S(4))+b3*(S(2)+S(3)),...
            b2*(S(1)+S(4))+b3*(S(2)+S(3)),...
            b1*(S(1)+S(4))+b2*(S(2)+S(3))]);

dI2dH = -gamma*diag([pH1 pH1 pH2 pH2]);
dI2dR = -gamma*diag([(1-pH1) (1-pH1) (1-pH2) (1-pH2)]);
dI2dD = zeros(4);
% -------dH/dx------%
dH2dS = zeros(4);
dH2dI = -dI2dH;
dH2dH = zeros(4);
dH2dR = -gammaH*diag([1-pD1 1-pD1 1-pD2 1-pD2]);
dH2dD = -gammaH*diag([pD1 pD1 pD2 pD2]);
% -------dR/dx------%
dR2dS = zeros(4);
dR2dI = -dI2dR;
dR2dH = -dH2dR;
dR2dR = zeros(4);
dR2dD = zeros(4);
% -------dD/dx------%
dD2dS = zeros(4);
dD2dI = zeros(4);
dD2dH = -dH2dD;
dD2dR = zeros(4);
dD2dD = zeros(4);

dS = [dS2dS dS2dI dS2dH dS2dR dS2dD];
dI = [dI2dS dI2dI dI2dH dI2dR dI2dD];
dH = [dH2dS dH2dI dH2dH dH2dR dH2dD];
dR = [dR2dS dR2dI dR2dH dR2dR dR2dD];
dD = [dD2dS dD2dI dD2dH dD2dR dD2dD];

J  = [dS; dI; dH; dR; dD;];

end