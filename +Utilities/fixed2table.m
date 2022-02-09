if exist("SimT","var")
    oldT = SimT;
    SimT = table();
else
    oldT = table();
end
% if isrow(pBfromS)
%     cfg.corr = cfg.corr';
% end

SimT = struct2table(cfg,"AsArray",true);

SimT.simType(:,1)      = categorical("matlab");
SimT.graphType(:,1)    = categorical("Dreg");
SimT.families(:,1)     = 0;
% if isfield(SimT, "R0matlab")
if isempty(SimT.R0matlab)
    SimT.R0matlab          = "";
end
SimT.freq(:,1)         = inf;
SimT.output_filenames  = "";

vnames = SimT.Properties.VariableNames;
for i = 1:length(vnames)
    if isstruct(SimT.(vnames{i}))
        SimT.(vnames{i}) = structs2tables(SimT.(vnames{i}));
    end
end      

nameList = {'corr','pop','sick','hosp','dead','inf','R0',...
    'peakInfT','peakInf','R0matlab','simType','graphType',...
    'families','sim_duration','p_risk','p_cautious','gamma',...
    'alpha','beta','b_l','gammaH','p_h_l','pD_l','freq',...
    'output_filenames'};

n1 = oldT.Properties.VariableNames;
n2 = SimT.Properties.VariableNames;
% for iter = n2(~contains(n2, n1))
%     T.(iter{:}) = "";
% end

if ~isempty(oldT) && (length(n1) == length(n2) ||all(strcmp(n1, n2)))
    oldT(cnt, :) = SimT;
    SimT = oldT;
elseif isempty(oldT)
    % first iteration, preallocate all subsequent rows.
    SimT = repmat(SimT, NitersCautious * NitersRisk, 1);
else
    error("whoops");
end

clear("oldT")


