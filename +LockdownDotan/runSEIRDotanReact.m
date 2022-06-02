function [x3,t3] = runSEIRDotanReact(xinit, param2,...
    TtoQuarantine, options1, isPlot)
    if nargin == 2
        TtoQuarantine = 60; 
    end
    if nargin <= 3
        % use default parameters:
        options1 = odeset('NonNegative',20,"Refine",40);
        isPlot = false;
    end
    loc = fileparts(mfilename("fullpath"));
    ext = load(fullfile(loc,"ExternalI.mat"));
    
    
    Tmx=TtoQuarantine;
    Tmn=0;
    [t3,x3] = ode45(@(t,x) mySEIRode_modified(t,x,param2,ext.tt,ext.iext),...
        [Tmn Tmx],xinit(:),options1);

    if isPlot == true
        
        S3=sum(x3(:,1:4),2);
        I3=sum(x3(:,5:8),2);
        H3=sum(x3(:,9:12),2);
        R3=sum(x3(:,13:16),2);
        D3=sum(x3(:,17:20),2);

        figure;
        plot(t3,H3,'LineWidth',2),hold all,plot(t3,I3,'LineWidth',2);
        hold all
    end
    
    param2(1:3)=param2(1:3)*0.76;
    Tmn=t3(end);
    Tmx=365 %TtoQuarantine+Tmn;
    [t4,x4] = ode45(@(t,x) mySEIRode_modified(t,x,param2,ext.tt,ext.iext),...
        [Tmn Tmx],x3(end,:)',options1);
    x3=[x3;x4];
    t3=[t3;t4];
    
end


function dxdt = mySEIRode_modified(t,x,params,tt,iext)
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


%dx(1)/dt = + param(10)*x(2)*Iext
%dx(2)/dt = - param(10)*x(2)*Iext


Iext=interp1(tt,iext,t,"pchip");
dxdt = [
    -x(1)*(params(1)*(x(5)+x(8))+params(2)*(x(6)+x(7))) + params(10)*x(2)*Iext/sum(x);... % x(1,4)
    -x(2)*(params(2)*(x(5)+x(8))+params(3)*(x(6)+x(7))) - params(10)*x(2)*Iext/sum(x); ...% x(2)
    -x(3)*(params(2)*(x(5)+x(8))+params(3)*(x(6)+x(7))); ...% x(3)
    -x(4)*(params(1)*(x(5)+x(8))+params(2)*(x(6)+x(7))); ...% x(4)
    x(1)*(params(1)*(x(5)+x(8))+params(2)*(x(6)+x(7))) - x(5)*params(4);... % x(5)
    x(2)*(params(2)*(x(5)+x(8))+params(3)*(x(6)+x(7))) - x(6)*params(4);... % x(6)
    x(3)*(params(2)*(x(5)+x(8))+params(3)*(x(6)+x(7))) - x(7)*params(4);... % x(7)
    x(4)*(params(1)*(x(5)+x(8))+params(2)*(x(6)+x(7))) - x(8)*params(4);... % x(8)
    +params(4)*params(6)*x(5) - params(5)*x(9);... % x(9)
    +params(4)*params(6)*x(6) - params(5)*x(10);... % x(10)
    +params(4)*params(7)*x(7) - params(5)*x(11); ...% x(11)
    +params(4)*params(7)*x(8) - params(5)*x(12); ...% x(12)
    +params(4)*(1-params(6))*x(5) + params(5)*(1-params(8))*x(9);... % x(13)
    +params(4)*(1-params(6))*x(6) + params(5)*(1-params(8))*x(10); ...% x(14)
    +params(4)*(1-params(7))*x(7) + params(5)*(1-params(9))*x(11); ...% x(15)
    +params(4)*(1-params(7))*x(8) + params(5)*(1-params(9))*x(12);... % x(16)
    +params(5)*params(8)*x(9);... % x(17)
    +params(5)*params(8)*x(10);... % x(18)
    +params(5)*params(9)*x(11);... % x(19)
    +params(5)*params(9)*x(12);]; % x(20)

% if any(x < -1e-3) || abs(sum(dxdt)) > 1e-6
%     error("negative number or non-consistent step");
% end
% dxdt =[-param(1)*x(1)*x(3);params(1)*x(1)*x(3)-params(2)*x(2);params(2)*x(2)-params(3)*x(3);param(3)*x(3)];
end