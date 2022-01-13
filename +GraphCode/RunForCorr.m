%%
function [d,x,t] = RunForCorr(Susc, C, d_or_h, param, N0, init_inf, tspan)
    if nargin == 2
        d_or_h = 0; %dead
    end
    if nargin <= 3
        N0 = 9000000;
        init_inf = 0.01;
        tspan = [0   365];
        param = [1.66e-09,5.00e-09,3.33e-08,0.100,0.0500,0.20,0.020,0.20,0.050];
    end
    
    if(d_or_h)
        inds = 9:12;
    else
        inds = 17:20;
    end
    mat = good_corr(C, Susc);
    sb = mat(1,2); snb = mat(1,1); nsnb = mat(2,1);nsb = mat(2,2);
    xinit = [sb*N0; snb*N0; nsnb*N0; nsb*N0; ones(4,1)*init_inf*N0/4; zeros(12,1)];
    xinit = xinit / sum(xinit) * N0; 
    [x,t]=SEIRodeSolver_YR(tspan,param,xinit);
    
    d = sum(x(end,inds),2);
    
end
