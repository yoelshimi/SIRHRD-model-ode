
name = datestr(today);
suscs = 0.3;
N_susc = length(suscs);
cautions = linspace(0.1, 0.5, 11); 
N_cautious = length(cautions);
output_filename = string(name)+filesep()+"sim_run_";
fnamefun = @(x, it1, it2) x+it1+"_"+it2+"_";
RGmode = "manual" ; 
T = table();
isActive = struct("dreg", true, "struct", false, "save", false);
for Biter = 1 : N_cautious
    p_cautious = cautions(Biter);
    for Riter = 1 : N_susc
        p_susc = suscs(Riter);
        fname = fnamefun(output_filename, Riter, Biter);
        [seir, Niter1, Niter2, cfg] = Runners.runMySimulation(p_susc, p_cautious, ...
            fname, RGmode);
        [res(Biter, Riter), T] = Utilities.readSimOutput(fname, Niter1, Niter2, seir, isActive, cfg, T);
    end
end

%%
tStruct = table2struct(T);
[G, ID] = findgroups(T.p_cautious, T.p_risk);
outbreakStruct = struct();
%%
for ind = 1 : numel(ID)
    csv(ind, :) = cellfun(@(x) Analysis.readCSVfromTable(x), ...
        tStruct(1).output_filenames, "UniformOutput", false);
    figure; plot(csv');
%     [tStruct(G == ind).isOutbreak] = Utilities.disperse(Analysis.isOutbreak(tStruct(G == ind)));
    
end
% outbreakTable = struct2table(outbreakStruct);
%%
for iter = 1 : 50
figure; plot(csv{iter}'); 
title(iter+"metrics: "+ tStruct(1).isOutbreak.metrics(iter))
end
%%
[G, ID] = findgroups(T.p_cautious);
n = max(G);
y = zeros(n, 1);
for g = 1 : n
    s = [tStruct(G == g).isOutbreak];
    y(g) = mean([s.p_outbreak]);
end
figure; plot(ID, y, "bs", "MarkerSize", 10, "MarkerFaceColor", "g");
