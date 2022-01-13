function [x,t]=SIRHDJacobean(tspan,param,xinit)
%  function for running SIRHD code via usage of jacobean as 
% step function.
% derivative:
    J = @(x) getJacobeanSIRHD(param,x);
% fixed step 100 steps per day:
    step = 0.01;
    t = tspan(1):step:tspan(2);
% initial values:
    x = zeros(length(t),length(xinit));
    xinit = reshape(xinit, 1, length(xinit));
    x(1,:) = xinit;
% update rule: x(t) = x(t-1)+f' * x(t-1)
    for iter = 2:length(t)
        lastX = x(iter-1,:);
        x(iter,:) = lastX + step * (J(lastX) * lastX')';
    end
end
