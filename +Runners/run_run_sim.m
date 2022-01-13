name =   "05-Jan-2022" %datestr(today); %

suscs = [0.6 0.8]; linspace(0.2,0.5,4);
N_susc = length(suscs);
% suscs = [0.3 0.4];%linspace(0,1,N_susc);
cautions = 1 - suscs;
N_cautious = 1 % length(cautions);

for Biter = 1 : N_cautious
    p_cautious = cautions(Biter);
    for Riter = 1 : N_susc
        p_susc = suscs(Riter);
        p_cautious = 1 - p_susc;
        output_filename = string(name)+filesep()+"sim_run_"+Riter+"_"+Biter+"_";
        run_simulation();
    end
end

%%
analyzeSimData();
%%
makeRGraph();

% makeInfectorGraph();