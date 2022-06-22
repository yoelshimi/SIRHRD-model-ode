function [res, T] = readSimOutput(output_filename, Niter1, Niter2, seir, isActive, cfg, T)
    % function that reads variuous outputs from sim .
    Utilities.assgnFromStruct(cfg)
    FIELDS = ["snb", "sb", "nsnb", "nsb"];
    tabR = cell(Niter1,Niter2);
    tabS = tabR;
    warning("off")
    fnamefun = @(x, it1, it2) x+it1+"_"+it2;
    HOSPIND = 6;
    for iter = 1 : Niter1
        for iter2 = Niter2:-1:1
            thisOutName = fnamefun(output_filename, iter, iter2);
            disp(thisOutName);
            if isActive.struct
                [P(iter,iter2), S(iter,iter2), H(iter,iter2), D(iter,iter2), I(iter,iter2)] = ...
                    Utilities.read_sb_output(thisOutName+"_sb.txt");
                tabS(iter,iter2) = {csvread("israel population graph"+thisOutName+".csv")};
                [R0growthS(iter,iter2), R0RatioS(iter,iter2), qualS(iter,iter2)] = ...
                    Estimation.estimateR0FromCSV(tabS{iter,iter2},cfg.req,cfg.gamma);
                [R0S(iter,iter2,:), ~, maxTimes(iter,iter2,:), ...
                    maxInfs(iter,iter2,:), varInf(iter, iter2)] = ...
                    Utilities.readRunDetails(thisOutName+".txt");
            end
            if isActive.dreg
                [Pr(iter,iter2), Sr(iter,iter2), Hr(iter,iter2), Dr(iter,iter2), Ir(iter,iter2)] = ...
                    Utilities.read_sb_output(thisOutName+" rnd_sb.txt");
                tabR(iter,iter2) = {csvread("random graph"+thisOutName+".csv")};
                [R0growthR(iter,iter2), R0RatioR(iter,iter2), qualR(iter,iter2)] = ...
                    Estimation.estimateR0FromCSV(tabR{iter,iter2},cfg.freq, cfg.gamma);
                [~, R0R(iter,iter2,:), maxTimes(iter,iter2,:), ...
                    maxInfs(iter,iter2,:), varInf(iter, iter2)] = ...
                    Utilities.readRunDetails(thisOutName+".txt");
            end
        end
    end
    
    if isActive.struct
        res.corr        = cfg.validCorrs;
        res.pop         = P;
        res.sick        = S;
        res.hosp        = H;
        res.dead        = D;
        res.inf         = I;
        res.R0          = R0S;
        res.R0matlab    = cat(3,R0growthS, R0RatioS, qualS);
        [n,m]           = size(maxTimes);
        res.peakInfT    = reshape([maxTimes.TmaxInf],n,m);
        res.peakInf     = reshape([maxInfs.MaxInf],n,m);
        res.peakHosp    = cellfun(@(x) max(x(HOSPIND, :)), tabS);
        res.N0          = N0pop*ones(Niter1,1);
        res.seir        = seir;
        res.infVariance = reshape([varInf.varInfStruct], n, m);
        savedir = fullfile("..", "..", "simOutputs");
        if isActive.save
            save(fullfile(savedir,...
                "agent res for B "+p_cautious+" S "+p_susc+" susc.mat"), "res");
        end
        graphType       = "StructuredGraph";
        Utilities.res2table();
    end

    if isActive.dreg
        res.corr     = cfg.validCorrs;
        res.pop      = Pr;
        res.sick     = Sr;
        res.hosp     = Hr;
        res.dead     = Dr;
        res.inf      = Ir;
        res.R0       = R0R;
        res.R0matlab = cat(3,R0growthR, R0RatioR, qualR);
        
        [n,m]           = size(maxTimes);
        res.peakInfT    = reshape([maxTimes.TmaxInfRand],n,m);
        res.peakHosp    = cellfun(@(x) max(x(HOSPIND, :)), tabR);
        res.peakInf     = reshape([maxInfs.MaxInfRand],n,m);
        res.infVariance = reshape([varInf.varInfRand], n, m);
        res.seir        = seir;
        if isActive.save
            save(fullfile(savedir,...
                "rand res for B "+p_cautious+" S "+p_susc+" susc.mat"), "res");
        end
        graphType = "DregGraph";
        Utilities.res2table();
    end
end