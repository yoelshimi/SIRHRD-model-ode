name = datestr(today);
suscs = 0.3;
N_susc = length(suscs);
cautions = linspace(0.1, 0.5, 5); 
N_cautious = length(cautions);

for Biter = 1 : N_cautious
    p_cautious = cautions(Biter);
    for Riter = 1 : N_susc
        p_susc = suscs(Riter);
%         p_cautious = 1 - p_susc;
        output_filename = string(name)+filesep()+"sim_run_"+Riter+"_"+Biter+"_";
        Runners.run_simulation();
    end
end


rundir = mfilename("fullpath");
cd(fileparts(rundir))
tic
f = ["S" "I" "H" "R" "D" "P"];
reusedVariables{2} = f;
f = f + "r"; 
reusedVariables{3} = f;
f = ["R0growth" "R0Ratio" "qual" ...
    "tab" "R0"];
f = f'+["R" "S"];
reusedVariables{4} = f;
f = ["maxTimes" "maxInfs", "seir"];
reusedVariables{5} = f;
if exist("res", "var") == true
    f = fields(res);
    reusedVariables{1} = f;
    for iter = 1 : numel(reusedVariables)
        clear(reusedVariables{iter}{:});
    end
end
% addpath("SIRHRD model ode\+Correlation");
FIELDS = ["snb", "sb", "nsnb", "nsb"];
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
families = 1e3;
sim_duration = 60;
if ~exist('p_susc','var')
    p_susc = 0.3;
end
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
if ~exist('output_filename','var')
    output_filename = "valid1\res"
end
if ~isfolder(fileparts(output_filename))
    fdrName = fileparts(output_filename);
    mkdir(fdrName);
    mkdir("israel population graph"+fdrName);
    mkdir("random graph"+fdrName);
end
corrs = linspace(0,1,21); %  -1:0.1:1;
Niter2 = 5;
Niter1 = length(corrs);
RGmode = "sb"  

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
                " -rng "+RGmode+" -s "+"True";     
            [status, result] = system(to_run, "-echo");
            if status ~= 0
                error(result);
            end
        end
        sb = mat(1,2); snb = mat(1,1); nsnb = mat(2,1);nsb = mat(2,2);
        xinit = [sb*N0pop; snb*N0pop; nsnb*N0pop; nsb*N0pop; ones(4,1)*p_init*N0pop/4; zeros(12,1)];
        xinit = xinit / sum(xinit) * N0pop; 
        [x,t]=SEIR.SEIRodeSolver_YR(tspan,param,xinit);
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
%%

tabR = cell(Niter1,Niter2);
tabS = tabR;
preallocField = cell2struct(cell(Niter1, Niter2, numel(FIELDS)), FIELDS, 3);
allocFun = @(x) assignin("caller", x, preallocField); 
cellfun(allocFun, [reusedVariables{[2 3]}])

warning("off")
for iter = 1 : Niter1
    for iter2 = Niter2:-1:1
        thisOutName = output_filename+iter+"_"+iter2;
        disp(thisOutName);
        [P(iter,iter2), S(iter,iter2), H(iter,iter2), D(iter,iter2), I(iter,iter2)] = ...
            Utilities.read_sb_output(thisOutName+"_sb.txt");
        tabS(iter,iter2) = {csvread("israel population graph"+thisOutName+".csv")};
        [R0growthS(iter,iter2), R0RatioS(iter,iter2), qualS(iter,iter2)] = ...
            Estimation.estimateR0FromCSV(tabS{iter,iter2},freq,gamma);
        if RGmode == "sb"
            [Pr(iter,iter2), Sr(iter,iter2), Hr(iter,iter2), Dr(iter,iter2), Ir(iter,iter2)] = ...
                Utilities.read_sb_output(thisOutName+" rnd_sb.txt");
            tabR(iter,iter2) = {csvread("random graph"+thisOutName+".csv")};
            [R0growthR(iter,iter2), R0RatioR(iter,iter2), qualR(iter,iter2)] = ...
                Estimation.estimateR0FromCSV(tabR{iter,iter2},freq, gamma);
            
            [R0S(iter,iter2,:), R0R(iter,iter2,:), maxTimes(iter,iter2,:), ...
                maxInfs(iter,iter2,:), varInf(iter, iter2)] = ...
                Utilities.readRunDetails(thisOutName+".txt");
        end
    end
end
warning("on")
%%
% cd(matlabDir);
HOSPIND = 6;
res.corr        = validCorrs;
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
save(fullfile(savedir,...
    "agent res for B "+p_cautious+" S "+p_susc+" susc.mat"), "res");

graphType       = "StructuredGraph";
Utilities.res2table();

if RGmode == "sb"
    res.pop      = Pr;
    res.sick     = Sr;
    res.hosp     = Hr;
    res.dead     = Dr;
    res.inf      = Ir;
    res.R0       = R0R;
    res.R0matlab = cat(3,R0growthR, R0RatioR, qualR);
    res.peakInfT    = reshape([maxTimes.TmaxInfRand],n,m);
    res.peakHosp    = cellfun(@(x) max(x(HOSPIND, :)), tabR);
    res.peakInf     = reshape([maxInfs.MaxInfRand],n,m);
    res.infVariance = reshape([varInf.varInfRand], n, m);
    res.seir        = seir;
    
    save(fullfile(savedir,"rand res for B "+p_cautious+" S "+p_susc+" susc.mat"), "res");
    
    graphType       = "DregGraph";
    Utilities.res2table();
end

%%
if 0
    nms = lower(["SB", "SNB", "NSNB","NSB"]);

    if Niter2 == 1
        datamat2 = cell2mat(struct2cell(Hr));   
        datamat = cell2mat(struct2cell(H)); 
    else
        datamat2 = squeeze(mean(cell2mat(struct2cell(Hr)),3));   
        datamat = squeeze(mean(cell2mat(struct2cell(H)),3)); 
    end
    figure; plot(corrs, datamat2,'.')	
    legend(nms)
    hold on; plot(corrs, datamat,'o')
    legend("random", "structured");
    title("Sick for Correlations")
    legend(nms)
    xlabel( "Corr")
    ylabel("")
end
%%
if 1
    figure;
    subplot(1,2,1);
    for iter = 1:Niter1
    hold on;
    plot(tabS{iter,1}(3,:)','Color',[iter/(2*Niter1) 0.1 0.1],'LineWidth',iter / 10);
    end
    subplot(1,2,2);
    for iter = 1:Niter1
        hold on;
        plot(tabR{iter,1}(3,:)','Color',[iter/(2*Niter1) 0.1 0.1],'LineWidth',iter / 10);
    end
end
%%
if 0
    k = divisors(Niter1);
    k = k(2);
    for iter = 1 : Niter1
        c1 = tabR(iter, :);
        c2 = seir(iter);
        c3 = cellfun(@(x) x(6, :), c1, "UniformOutput", false);
        tmax = min(cellfun(@(x) numel(x), c3));
        t = (1 : tmax)/24;
        subplot(k, Niter1 / k, iter);
        for iter2 = 1 : numel(c3)
            hold on; plot(t, c3{iter2}(1 : numel(t)));
        end
        hold on;
        plot(c2.t, c2.H, "kx")
    end
end
%%
if 0
    toc;
    result = 0;
    a = dir("israel population graph"+strtok(output_filename) + "*.csv");
    if 1  %  isempty(a)||result
        ME = MException('MyComponent:noFile', ...
            "no files found. try again.");
        throw(ME)
    end
    t = csvread(a.folder+"\"+a.name);toc;
    infected = t(3,:);
    [~,t_max] = max(infected);
    b = [t_max/(8*freq),t_max/(2*freq)];
    x = linspace(b(1),b(2),round((b(2)-b(1))*freq)+1);
    y = infected(round(b(1)*freq):round(b(2)*freq));
    f = fit(x',y','exp1')
    plot(f,x,y);
    xlabel("time since day 0 [days]")
    ylabel("infected [people]")
    title({"simulation - exponential fit";"formula: "+formula(f)+" a: "+f.a+" b: "+f.b});
end