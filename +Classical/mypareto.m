function [out,med,gcv,prc_vec]=mypareto(xmin,alpha,M,N)
% xmin = minimum 
% alpha = powerlaw, for alpha>2, cv
%function out=mypareto(xmin,alpha,M,N)
if nargout>1
    %%%find median
    K=1/alpha;
    SIGMA=xmin./alpha;
    THETA=xmin;
    f = @(x,c) abs(gpcdf(x,c(1),c(2),c(3))-0.5);  % The parameterized function.
    c = [K,SIGMA,THETA];                        % The parameter.
    X50 = fminsearch(@(x) f(x,c),4*c(3));
    %%%find 75 percentile
    f = @(x,c) abs(gpcdf(x,c(1),c(2),c(3))-0.75);  % The parameterized function.
    c = [K,SIGMA,THETA];                        % The parameter.
    X75 = fminsearch(@(x) f(x,c),4*c(3));     
     %%%find 25 percentile
    f = @(x,c) abs(gpcdf(x,c(1),c(2),c(3))-0.25);  % The parameterized function.
    c = [K,SIGMA,THETA];                        % The parameter.
    X25 = fminsearch(@(x) f(x,c),4*c(3)); 
    gcv=(X75-X25)/X50;
    %R = gprnd(K,SIGMA,THETA)
    prc_vec=[X25,X50,X75];
    med=X50;
end
if alpha>0
    if exist('M','var')==0
        M=1;
        N=1;
    end
 out=gprnd(1/alpha, xmin./alpha, xmin,M,N);
else
    out=[];
    disp('alpha parameter should be positive  ');
end