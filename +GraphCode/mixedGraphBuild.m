dataDir = "..\results from yoel\result tables";
load(fullfile(dataDir, "tables.mat"));

load(fullfile(dataDir, "tab_calibrated_11_11_21.mat"));
g = makeTableTopoGraph(SimT, "hosp"," ode");

subTable = T(T.p_risk == T.p_cautious & T.graphType == "DregGraph",:);
popSize = mean(subTable.N0(:));

[Data, corrs, parts_susc] = retrieve2mat...
    (subTable,"corr","p_risk","hosp", nan);
% ax = axes();
% g.CurrentAxes = ax;
factor = 1 / 3.3818;
Data = factor * Data / popSize * 100;
pointSize = 100;

scatter(g.CurrentAxes, subTable.corr, subTable.p_cautious,pointSize, ...
    Data(:), "filled","o");
% makeTableTopoGraph(T(T.graphType=="DregGraph",:), "hosp", " agent");
h = get(gca, "Children");
order = [2 3 5 1 4];
set(gca,'Children',h(order));
ylim([min(subTable.p_cautious) max(subTable.p_cautious)])

legend("ODE","Agent-based")
fdr = mfilename("fullpath");
fparts = strsplit(fdr,filesep());
fparts = fparts(1:end-2);
fdr = strjoin(fparts,filesep());
fdr = fullfile(fdr,"figures",datestr(today));

% savefig(g, fullfile(fdr,"ODE+AGENT DREG"+" .fig"));
% saveas(g, fullfile(fdr,"ODE+AGENT DREG"+" .eps"),"epsc");
