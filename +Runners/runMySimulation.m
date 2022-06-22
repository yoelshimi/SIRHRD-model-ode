function [seir, Niter1, Niter2, cfg] = ...
    runMySimulation(p_susc, p_cautious, output_filename, RGmode)
    rundir = mfilename("fullpath");
    cd(fileparts(rundir))
    tic
    % addpath("SIRHRD model ode\+Correlation");
    format long g
    tic;
    switch getenv("computername")
        case 'LAPTOP-Q0OQCTC5'        
            code_path = "C:\Users\yoel\Documents\army\corona\rami_simulation\python\AgentSimulation";
        otherwise
            code_path = "..\..\python_31_5_21";
    end
    space = " ";
    command = "python"
    run_file = "basic_run.py"
    families = 100; % 10.^(1:4);
    sim_duration = 60;
    R = 3;
    gamma = 1/10;% recovery rate
    beta = R*gamma;
    alpha = 0; % no latency.

    p_init = 0.01;
    b_l = [0.05 0.15 1]; % betas: 1: BB, 2:nBB, 3: nBnB
    gammaH = 1/20; % rate of move out of hospital.
    N0pop = families*3.3;

    p_h_l =  [0.2,0.2/10];
    pD_l= [0.2,0.05];

    tspan=[0,365];
    param=[beta.*b_l/N0pop gamma gammaH p_h_l pD_l];

    is_plot = false;
    freq = 24;
    if ~isfolder(fileparts(output_filename))
        fdrName = fileparts(output_filename);
        mkdir(fdrName);
        mkdir("israel population graph"+fdrName);
        mkdir("random graph"+fdrName);
    end
    corrs = 0:0.1:1;
    Niter2 = 50;
    Niter1 = length(corrs);

    validCorrStruct = Correlation.getMinMaxCorrs(p_susc, p_cautious);
    validCorrs = corrs(corrs >= validCorrStruct.minCR &...
        corrs <= validCorrStruct.maxCR);
    Niter1 = numel(validCorrs);
    %%
    % modes: on, off, sb, true, false
    if 1
        parfor iter1 = 1 : Niter1
            for iter2 = 1 : Niter2
                corr  = validCorrs(iter1);
        %         mat = good_corr(corr, p_susc);
                mat = Correlation.nonSymCorr(p_susc, p_cautious, corr); 
                mat(mat(:)<0.001) = 0
                to_run = command+space+code_path+filesep()+run_file+space+" -n "+families...
                    +" -p "+is_plot+" -o "+output_filename+iter1+"_"+iter2+" -b "+beta+" -a "+alpha+" -g "...
                    +gamma+" -f "+freq+" -n_i "+sim_duration+" -b_l "+b_l(1)+" "+b_l(2)+" "+b_l(3)+...
                    " -g_h "+gammaH + " -p_h_l "+p_h_l(1)+" "+p_h_l(2)+" -p_d_l "+pD_l(1)+" "...
                    +pD_l(2)+" -sbc_l "+mat(1,1)+space+mat(1,2)+space+mat(2,1)+space + mat(2,2)+...
                    " -rng "+RGmode+" -s "+"True"+" -stg "+"false";     
                [status, result] = system(to_run, "-echo");
                if status ~= 0
                    error(result);
                end
            end
            sb = mat(1,2); snb = mat(1,1); nsnb = mat(2,1);nsb = mat(2,2);
            xinit = [sb*N0pop; snb*N0pop; nsnb*N0pop; nsb*N0pop; ones(4,1)*p_init*N0pop/4; zeros(12,1)];
            xinit = xinit / sum(xinit) * N0pop; 
            [x, t]=SEIR.SEIRodeSolver_YR(tspan,param,xinit);
            ind_last = find(t<81,1,'last');
            inds = 1:ind_last;
            t = t(inds);
            s = sum(x(inds,1:4),2);
            i = sum(x(inds,4+(1:4)),2);
            h = sum(x(inds,8+(1:4)),2);
            r = sum(x(inds,12+(1:4)),2);
            d = sum(x(inds,16+(1:4)),2);
            seir(iter1, 1) = struct("t", t, "xinit", xinit,...
                "S", s, "I", i, "H", h, "R", r, "D", d)
        end
    end
    %  toc;
    cfg = struct("gamma", gamma, "freq", freq, "validCorrs", validCorrs, ...
        "beta", beta, "alpha", alpha, "sim_duration", sim_duration, "b_l", b_l, ...
        "gammaH", gammaH, "p_h_l", p_h_l, "pD_l", pD_l,"families", families, ...
        "p_susc", p_susc, "p_cautious", p_cautious);
end
