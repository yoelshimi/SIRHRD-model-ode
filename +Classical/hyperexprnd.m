function out=hyperexprnd(tavg,p,N,M)
% tavg mean vector of exponents
% prob. to be with exp1, exp2,...expn == pn

p=p./sum(p);
if sum(p<0)>0
    out=-1;
    disp('error, p contains negative elements ');
end
r=rand(N,M);
cp=cumsum(p);
s=exprnd(tavg(1),N,M);
ot=s.*(r<cp(1)); % n*m matrix w 
for k=2:length(tavg)
s=exprnd(tavg(k),N,M);
ot=ot+s.*(r>cp(k-1)).*(r<=cp(k)); % if we used the k-th exponental- apply to ot.
end
out=ot;
