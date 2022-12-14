% makes the graph of: caution vs risk with color being percent outbreak.
f = figure;
ax1 = subplot(1, 2, 1);
pop2Percent = @(x) x * 100 / SimT.N0(1);
f = GraphCode.makeTopoGraphGeneral(...
    SimT, "not_cautious", "p_risk", "hosp", "RnC", "min", pop2Percent);
xlim([0.4 1])
res = Utilities.getFieldInChildren(f, "Title");
str = "\Phi_{min}";
Utilities.setFieldInChildren(f, "Title", str, "String")
GraphCode.makeZCorrection(ax1)
fname = GraphCode.saveGraph(f)
ax2 = subplot(1, 2, 2);
f = GraphCode.makeTopoGraphGeneral(...
    SimT, "not_cautious", "p_risk", "hosp", "RnC", "max", pop2Percent);
xlim([0.4 1])
ylabel(ax2, ""); yticklabels(ax2, "")
res = Utilities.getFieldInChildren(f, "Title");
str = "\Phi_{max}";
ax2.Title.String = str;
ax2.Title.FontSize = 10;
GraphCode.makeZCorrection(ax2)
fname = GraphCode.saveGraph(f)
%%
IMSIZE = [0.05 0.05];
% do the flags, making one on left and one on right.
load(fullfile(Utilities.buildUpDirs(3), ...
    "statistical materials\worldVaxData", "CRdata.mat"))

countries = convertCharsToStrings( categories(combinedTables.country));
isvalidfun = @(x) x >= 0 & x <= 1;
% ylms = [0.2 0.3]; xlms = [0.2 1];
% ax1.XLim = xlms;
% ax1.YLim = ylms;
% applyLimFun = @() applyLims(ax1, xlms, ylms);
% ax1.XLimMode = "manual";
% ax1.YLimMode = "manual";
hold on;
countries = ["Israel"; "Switzerland";];
clrs = flipud(GraphCode.linspecer(numel(countries)+9));
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
    [xLocS, yLocS] = GraphCode.Coords.coord2norm(ax2, x(1)-0.05, y(1));
    [xLocE, yLocE] = GraphCode.Coords.coord2norm(ax1, x(end)+0.05, y(end));
    arh = annotation('arrow', [xLocS, xLocE], [yLocS, yLocE],...
        "Color", clrs(1, :), "LineWidth", 3, "LineStyle", "--");
    
    clrs = clrs(2:end, :);
    hold on
    axn = GraphCode.plotCustMark.addImageToPlot(ax2, x(1), y(1), ...
        VaccinationData.getFlagFromDB(cnt), "\Phi = "...
        +sprintf("%2.0f", round(z(1)*100))+"%", ...
        IMSIZE);
    hold on;
    
    n = height(st);
    axn = GraphCode.plotCustMark.addImageToPlot(ax1, x(n), y(n), ...
        VaccinationData.getFlagFromDB(cnt), "\Phi = "+...
        sprintf("%2.0f", round(z(n)*100))+"%",...
        IMSIZE);
    hold on;
    grid(ax2, "off")
end

sgtitle(f, ["peak percent [%] hospitalized";...
    "\Phi = P(Not Cautious \cap Risk)"], "FontSize", 10);

TFString = {"FontSize",12,"FontWeight","bold"};
set(ax2.XLabel, TFString{:})
set(ax2.YLabel, TFString{:})

t = f.Children(5).Title;
set(t,'position',get(t,'position')+[0 70 0])

disp(GraphCode.saveGraph(f, ax1));

function applyLims(ax, xlm, ylm)
% applies the axis limits as they seem to jump everywher for no apparent
% reason.
    ax.YLim = ylm;
    ax.XLim = xlm;
end