% %--------------
% SIR_caution_odeSolver
% written by: Yoel Sanders
% date: 19.1.2021
% %--------------

% Example of running script:
% xinit = [1e4 1e4 1e1 1e1 0 0];
% p = [0.05*10 0.15*10 1*10 0.1 5 4];
% tspan = [0 60];
% p(1:3) = p(1:3) / sum(xinit);
% [x,t] = SIRodeSolver_yoel(tspan,p,xinit);
% figure; plot(t, x)

%%
function [x,t]=SIRodeSolverCaution(tspan,param,xinit)
%param=[beta,gamma,h,k];
%xinit=x(t=0)=[100 0 1 0 (for example)
%options1 = odeset('Refine',50,'NonNegative',5);
%to run call [x,t]=SEIRodeSolver(tspan,param,xinit)
%then plot(x,t,'LineWidth',2),grid on, xlabel(time)
options1 = odeset('NonNegative',6,"Refine",40);
%all 6 parameters in the state vector are non-negative
Tmx=max(tspan);
Tmn=min(tspan);
[t,x] = ode45(@(t,x) SIRode(t,x,param),[Tmn Tmx],xinit(:),options1);
end
%% 
function dxdt = SIRode(t,x,params)
% ode of SIR model for caution affected beta rate.
%x vec:
%  X: [S I R]
% x(1:2) = S,
% x(1) = Sc, x(2)=Snc
% x(3:4) = I,
% x(3) = Isc, x(4) = Isnc
% x(5:6) = R,
% x(5) = Rc, x(6) = Rnc

%param=[beta,gamma,h,k];
% params(1:3):
% beta = [beta1: c-c, beta2: c-nc, beta3: nc-nc],  infection rates.
% beta(1) = infection from Cautious-Cautious.
% beta(2) = infection rate Cautious-non Cautious.
% beta(3) = infection rate non-Cautious - non-Cautious.

% params(4):
% gamma: rate to transition out of I.
% params(5):
% h: exponent for calc of caution.
% params(6):
% k: lower number for sigmoid of caution

%param=[beta,gamma,h,k];

%---- definitions ---%
% DS
% dsb = - newly infected: beta(1:2)* Suscptible bb bnb * infected b nb

sigmoid= @(I,h,k) I^h/(I^h+k^h);
b_factor = sigmoid(x(3)+x(4), params(5), params(6));

dxdt = [-x(1)*(params(1)*x(3)+params(2)*x(4))*b_factor;...   % x(1)
    -x(2)*(params(2)*x(3)+params(3)*x(4))*b_factor; ...      % x(2)
    
    x(1)*(params(1)*x(3)+params(2)*x(4))*b_factor-params(4)*x(3);... % x(3)
    x(2)*(params(2)*x(3)+params(3)*x(4))*b_factor-params(4)*x(4);... % x(4)
    
    params(4)*x(3);...% x(5)
    params(4)*x(4)];% x(6)
end

