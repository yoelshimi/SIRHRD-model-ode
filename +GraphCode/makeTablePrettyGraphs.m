makeTableTopoGraph(T(T.graphType=="DregGraph",:), "hosp", " agent");

makeTableTopoGraph(T(T.graphType=="DregGraph",:), "dead"," agent");

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