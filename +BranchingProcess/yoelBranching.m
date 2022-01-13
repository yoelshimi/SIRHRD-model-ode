clear;
cd (fileparts(which('yoelBranching')));
if ~exist('myhist','file')
    addpath('..');
end
figure; 
pib = BranchClass('Exponential',struct('lambda',1));
pe =  BranchClass('Exponential',struct('lambda',3));
pl = BranchClass('Exponential',struct('lambda',4));
t_smp = BranchClass('Uniform', struct('a',1e+5,'b',1e+6));
t_tst = BranchClass('Uniform', struct('a',1e+5,'b',1e+6));
config = struct('Nruns',1e5, 'qe', pe, 'pib', pib,'pl',pl,'t_smp',...
    t_smp,'t_tst',t_tst,'nmx',50);
pr = 0;
config.pr = pr;
pr

Qn = QNfind(config);
mu = fminbnd(@(s) abs(growth_eqn(s,Qn,pe.laplace_pdf,pib)),0,10)
%%
k = mu * log(2);
hold on; plot(0:config.nmx, Qn); R0 = Qn * (0:config.nmx)';
xlabel("number of infections Qn")
ylabel('probability');
title("branching process simulation Qn, R0 = " + R0);
legend('quarantine probability 0:0.1:1');
sim_fdr = "C:\Users\yoel\Documents\army\corona\rami simulation\python";
sim_res = dir(sim_fdr + "\*.csv");
sim_type = "d-regular";
if sim_type == "clustered"
    [~,ind] = sort([sim_res(:).datenum],'descend');
else 
    ind = find(startsWith({sim_res.name},"random"),1,'first');
end
t = readtable(sim_fdr + filesep() +  strip(string(sim_res(ind(1),:).name)));
num_infected = t(3,:);
x = (0:1:500)';
y = table2array(num_infected(1,1:501))';
f = fit(x,y,'exp1');
figure; plot(f,x,y); xlabel('time in freq units'); ylabel('num infected'); 
title({'simulation exponential fit';''});
%%

function s = growth_eqn(s,Qn, pe_L,pib)
    s = pib.laplace_pdf(s) * (pe_L(s) * (1-sum(Qn * pibn(Qn,pib.laplace_pdf,s,0:length(Qn)-1))) + 1) - 1;
end

function n_vec = pibn(Qn,pib_func,x,n)
% retrieves vector of the phrase: sum pib_func(x)*Qn(i) for i in n.
    n_vec = zeros(size(Qn,2));
    for i=n
        n_vec(i+1) = Qn(i+1) * pib_func(x)^i;
    end
end