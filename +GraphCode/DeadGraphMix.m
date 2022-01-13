graphConfig


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
fdr = cd;
fdr = split(fdr,'\');
fdr = fullfile(fdr{1:end-2});
savefig(fullfile(fdr, "SIRHRD model ode","figures","graph Dead "+datestr(today)+".fig"));
saveas(f(2),fullfile(fdr, "SIRHRD model ode","figures","graph Dead "+datestr(today)+".eps"),"epsc");
