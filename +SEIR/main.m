nvar=7;%
options1 = odeset('Refine',50);
options2 = odeset(options1,'NonNegative',nvar);
N=(8.8e6);
beta=8*log(2)/31.4;
T=50;
beta=beta*[1 0;0 1]/N;
gammaE=(1/5)*[1 1];
gammaR=(1/4)*[1 1];
yinit=[N-1.5e5-5,1.5e5,0,0,5,0,0];
[t,y] = ode45(@(t,y) SEIR_modelNtwo(t,y,beta,gammaE,gammaR),[0 T],yinit);
figure
plot(t,y(:,5),'LineWidth',2),grid on,shg