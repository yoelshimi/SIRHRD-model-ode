% MAXN = 50;
% Qn = zeros(MAXN,1);
% parfor i =1:MAXN
% Qn(i) = QnSimCalc(i);
% end
%% 
clear;
figure; 
pib = BranchClass('MixedExponential',[struct('lambda',10,'p',0.95),struct('lambda',18^-1,'p',0.05)]);
pe =  BranchClass('Uniform',[struct('a',3.5,'b',6.5)]);
config = struct('Nruns',1e4, 'qe', pe, 'pib', pib,'nmx',100);
for pr = 0:0.1:1
    config.pr = pr;
    Qn = QNfind(config);
    mu = fminbnd(@(s) abs(growth_eqn(s,Qn,pe.laplace_pdf,pib)),0,10)
    
    P=0.95;lambda1 = 10; lambda2 = 18^-1; upperlim = 6.5; lowerlim = 3.5;
    % 
    % 
    % pe = @(x) 1./(upperlim - lowerlim) * (x<=upperlim) * (x>= lowerlim);
    % pe_l = @(s) matlabFunction(laplace(sym(pe),s));
    % 
    pib = @(t) p.*lambda1 .* exp(-lambda1 .* t) + (1-p) .* lambda2 .* exp(-lambda2 .* t);
    % pib_l = @(s) matlabFunction(laplace(sym(pib)));
    % 
    % eqn = @(s) pib_l(s) * (pe_l(s) *(1-sum(Qn * pibn(pib_l,s,0:length(Qn)))) + 1) - 1;
    % % eqn_m = matlabFunction(eqn);
    % 

    %%
    % Qn = nq;
    PE_func = @pe_L;
    PIB_func = @pib_L;

    % eqn = @(s) PIB_func(s) * (PE_func(s) * (1-sum(Qn * pibn(PIB_func(5),s,0:length(Qn)))) + 1) - 1;
    Qn = p;hold on; plot(p)
    
%     mu = fzero(@(s) eqn(s,Qn),5)
    

end
xlabel('number of infections Qn')
ylabel('probability');
title('branching process simulation Qn');
legend('quarantine probability 0:0.1:1');


function s = growth_eqn(s,Qn, pe_L)
    s = pib_L(s) * (pe_L(s) * (1-sum(Qn * pibn(Qn,@pib_L,s,0:length(Qn)-1))) + 1) - 1;
end

function y = pe_f(x)
    upper_lim = 6.5;
    lower_lim = 3.5;
    if x<=upper_lim && x>=lower_lim
        y = 1./(upper_lim - lower_lim);
    else y = 0;
    end    
end


function y = pe_L(s)
% laplace transform of 'E' exposed time distribution.
    y =  (exp(-3*s) - exp(-5*s)) / (2*s);
    %1./(1+1/4.*s); 
end


function n_vec = pibn(Qn,pib_func,x,n)
% retrieves vector of the phrase: sum pib_func(x)*Qn(i) for i in n.
    n_vec = zeros(size(Qn,2));
    for i=n
        n_vec(i+1) = Qn(i+1) * pib_func(x)^i;
    end
end


function y = pib_L(s)
% laplace transform of Pib distribution of infection times.
% shift = 0.5; lambda = 0.5;
y =  0.9 ./ (1+1*s) + 0.1 ./ (1+5.*s);% shift./s + 1./(1+s./lambda);
end




