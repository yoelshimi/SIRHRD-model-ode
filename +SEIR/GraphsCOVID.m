close all
%   script to create graphs and calculations of Disease:
%  modeled
%  
tspan=[0,365];
N0 = 9e6;
parts_susc = [0.1:0.02:1];
Niters = 1e2+1;
Niters_susc = length(parts_susc);
corrs = linspace(-1,1,Niters);
init_inf = 1e-2;
gamma=1/10;
gammaH=1/20;
R=3;
%% 
% config conplete: 
% 
% Split into Params for ODE model.

beta=[0.05*R*gamma 0.15*R*gamma R*gamma];
% params(6:7):
% P_H: probability to move into hospital once finished with I.
% P_H(1): probability of hospitalization from Susceptible.
% P_H(2): probability of hospitalization from non-Susceptible.
pH=[0.2 0.2/10]
% params(8:9):
% P_D: probability of death from hospital.
% P_D(1): death from Susceptible.
% P_D(2): death from non-susceptible.
pD=[0.2 0.05]
%param=[beta,gamma, gamma_H,P_H,P_D];
% param=[1e-1.*[0.1 0.4 0.98 0.5 0.8] 0.1 0.01 0.1 0.01];
% param=[1/N0.*[0.015 0.045 0.3] 0.1 0.05 0.2 0.02 0.2 0.05];
param=[beta/N0 gamma gammaH pH pD]
% betas = R*gamma/N0
%% 
% config complete. initialize storage variables:
pop2percent = 100/N0;
Hosp = zeros(Niters,Niters_susc ,4);
Dead = zeros(Niters,Niters_susc,4);
TtoMaxParts = zeros(Niters,Niters_susc,4);
TtoMaxHosp = zeros(Niters,Niters_susc);
Correlation = zeros(Niters,Niters_susc,1);
not_s = zeros(Niters,Niters_susc,4);
%% 
% Main part: loop over Susceptible portion, and correlation.

for iter1 = 1:Niters
    for iter2 = 1:Niters_susc
%     [mat,C] = get_corr(1);
        C = corrs(iter1);
        mat = good_corr(C, parts_susc(iter2));
        sb = mat(1,2); snb = mat(1,1); nsnb = mat(2,1);nsb = mat(2,2);
        xinit_s = [sb*N0; snb*N0; nsnb*N0; nsb*N0;];
        xinit = [xinit_s; xinit_s*init_inf; zeros(12,1)];
        xinit = xinit / sum(xinit) * N0; 
        
        [x,t]=SEIRodeSolver_YR(tspan,param,xinit);
        % plot(t,x,'LineWidth',2),grid on, xlabel('days'),shg
        not_s(iter1,iter2,:) = xinit(1:4)' - x(end,1:4);
        % measure hospitalization for compartments
        [max_h,t_max_ind] = max(x(:,9:12));
        t_max_h = t(t_max_ind);
        Hosp(iter1,iter2,:) = max_h; %  ./ (x(1,1:4) + x(1,5:8));
        TtoMaxParts(iter1,iter2,:) = t_max_h;
        
        % measure hospitalization overall
         [~,t_max_ind] = max(sum(x(:,9:12),2));
        t_max_h = t(t_max_ind);
        TtoMaxHosp(iter1,iter2,:) = t_max_h;
        % 
        Dead(iter1,iter2,:) = x(end,17:20); %  ./ ((x(1,1:4) + x(1,5:8)).*reshape([pD;pD].*[pH;pH],1,4));
        Correlation(iter1,iter2) = (sb*nsnb - snb*nsb) / (sb*nsnb + snb*nsb);
%         snb_(iter1, iter2) = mat(1,1); sb_(iter1) = mat(1,2);
    end
end
%% 
sval_to_plot = [0.3 0.4];
prefix = ["rand";"agent"];
run_ind = 1:2
structure_fname = "test\"+prefix(run_ind)+"2 res for alpha 0 "+sval_to_plot+" susc.mat";
%     prefix(run_ind(1))+" res for alpha 0 "+sval_to_plot+" susc.mat";
% if length(run_ind)>1
%     structure_fname = [structure_fname "test\"+...
%         prefix(run_ind(2))+" res for alpha 0 "+sval_to_plot+" susc.mat"]
% end
colourcode = ["ks", "bo";"kd", "rx"]';
colourcode = colourcode(run_ind,:)

%%
% configs colormaps
Ncolours = 15;
c1       = [112 172 105]/1.2;
c2       = [255 220 140];
c3       = [97 82 52]/1.2;
cmap     = arrayfun(@(x) linspace(single(c1(x))/256, single(c2(x))/256, Ncolours/2+1), 1:length(c2), 'UniformOutput', false);
cmap     = cell2mat(cmap')';
tcmp     = arrayfun(@(x) linspace(single(c2(x))/256, single(c3(x))/256, Ncolours/2+1), 1:length(c2), 'UniformOutput', false);
tcmp     = cell2mat(tcmp')';
cmap     = [cmap; tcmp(2:end,:)];
%%

% Graph 1: Times of Max Hospitalization.

f(1) = figure(1); 
g = pcolor(corrs', parts_susc', TtoMaxHosp'); shading interp ;
colormap jet
colorbar
xlabel("Correlation of Cautious-Risk")
ylabel("Part Susceptible")
title("Time of Max Hospitalization  for Corr and Susc part")
f(1).Visible = false;
%% 
f(2) = figure(2); g = subplot(3,1,1);
f(2).WindowStyle = 'docked';
set(f(2),'color','w');

p1 = contourf(corrs', parts_susc', sum(Dead,3)',Ncolours,'linewidth',2);

hold on; plot(corrs', sval_to_plot(1)*ones(length(corrs),1),"w--","linewidth", 3)
hold on; plot(corrs', sval_to_plot(2)*ones(length(corrs),1),"w--","linewidth", 3)
colorbar; hold on;
shading interp ;
xlabel("Correlation of Cautious-Risk", "FontSize",12)
ylabel("Percent at Risk", "FontSize",12)
title("Dead for Corr and Susc part")

% Graph 3: Correlation vs DEAd/Hosp by Group for a few [part susc]
subplot(3,1,3);

[~,s_ind1] = min(abs(parts_susc-sval_to_plot(1)))

plot(corrs,sum(Dead(:,s_ind1,:),3)*pop2percent,'b','linewidth',3); hold on;
[~,s_ind2] = min(abs(parts_susc-sval_to_plot(2)))
plot(corrs,sum(Dead(:,s_ind2,:),3)*pop2percent,'b','linewidth',3); hold on;
s_inds = [s_ind1;s_ind2]*[1 1];


for iter = 1:numel(structure_fname)
    load(structure_fname(iter)); 
    n = sum(cellfun(@(x) res.pop.(x), fields(res(1).pop)));
    t = squeeze(sum(cell2mat(struct2cell(res.dead)),1)) ; %  rows: iter1, correlation, columns: extra experiments.
    scale_f = mean(sum(Dead(:,s_inds(iter),:),3)) / mean(t(:));
    [x,y,err] = make_error_plot(res.corr',t * scale_f * pop2percent, Ncolours);
    inds = 1:2:length(x);
    errorbar(x(inds),y(inds),err(2,inds),err(1,inds),...
        colourcode(iter),'LineWidth',2); hold on;
end
grid on

sidefig_names = ["ODE ";"Dreg ";"struct "]+sval_to_plot;
legend(sidefig_names',"NumColumns",(1+numel(structure_fname)/2),"Location","northwest")
title(["Deceased";],TFString(1),TFString(2),TFString(3),TFString(4));
%title(["Number of Dead";...
%    "Risk: "+join(string(parts_susc([s_ind1 s_ind2])))+" init inf: "+init_inf])
xlabel("Correlation of Risk-Caution", FontString(1),FontString(2)...
    ,"HorizontalAlignment","center"); 
ylabel("[%] Deceased at peak", FontString(1),FontString(2))


% Graph 4: Pie chart of which groups are dead for different s 0.3,0.4
ts = ["R,C" "R,\negC" "\negR,\negC" "\negR,C"];
pieData = [
    Dead(1,s_ind1,:); 
    Dead(Niters_susc/2,s_ind1,:);
    Dead(end,s_ind1,:);
    Dead(1,s_ind2,:);
    Dead(Niters_susc/2,s_ind2,:);
    Dead(end,s_ind2,:);
    ];
nolabels = strings(4,1);
inds = 1:4;
getInds = @(x) squeeze(x>sum(x)/20);
% inds = getInds(Dead(1,s_ind1,inds));
pieData = squeeze(pieData);
pieData(pieData<=0) = eps;
pie_corrs = repmat(-1:1:1,2,1)';
pie_subplots = [7:9 10:12];
pie_svals = repmat(sval_to_plot,3,1)';
for iter = 1:numel(pie_subplots)
    s = subplot(6,3,pie_subplots(iter));
    pie(pieData(iter,:), nolabels); 
    s.Title.String = "c="+pie_corrs(iter)+" s="+pie_svals(iter)
    s.Title.VerticalAlignment = "middle";
end

% subplot(2,2,4); title("distribution of Dead")
% subplot(4,6,16); pie(Dead(1,s_ind1,inds), nolabels(inds));title("c=-1, s=0.3");
% % inds = getInds(Dead(Niters_susc/2,s_ind1,:));
% subplot(4,6,17); pie(Dead(Niters_susc/2,s_ind1,inds),nolabels(inds));title("c=0, s=0.3");
% % inds = getInds(Dead(end,s_ind1,:));
% subplot(4,6,18); pie(Dead(end,s_ind1,inds),nolabels(inds));title("c=+1, s=0.3")
% subplot(4,6,22); pie(Dead(1,s_ind2,inds),nolabels(inds));title("c=-1, s=0.4")
% subplot(4,6,23); pie(Dead(Niters_susc/2,s_ind2,inds),nolabels(inds));title("c=0, s=0.4")
% subplot(4,6,24); pie(Dead(end,s_ind2,inds),nolabels(inds));title("c=+1, s=0.4")
colormap jet;
legend(ts,'Orientation','horizontal');
colormap(g,cmap)
savefig(fullfile("SIRHRD model ode","figures","graph Dead "+datestr(today)+".fig"));
saveas(f(2),fullfile("SIRHRD model ode","figures","graph Dead "+datestr(today)+".eps"),"epsc");

%% 
% Graph 1.2: Amount of Dead for corr and susc

f(3) = figure(3); g = pcolor(corrs', parts_susc', sum(Hosp,3)'); shading interp ;

colorbar
xlabel("Correlation of Cautious-Risk")
ylabel("Part Susceptible")
title(" Hosp for Corr and Susc part")
f(3).Visible = 'off';
%%
% Graph 4: Hosp for corrs and susc.
f(4) = figure(4);
f(4).WindowStyle = 'docked';
set(f(4),'color','w');
FontString = {"FontSize",10};
TFString = {"FontSize",10,"FontWeight","bold"};

g = subplot(6,1,[1 2]);
p1 = contourf(corrs', parts_susc', sum(Hosp,3)' * pop2percent...
    ,Ncolours,'linewidth',2); 

hold on; plot(corrs', sval_to_plot(1)*ones(length(corrs),1),"w--","linewidth", 3)
hold on; plot(corrs', sval_to_plot(2)*ones(length(corrs),1),"w--","linewidth", 3)
colorbar; hold on;
shading interp ;

ylabel("Part Susceptible", FontString(1),FontString(2))
title("peak Hospitalization for Corr and Susc [%] percent", ...
    TFString(1),TFString(2),TFString(3),TFString(4))

% Graph 3: Correlation vs DEAd/Hosp by Group for a few [part susc]
subplot(3,1,3);
[~,s_ind1] = min(abs(parts_susc-sval_to_plot(1)))
plot(corrs,sum(Hosp(:,s_ind1,:),3)*pop2percent,'b','linewidth',3); hold on;
[~,s_ind2] = min(abs(parts_susc-sval_to_plot(2)))
plot(corrs,sum(Hosp(:,s_ind2,:),3)*pop2percent,'r','linewidth',3); hold on;
s_inds = [s_ind1;s_ind2]*[1 1];

for iter = 1:numel(structure_fname)
    load(structure_fname(iter)); 
    n = sum(cellfun(@(x) res.pop.(x), fields(res(1).pop)));
    t = squeeze(sum(cell2mat(struct2cell(res.hosp)),1)) ; %  rows: iter1, correlation, columns: extra experiments.
    scale_f = mean(sum(Hosp(:,s_inds(iter),:),3)) / mean(t(:));
    %     sum(xinit) / n;
    [x,y,err] = make_error_plot(res.corr',t * scale_f * pop2percent, Ncolours);
    inds = 1:2:length(x);
    errorbar(x(inds),y(inds),err(2,inds),err(1,inds),...
        colourcode(iter),'LineWidth',2); hold on;
end
 grid on;
 
legend(sidefig_names',"NumColumns",(1+numel(structure_fname)/2),"Location","northwest")
title(["Hosp for Correlations";],TFString(1),TFString(2),TFString(3),TFString(4));
    %"Susc: "+join(string(parts_susc([s_ind1 s_ind2])))+" init inf: "+init_inf])
xlabel("Correlation of Risk-Caution", FontString(1),FontString(2)...
    ,"HorizontalAlignment","center")
ylabel("[%] Hospitalized at peak", FontString(1),FontString(2))

% Graph 4: Pie chart of which groups are dead for different s 0.3,0.4
ts = ["R,C" "R,\negC" "\negR,\negC" "\negR,C"];
pieData = [
    Hosp(1,s_ind1,:); 
    Hosp(Niters_susc/2,s_ind1,:);
    Hosp(end,s_ind1,:);
    Hosp(1,s_ind2,:);
    Hosp(Niters_susc/2,s_ind2,:);
    Hosp(end,s_ind2,:);
    ];
pieData = squeeze(pieData);
pieData(pieData<=0) = eps;
pie_corrs = repmat(-1:1:1,2,1)';
pie_subplots = [7:9 10:12];
pie_svals = repmat(sval_to_plot,3,1)';
for iter = 1:numel(pie_subplots)
    s = subplot(6,3,pie_subplots(iter));
    pie(pieData(iter,:), nolabels); 
    s.Title.String = "c="+pie_corrs(iter)+" s="+pie_svals(iter)
    s.Title.VerticalAlignment = "middle";
end
%     subplot(4,6,17); pie(Hosp(Niters_susc/2,s_ind1,:), nolabels);title("c=0, s=0.3")
% subplot(4,6,18); pie(Hosp(end,s_ind1,:), nolabels);title("c=+1, s=0.3")
% subplot(4,6,22); pie(Hosp(1,s_ind2,:), nolabels);title("c=-1, s=0.4")
% subplot(4,6,23); pie(Hosp(Niters_susc/2,s_ind2,:), nolabels);title("c=0, s=0.4")
legend(ts,'Orientation','horizontal', 'Location',"south")
% subplot(4,6,24); pie(Hosp(end,s_ind2,:), nolabels);title("c=+1, s=0.4")

colormap jet;
colormap(g,cmap);
savefig(fullfile("SIRHRD model ode","figures","graph Hosp "+datestr(today)+".fig"));
saveas(f(4),fullfile("SIRHRD model ode","figures","graph Hosp "+datestr(today)+".eps"),"epsc");
%%
% Graph X: Number of people infected overall by the virus, divided to
% populations.
[~,s_ind1] = min(abs(parts_susc-sval_to_plot(1)));
figure; plot(corrs, squeeze(not_s(:,s_ind1,:)));
hold on; plot(corrs, sum(not_s(:,s_ind2,:),3),'k');
xlabel("corr");ylabel("#infected overall"); 
title("number of people infected overall");
legend(ts)
%% 
% Graph 2: Number of Dead for equalized parts.

equality_S_val_dead = 0.348543421210721;
[~,x1,t1]=RunCorr(equality_S_val_dead,1,1);
[~,x0,t0]=RunCorr(equality_S_val_dead,0,1);
[~,x_1,t_1]=RunCorr(equality_S_val_dead,-1,1);
f(5) = figure(5); semilogy(t1,x1(:,9:12)); hold on;
semilogy(t0,x0(:,9:12)); hold on;
semilogy(t_1,x_1(:,9:12)); xlim([0,50])
f(5).Visible = false;
%% 
% Graph 3: Dead and Hosp diff between +1 -1 Correlations for susceptibility 

f(6) = figure(6); plot(parts_susc,abs(sum(Hosp(1,:,:),3)-sum(Hosp(end,:,:),3)));
xlabel("part Susceptible")
ylabel("gap between -1 and +1 correlation")
title("Hospitalized equality point for susceptibility")
legend("-1 +1 corr dif")
f(6).Visible = false;
%%
f(7) = figure(7); plot(parts_susc,abs(sum(Dead(1,:,:),3)-sum(Dead(end,:,:),3)));
xlabel("part Susceptible")
ylabel("gap between -1 and +1 correlation")
title("Dead equality point for susceptibility")
legend("-1 +1 corr dif")
f(7).Visible = false;

%% 
% Graph 3: Correlation vs DEAd/Hosp by Group for a few [part susc]


[~,s_ind] = min(abs(parts_susc-equality_S_val_dead))
f(8) = figure(8); scatter(corrs,sum(Hosp(:,s_ind,:),3),'rx'); hold on; 
scatter(corrs,sum(Dead(:,s_ind,:),3),'ko');
title(["Dead and Hosp for Correlations";"Susc: "+parts_susc(s_ind)+" init inf: "+init_inf])
f(8).Visible = false;
%%
ts = ["sb" "snb" "nsnb" "nsb"];
f(9) = figure(9);
for i = 1:4
subplot(2,2,i); pcolor(parts_susc,corrs,Dead(:,:,i)); 
shading flat ; xlabel("Susceptible Fraction");
ylabel("Correlation");
title(ts(i)+" Dead"); colorbar;caxis([0 1e5]);
end
f(9).Visible = false;
%%
function [d,x,t] = RunCorr(Susc, C, d_or_h, param, N0, init_inf, tspan)
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

%%
function [x,y,err] = make_error_plot(x_long, y_long, Nvals)
    [x_long,ord] = sort(x_long);
    x = linspace(x_long(1),x_long(end),Nvals);
    y = zeros(Nvals,1);
    err = zeros(2,Nvals);
    for iter = 1:Nvals
        strt = find(x_long>=x(iter),1,"first");
        stp = find(x_long<=x(min(iter+1,Nvals)),1,"last");
        try
            y_data = y_long(ord(strt:stp),:);
        catch
            y_data = y_long(:,ord(strt:stp));
        end
        y(iter) = mean(y_data(:));
        err(1,iter) = std(y_data(y_data>y(iter))); % pos std *2 
        err(2,iter) = std(y_data(y_data<y(iter))); % pos std *2
    end
end