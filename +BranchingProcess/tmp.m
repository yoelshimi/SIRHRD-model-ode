nruns=1e6;
qnmc=zeros(1,2000);
for k=1:nruns
    tauIBrnd=exprnd(tauIB,1,2000);
    tauLrnd=exprnd(tauL,1,1);
    tibcs=cumsum(tauIBrnd);
    tmp2=sum(tibcs<=tauLrnd);
    if tmp2==0
        qnmc(1)=qnmc(1)+1;
    else
        qnmc(tmp2+1)=qnmc(tmp2+1)+1;
    end
end
qnmc=qnmc/nruns;