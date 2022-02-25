name = datestr(today); %

suscs = linspace(0.2,0.5,4);
N_susc = length(suscs);
% suscs = [0.3 0.4];aWE%linspace(0,1,N_susc);
cautions = 1 - linspace(0.2,0.5,4);
N_cautious = length(cautions);

for Biter = 1 : N_cautious
    p_cautious = cautions(Biter);
    for Riter = 1 : N_susc
        p_susc = suscs(Riter);
        p_cautious = 1 - p_susc;
        output_filename = string(name)+filesep()+"sim_run_"+Riter+"_"+Biter+"_";
        Runners.run_simulation();
    end
end

%%
Analysis.analyzeSimData();
%%
GraphCode.makeRGraph();

% makeInfectorGraph();