function [x,t]=SEIRVaccineSolver(tspan,param,xinit)
%param=[beta,gammaE,gammaR];
%xinit=x(t=0)=[100 0 1 0 (for example)
%options1 = odeset('Refine',50,'NonNegative',5);
%to run call [x,t]=SEIRodeSolver(tspan,param,xinit)
%then plot(x,t,'LineWidth',2),grid on, xlabel(time)
options1 = odeset('NonNegative',20,"Refine",40);%all 20 parameters in the state vector are non-negative
Tmx=max(tspan);
Tmn=min(tspan);
[t,x] = ode45(@(t,x) SEIRode(t,x,param),[Tmn Tmx],xinit(:),options1);
end

function dxdt = SEIRode(t,x,params)
%x vec:
%  X: [S I H R D]
% x(1:4) = S,
% x(1) = SnVC, x(2)=SnVnC, x(3)= SVnC, x(4) = SVC
% dS/dt = -beta*I
% x(5:8) = I,
% x(5) = InVC, x(6) = InVnC, x(7) = IVnC, x(8) = IVC
% dI/dt = beta*I - gamma*I
% x(9:12) = H,
% x(9) = HnVC, x(10) = HnVnC, x(11) = HVnC, H(12) = HVC
% x(13:16) = R,
% x(13) = RnVC, x(14) = RnVnC, x(15) = RVnC, x(16) = RVC
% x(17:20) = D.
% x(17) = DnVC, x(18) = DnVnC, x(19) = DVnC, x(20) = DVC

% params: [betaVax, betaCautious, gamma, gamma_H, P_H, P_D]
% params(1:3):
% betaVax = [beta1, beta2, beta3],  infection rates.
% beta(1) = infection from Vaccinated-Vaccinated.
% beta(2) = infection rate Vaccinated-non Vaccinated.
% beta(3) = infection rate non-Vaccinated - non-Vaccinated.

% params(4:6):
% betaVax = [beta1, beta2, beta3],  infection rates.
% beta(1) = infection from Cautious-Cautious.
% beta(2) = infection rate Cautious-non Cautious.
% beta(3) = infection rate non-Cautious - non-Cautious.

% params(7:8):
% gamma: rate to transition out of I.
% gamma_H: rate to transition out of hospital.

% params(9:10):
% P_H: probability to move into hospital once finished with I.
% P_H(1): probability of hospitalization from non-Vaccinated.
% P_H(2): probability of hospitalization from Vaccinated.

% params(11:12):
% P_D: probability of death from hospital.
% P_D(1): death from Vaccinated.
% P_D(2): death from non-Vaccinated.

%param=[beta,gamma, gamma_H,P_H,P_D];

%---- definitions ---%

b = params(1:6);
bMat = [
    b(3)*b(4) b(3)*b(5) b(2)*b(5) b(2)*b(4);
    b(3)*b(5) b(3)*b(6) b(2)*b(6) b(2)*b(6);
    b(2)*b(5) b(2)*b(6) b(1)*b(6) b(1)*b(5);
    b(2)*b(4) b(2)*b(5) b(1)*b(5) b(1)*b(4);
    ];
g = params(7:8);
h = params(9:10);
d = params(11:12);

dxdt = [
    -x(1)*(bMat(1,:)*x(5:8));... % x(1) 
    -x(2)*(bMat(2,:)*x(5:8)); ...% x(2)
    -x(3)*(bMat(3,:)*x(5:8)); ...% x(3)
    -x(4)*(bMat(4,:)*x(5:8)); ...% x(4)
    +x(1)*(bMat(1,:)*x(5:8)) - x(5)*g(1);... % x(5)
    +x(2)*(bMat(2,:)*x(5:8)) - x(6)*g(1);... % x(6)
    +x(3)*(bMat(3,:)*x(5:8)) - x(7)*g(1);... % x(7)
    +x(4)*(bMat(4,:)*x(5:8)) - x(8)*g(1);... % x(8)
    +g(1)*h(1)*x(5) - g(2)*(g(2)*x(9) + (1-g(2))*x(9));... % x(9)
    +g(1)*h(1)*x(6) - g(2)*x(10);... % x(10)
    +g(1)*h(2)*x(7) - g(2)*x(11); ...% x(11)
    +g(1)*h(2)*x(8) - g(2)*x(12); ...% x(12)
    +g(1)*(1-h(1))*x(5) + g(2)*(1-d(1))*x(9);... % x(13)
    +g(1)*(1-h(1))*x(6) + g(2)*(1-d(1))*x(10); ...% x(14)
    +g(1)*(1-h(2))*x(7) + g(2)*(1-d(2))*x(11); ...% x(15)
    +g(1)*(1-h(2))*x(8) + g(2)*(1-d(2))*x(12);... % x(16)
    +g(2)*d(1)*x(9);... % x(17)
    +g(2)*d(1)*x(10);... % x(18)
    +g(2)*d(2)*x(11);... % x(19)
    +g(2)*d(2)*x(12);% x(20)
    ]; 
end

