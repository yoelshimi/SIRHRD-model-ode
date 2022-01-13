base_path = fileparts(which('validify'));
fdr_stc = fullfile(base_path, "israel population graph"+fileparts(output_filename));
fdr_rnd = fullfile(base_path, "random graph"+fileparts(output_filename));

beta_sc = zeros(Niter1,1);
beta_rnd = beta_sc;
beta_num = beta_sc;
part_susceptible = p_susc;  N0 = 9e6;
% load("SIRHRD model ode\validation\param.mat")
res = cell(Niter1,1);
res2 = cell(Niter1,1);
res3 = cell(Niter1,2);
%%
figure;
for iter = 1 :Niter1
    tab = csvread(fullfile(fdr_stc,"res"+iter+"_1.csv"));
    res(iter) = {tab};
    infected = tab(3,:);
    [~,ind_s] = max(infected);
    ts = linspace(0,ind_s/(2*24),ind_s/2);
    semilogy(ts(3:end)', infected(1,3:floor(ind_s/2))' / sum(tab(:,1)),'b-');hold on;
    f = fit(ts(3:end)', infected(1,3:floor(ind_s/2))' / sum(tab(:,1)),'exp1');
    beta_sc(iter) = f.b;
    
    tab2 = csvread(fullfile(fdr_rnd,"res"+iter+"_1.csv"));
    res2(iter) = {tab2};
    infected2 = tab2(3,:);
    [~,ind_r] = max(infected2);
    ts2 = linspace(0,ind_r/(2*24),ind_r/2);
    f = fit(ts2(3:end)', infected2(1,3:floor(ind_r/2))' / sum(tab2(:,1)),'exp1');
    hold on; semilogy(ts2(3:end)', infected2(1,3:floor(ind_r/2))' / sum(tab2(:,1)),'r-')
    beta_rnd(iter) = f.b;
    
        C = corrs(iter);
        mat = good_corr(C, part_susceptible);
        sb = mat(1,2); snb = mat(1,1); nsnb = mat(2,1);nsb = mat(2,2);
        init_inf = 1e-4;
        xinit = [sb*N0; snb*N0; nsnb*N0; nsb*N0; ones(4,1)*init_inf*N0/4; zeros(12,1)];
        xinit = xinit / sum(xinit) * N0; 
        tspan=[0,365];
        param=...%[[3*0.1*0.05 3*0.1*0.15 3*0.1*1]/N0 0.1 0.05 [0.2 0.02] [0.2 0.05]];
        [[3*0.1*3 3*0.1*0 3*0.1*0]/N0 0.1 0.05 [0.2 0.02] [0.2 0.2]];
        [x,t]=SEIRodeSolver_YR(tspan,param,xinit);
    res3(iter,:) = {t,x};
    infected3 = sum(x(:,5:8),2);
    [~,ind2] = max(diff(infected3));
    ind1 = find(diff(infected3)>0,1,'first');
    hold on; semilogy(t(ind1:floor(ind2)), infected3(ind1:floor(ind2))/ sum(x(1,:)),'k-')
    try
        f = fit(t(ind1:floor(ind2)), infected3(ind1:floor(ind2))/ sum(x(1,:)),'exp1');
    catch
        f = fit(t(10:end), infected3(10:end)/ sum(x(1,:)),'exp1');
    end
        beta_num(iter) = f.b;
end
%%
figure; plot(corrs,beta_num,'kp'); 
hold on; plot(corrs,beta_sc,'bs');
hold on; plot(corrs,beta_rnd,'rx');
legend("numerical ODE","structure graph","random graph")