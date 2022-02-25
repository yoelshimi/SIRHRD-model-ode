load(fullfile(Utilities.buildUpDirs(3), ...
    "statistical materials\worldVaxData", "CRdata.mat"))

countries = convertCharsToStrings( categories(combinedTables.country));
isvalidfun = @(x) x >= 0 & x <= 1;
f = figure;
ax1 = gca;
ylms = [0.2 0.3]; xlms = [0.2 1];
ax1.XLim = xlms;
ax1.YLim = ylms;
applyLimFun = @() applyLims(ax1, xlms, ylms);
ax1.XLimMode = "manual";
ax1.YLimMode = "manual";
hold on;
countries = ["Switzerland"; "Spain"; ...
"Israel"; "Croatia"; "Uruguay"; "Argentina"; "Slovakia"];
clrs = GraphCode.linspecer(numel(countries));
for cnt = countries'
    st = combinedTables(combinedTables.country == cnt, :);
    st = st(isvalidfun(st.p_cautious) & ...
        isvalidfun(st.risk) & isvalidfun(st.RnC), :);
    if isempty(st)
        continue;
    end
    x = 1 - st.p_cautious;
    y = st.risk;
    z = st.RnC;
    plot(ax1, [x(1) x(end)], [y(1) y(end)], ...
        "Color", clrs(1, :), "Marker", "none");
    applyLimFun();
    plot(ax1, mean([x(1) x(end)]), mean([y(1) y(end)]), ...
        "Color", clrs(1, :), "Marker", "<", "MarkerFaceColor", clrs(1, :),...
        "LineStyle", "none");
    applyLimFun();
    
    clrs = clrs(2:end, :);
    hold on
    ax2 = GraphCode.plotCustMark.addImageToPlot(ax1, x(1), y(1), ...
        VaccinationData.getFlagFromDB(cnt), "\Phi = "...
        +sprintf("%2.1f", z(1)*100)+"%", ...
        [0.05 0.05]);
    hold on;
%     plot(x, y, "bo", "DisplayName", cnt+" "+z)
    n = round(height(st));
    ax2 = GraphCode.plotCustMark.addImageToPlot(ax1, x(n), y(n), ...
        VaccinationData.getFlagFromDB(cnt), "\Phi = "+...
        sprintf("%2.1f", z(n)*100)+"%",...
        [0.075 0.075]);
    hold on;
    
end

xlabel(ax1, "p(not cautious)");
ylabel(ax1, "p(risk)");
grid(ax1, "off");
f.Color = "white";
title(ax1, "country compliance, \Phi = P(Not Cautious \cap Risk)");

disp(GraphCode.saveGraph(f, ax1));

function applyLims(ax, xlm, ylm)
% applies the axis limits as they seem to jump everywher for no apparent
% reason.
    ax.YLim = ylm;
    ax.XLim = xlm;
end