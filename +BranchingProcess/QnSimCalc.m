function qn = QnSimCalc
syms t p lambda1 lambda2 r lambdaL1 lambdaL2  tau_l n
% n = 5;
p=0.95;
lambda1 = 10; lambda2 = 18^-1;
lambdaL1 = 3^-1; lambdaL2 = 13^-1; r = 0.9;
Pib(t) = p*lambda1*exp(-lambda1*t) + (1-p)*exp(-lambda2*t);
Pib_l(t) = laplace(Pib,t);
P_l(tau_l) = r*lambdaL1*exp(-lambdaL1*tau_l) + (1-r)*exp(-lambdaL2*tau_l);
% integrand = ilaplace

f1(tau_l) = int(ilaplace(Pib_l(t).^n * (1-Pib_l(t)), t),t,0,tau_l );
qn = int(P_l(tau_l) * f1(tau_l), tau_l, 0, +inf);
end