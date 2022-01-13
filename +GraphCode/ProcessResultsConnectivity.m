%process results
load rnddreg_results
if 0
    
    close all
    
    for k=1:length(d_)
        clear x y
        x=t_{k};
        y=I_{k};
        [mx,mxind]=max(y);
        ind=find(y>100,1);
        ind0=find(y>0);
        x=x(1:ind);
        y=y(1:ind);
        x=x(y>0);
        y=y(y>0);
        %y=log(y);
        if length(x)>1
            [fitresult, gof] = myexpfit(x, y);
            r2(k)=gof.adjrsquare;
            figure,
            semilogy(t_{k},I_{k},'.r'),hold all
            p=polyfit(x,y,1);
            mu_(k)=fitresult.b;
            semilogy(x(y<mx),fitresult.a*exp(mu_(k)*x(y<mx)),'--k','LineWidth',2)
        end
    end
    %save rnddreg_results t_h I_h d_ mu_
else
    for k=1:length(d_)
        %calculate growth rate
        %for expoential case only we have:
        n_=0:1:300;
        s=(1e-6):(1e-6):3;
        %cv=(std(sum(G>0,2)))./mean(sum(G>0,2));
        tauE=3;
        tauL=5;
        tauIB=tauL/2;
        tauib=2.333*tauIB/d_(k);
        qn=(tauib/tauL)./(1+(tauib/tauL)).^(n_+1);
        Pib=1./(1+s*tauib);
        L=0*Pib;
        for k1=1:length(n_)
            L=L+qn(k1)*Pib.^(k1);
        end
        PE=1./(1+tauE*s);
        minF=Pib.*(PE.*(1-L)+1)-1;
        [mn,mnind]=min(abs(minF));
        muth(k)=s(mnind);
        k
    end
end


function [fitresult, gof] = myexpfit(x, y)
fo = fitoptions('Method','NonlinearLeastSquares',...
'Lower',[0,0],...
'Upper',[Inf,Inf],...
'StartPoint',[1 1]);
ft = fittype('a*exp(x.*b)','options',fo);
[fitresult, gof] = fit(x',y',ft);
end