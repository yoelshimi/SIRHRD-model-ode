import GraphCode.*
% data locations: "SocialStructureGraph\results from yoel\result tables"
% real data location: "SocialStructureGraph\statistical
% materials\worldVaxData"

makeTableTopoGraph(T(T.graphType=="DregGraph",:), "hosp", " agent");

makeTableTopoGraph(T(T.graphType=="DregGraph",:), "dead"," agent");

GraphCode.plotCustMark.addCountryDataToPlot(combinedTables, gcf, "random")

makeTableTopoGraph(T(T.graphType=="DregGraph",:), ...
    "R0"," agent",2, "data");

makeTableTopoGraph(SimT, "hosp"," ode");

makeTableTopoGraph(SimT, "dead"," response");

makeTableTopoGraph(SimT, "R0"," response", 2, "data");

makeTableTopoGraph(SimTResponse, "hosp"," NO response");

makeTableTopoGraph(SimTResponse, "dead"," NO response");

makeTableTopoGraph(SimTResponse, "R0"," NO response", 2, "data");

makeTableTopoGraph(SimTnotTresponse, "hosp"," NO response");

makeTableTopoGraph(SimTnotTresponse, "dead"," NO response");

makeTableTopoGraph(SimTnotTresponse, "R0"," NO response", 2, "data");
%%
% makes the graph of: caution vs risk with color being percent outbreak.
pop2Percent = @(x) x * 100 / SimT.N0(1);
f = GraphCode.makeTopoGraphGeneral(...
    SimT, "not_cautious", "p_risk", "hosp", "RnC", "min", pop2Percent);
xlim([0.4 1])
res = Utilities.getFieldInChildren(f, "Title");
str = strrep(res.String, "RnC", "\Phi");
str = strrep(str, "hosp", "[%] hosp");
Utilities.setFieldInChildren(f, "Title", str, "String")
fname = GraphCode.saveGraph(f)

f = GraphCode.makeTopoGraphGeneral(...
    SimT, "not_cautious", "p_risk", "hosp", "RnC", "max", pop2Percent);
xlim([0.4 1])
res = Utilities.getFieldInChildren(f, "Title");
str = strrep(res.String, "RnC", "\Phi");
str = strrep(str, "hosp", "[%] hosp");
Utilities.setFieldInChildren(f, "Title", str, "String")
% zdat = f.Children(2).Children(1).ZData;
% f.Children(2).Children(1).ZData = pop2Percent(zdat);
fname = GraphCode.saveGraph(f)

GraphCode.plotFlagData
