graphConfig
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
fdr = cd; 
fdr = split(fdr,'\');
fdr = fullfile(fdr{1:end-2});
savefig(fullfile(fdr,"SIRHRD model ode","figures","graph Hosp "+datestr(today)+".fig"));
saveas(f(4),fullfile(fdr,"SIRHRD model ode","figures","graph Hosp "+datestr(today)+".eps"),"epsc");
