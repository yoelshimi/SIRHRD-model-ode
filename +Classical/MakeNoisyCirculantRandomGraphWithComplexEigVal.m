function [M,lambda,M2]=MakeNoisyCirculantRandomGraphWithComplexEigVal(avg,std,n)
%vec=1+rand(1,n);
vec=normrnd(0,std,1,n);
vec=vec+min(vec)+avg;
M=zeros(n);
for k=1:n
    tmp=circshift(vec,k-1);
    M(:,k)=tmp(:);
end

M=M+rand(size(M));
lambda=eig(M);

M2=round(round(M*10)/10);
