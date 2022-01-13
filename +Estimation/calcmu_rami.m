% case 1. All exponential distributions with
% tauIB=1 day
% tauL = 3 days
% tauE = 4 days.
%
% case 2.  In Between duration distribution shifted exponential with tauIB=0.5 days and Tmin = 0.5 days
%       tauL = flat distribution from 2 to 4 days
%       tauE = flat distribution from 3 to 5 days.
%
% case 3. In Between duration distribution mixture of exponents p=90% with tauIB1=1, and with p=10% tauIB=1/5;
%       tauL = flat distribution from 2 to 4 days
%       tauE = flat distribution from 3 to 5 days.
%
% let's compare mu and qn. We should also compare with simulation results
mycase=1;
if mycase==1
    tauL=3;
    tauIB=1;
    tauE=4;
    if exist('nruns')==0
        nruns=1e6;
    end
    for k=1:nruns
        tl=exprnd(tauL);
        t=cumsum(exprnd(tauIB,1,1000));
        indtmp=find(t>tl,1);
        n(k)=indtmp-1;
    end
    [bn,qn]=myhist(n,0:1:200);
    %figure,semilogy(bn,qn,'o'),hold all,%semilogy(0:1:999,Y(1:end),'r'),shg
    %axis([0   100    1e-8    1.0000])
    mu_=linspace((log(2)/(1/100)),(log(2)./365),1e6);
    for kk=1:length(mu_)
        mu=mu_(kk);
        Pib=1./(1+mu*tauIB);
        Pe=1./(1+mu*tauE);
        f(kk)=Pib.*(Pe.*(1-sum(qn.*(Pib.^bn)))+1)-1;
    end
    [mn,mnind]=min(abs(f));
    muth=mu_(mnind);
    Tmu1=log(2)./muth;
    %muth1=0.1829;
elseif mycase==2
    tauL=3;
    tauIB=.5;TibMin=0.5;
    tauE=4;
    if exist('nruns')==0
        nruns=1e6;
    end
    for k=1:nruns
        tl=rand*2+2;
        t=cumsum(TibMin+exprnd(tauIB,1,1000));
        indtmp=find(t>tl,1);
        n(k)=indtmp-1;
    end
    [bn,qn]=myhist(n,0:1:200);
    %figure,semilogy(bn,qn,'o'),hold all,%semilogy(0:1:999,Y(1:end),'r'),shg
    %axis([0   100    1e-8    1.0000])
    mu_=linspace((log(2)/(1/100)),(log(2)./365),1e6);
    for kk=1:length(mu_)
        mu=mu_(kk);
        Pib=exp(-TibMin*mu)./(1+tauIB*mu);
        Pe=(exp(-3*mu)-exp(-5*mu))./(5-3)./mu;
        f(kk)=Pib.*(Pe.*(1-sum(qn.*(Pib.^bn)))+1)-1;
    end
    [mn,mnind]=min(abs(f));
    muth2=mu_(mnind);
    Tmu2=log(2)./muth2;
    %muth2= 0.1644;
elseif mycase==3
    tauL=3;
    tauIB1=1;tauIB2=1/5;
    tauIB1=1.1067;tauIB2=1/100;
    p1=0.9;p2=1-p1;
    tauE=4;
    if exist('nruns')==0
        nruns=1e6;
    end
    for k=1:nruns
        tl=rand*2+2;
        r=rand(1,1000);
        tmp=(r>=0.9).*exprnd(tauIB2,1,1000)+ (r<0.9).*exprnd(tauIB1,1,1000);
        t=cumsum(tmp);
        indtmp=find(t>tl,1);
        n(k)=indtmp-1;
    end
    [bn,qn]=myhist(n,0:1:200);
    %figure,semilogy(bn,qn,'o'),hold all,%semilogy(0:1:999,Y(1:end),'r'),shg
    %axis([0   100    1e-8    1.0000])
    mu_=linspace((log(2)/(1/100)),(log(2)./365),1e6);
    for kk=1:length(mu_)
        mu=mu_(kk);
        Pib=p1./(1+tauIB1*mu) + (1-p1)./(1+tauIB2*mu);
        Pe=(exp(-3*mu)-exp(-5*mu))./(5-3)./mu;
        f(kk)=Pib.*(Pe.*(1-sum(qn.*(Pib.^bn)))+1)-1;
    end
    [mn,mnind]=min(abs(f));
    muth3=mu_(mnind);
    Tmu3=log(2)./muth2;
    %muth3=  0.1971;
end
