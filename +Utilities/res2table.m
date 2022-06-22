if exist("T","var")
    oldT = T;
    T = table();
else
    oldT = table();
end
if isrow(res.corr)
    res.corr = res.corr' .*ones(size(res.pop));
end

T = struct2table(res, "AsArray", false);

T.simType(:,1)      = categorical("python");
T.graphType(:,1)    = categorical(graphType);
T.families(:,1)     = families;
T.sim_duration(:,1) = sim_duration;
T.p_risk(:,1)       = p_susc;
T.p_cautious(:,1)   = p_cautious;
T.gamma(:,1)        = gamma;
T.alpha(:,1)        = alpha;
T.beta(:,1)         = beta;
T.b_l(:,1)          = {b_l};
T.gammaH(:,1)       = gammaH;
T.p_h_l(:,1)        = {p_h_l};
T.pD_l(:,1)         = {pD_l};
T.freq(:,1)         = freq;
T.output_filenames  = output_filename+(1:Niter1)'+"_"+(1:Niter2);

vnames = T.Properties.VariableNames;
for i = 1:length(vnames)
    if isstruct(T.(vnames{i}))
        T.(vnames{i}) = Utilities.structs2tables(T.(vnames{i}));
    end
end      

nameList = {'corr','pop','sick','hosp','dead','inf','R0',...
    'peakInfT','peakInf','R0matlab','simType','graphType',...
    'families','sim_duration','p_risk','p_cautious','gamma',...
    'alpha','beta','b_l','gammaH','p_h_l','pD_l','freq',...
    'output_filenames'};

T = Utilities.removeTableNameSuffix(T,"Rand");
n1 = oldT.Properties.VariableNames;
n2 = T.Properties.VariableNames;
if isempty(oldT) || all(contains(n2, n1))
    T = [oldT; T];
else 
    error("whoops");
end



