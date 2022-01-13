% clear
clear("S","R","H","D", "I")
% cd("Dropbox\SocialStructureGraph\matlab")
addpath("SIRHRD model ode\correlation");
format long g
tic;
switch getenv("computername")
    case 'LAPTOP-Q0OQCTC5'        
        code_path = "C:\Users\yoel\Documents\army\corona\rami_simulation\python";
    otherwise
        code_path = "..\python_31_5_21";
end
space = " ";
command = "python"
run_file = "basic_run.py"
families = [5e3];
sim_duration = 60;
if ~exist('p_susc','var')
    p_susc = 0.3;
    p_cautious = 0.2;
end
R = 5;
gamma = 1/10;% recovery rate
beta = R*gamma;
alpha = 0; % no latency.

b_l = [0.05 0.15 1]; % betas: 1: BB, 2:nBB, 3: nBnB
gammaH = 1/20; % rate of move out of hospital.


p_h_l =  [0.2,0.2/10];
pD_l= [0.2,0.05];

is_plot = false;
freq = 24*10; % every minute it runs a test(!)
if ~exist('output_filename','var')
    output_filename = "valid_4\res"
end
if ~isfolder(fileparts(output_filename))
    fdrName = fileparts(output_filename);
    mkdir(fdrName);
    mkdir("israel population graph"+fdrName);
    mkdir("random graph"+fdrName);
end
corrs = 0.3; %  -1:0.1:1;
corr = corrs;
Niter2 = 21;
Niter1 = length(families);
RGmode = "sb"  ;
%%
N0 = families(1) *3.3;
Sim = CSimInput("N0",N0,"pH",p_h_l,'pD',pD_l,...
    'p_susc',p_susc,'p_cautious',p_cautious,'R',3);



%%
% modes: on, off, sb, true, false
if 1
    parfor iter = 1 : Niter1 
        for iter2 = 1 : Niter2
            N0 = families(iter) *3.3;
%             corr = corrs(iter);
    %         mat = good_corr(corr, p_susc);
            mat = nonSymCorr(p_susc, p_cautious, corr); 
            mat(mat(:)<0.001) = 0
            to_run = command+space+code_path+filesep()+run_file+space+" -n "+families(iter)...
                +" -p "+is_plot+" -o "+output_filename+iter+"_"+iter2+" -b "+beta+" -a "+alpha+" -g "...
                +gamma+" -f "+freq+" -n_i "+sim_duration+" -b_l "+b_l(1)+" "+b_l(2)+" "+b_l(3)+...
                " -g_h "+gammaH + " -p_h_l "+p_h_l(1)+" "+p_h_l(2)+" -p_d_l "+pD_l(1)+" "...
                +pD_l(2)+" -sbc_l "+mat(1,1)+space+mat(1,2)+space+mat(2,1)+space + mat(2,2)+...
                " -rng "+RGmode+" -s "+"True"; 

            result = system(to_run) ;
            if result ~= 0
                error("failure message: "+result+"iter: "+iter+"_"+iter2);
            end
        %     toc;
        end
    end
end
%%
tabR = cell(Niter1,Niter2);
tabS = tabR;
warning("off")
for iter = 1 : Niter1
    for iter2 = 1:Niter2
        thisOutName = output_filename+iter+"_"+iter2;
        [P(iter,iter2), S(iter,iter2), H(iter,iter2), D(iter,iter2), I(iter,iter2)] = ...
            read_sb_output(thisOutName+"_sb.txt");
        tabS(iter,iter2) = {csvread("israel population graph"+thisOutName+".csv")};
        [R0growthS(iter,iter2), R0RatioS(iter,iter2), qualS(iter,iter2)] = ...
            estimateR0FromCSV(tabS{iter,iter2},freq,gamma);
        if RGmode == "sb"
            [Pr(iter,iter2), Sr(iter,iter2), Hr(iter,iter2), Dr(iter,iter2), Ir(iter,iter2)] = ...
                read_sb_output(thisOutName+" rnd_sb.txt");
            tabR(iter,iter2) = {csvread("random graph"+thisOutName+".csv")};
            [R0growthR(iter,iter2), R0RatioR(iter,iter2), qualR(iter,iter2)] = ...
                estimateR0FromCSV(tabR{iter,iter2},freq, gamma);
            
            [R0struct(iter,iter2,:), R0rand(iter,iter2,:), maxTimes(iter,iter2,:), ...
                maxInfs(iter,iter2,:)] = readRunDetails(thisOutName+".txt");
        end
    end
end
warning("on")
%%
N0 = 9e6;
pH = p_h_l;
pD = pD_l;
mat = nonSymCorr(p_susc, p_cautious, corr); 
xinit = mat([3 1 2 4])*N0 % conversion from mat to ODE
param=[b_l.*beta./N0 gamma gammaH pH pD]
%  x(1) = Ssb, x(2)=Ssnb, x(3)= Snsnb, x(4) = Snsb
xinit = [xinit xinit*0.01 zeros(1,12)];
tspan = [0 365];
[x,t]=SEIRodeSolver_YR(tspan,param,xinit);

%%
if 1
%     figure;
    
    flds = ["S", "I", "H", "R", "D"];
    fldsNum = [1 3 6 4 7];
    for fld = 1 : length(fldsNum)
        f = figure;
        for iter = 1 : Niter1
            for iter2 = 1:Niter2
                hold on;
                popFactor = 1 / (3.3*families(iter));
                plot(popFactor*tabR{iter,iter2}(fldsNum(fld),:)',...
                    'Color',[iter/(Niter1) 0.1 0.1],"Marker",".",...
                    "LineStyle","None", "displayName", ...
                    "sim N0: "+families(iter)+" i: "+iter2);
            end
        end
        p = (fld-1)*4 ;
        plot(t * freq ,sum(x(:,p+ 1 : p+4),2)/9e6,"b-", "LineWidth", 2)
        title(flds(fld));
        legend()
        savefig(f,output_filename+f.Children(2).Title.String + "_test.fig");
    end
    
end

%%

flds = ["S", "I", "H", "R", "D"];
fldsNum = [1 3 6 4 7];
for fld = 1 : length(fldsNum)
    for iter = Niter1
        n = max(cellfun(@(x) size(x, 2), tabR(iter, :)));
        m = min(cellfun(@(x) size(x, 2), tabR(iter, :)));
        vals = zeros(Niter2, n);
        hold on;
        popFactor = 1 / (3.3*families(iter));
        for iter2 = 1 : Niter2
            vals(iter2, 1:length(tabR{iter,iter2})) = popFactor*tabR{iter,iter2}(fldsNum(fld),:)';
        end
        meanVals = mean(vals, 1);
        
        p       = (fld-1)*4 ;
        simVals = sum(x(:, p+1 : p+4),2) / N0;
        tics    = 1 : n;
        simVals = interp1(t * freq, simVals, tics, "pchip");
        f = figure; 
        hold on;
        subplot(3, 1, 1);hold on;
        plot(tics, simVals, "b-")
        plot(tics, meanVals, "r.")
        legend()
        [d, ix, iy] = dtw(simVals(1:m), meanVals(1:m));
        subplot(3, 1, 2);hold on;
        plot(simVals(ix), "DisplayName", flds(fld)+" sim");
        plot(meanVals(iy), "DisplayName", flds(fld)+" agent");
        xlabel("ticks "+freq+"*days"); ylabel("num ppl")
        legend()
        subplot(3, 1, 3);hold on;
        plot(ix - iy, "DisplayName", flds(fld)+" agent - sim correction")
        title(flds(fld)+" correction");
        legend()
    end

    savefig(f,output_filename+f.Children(2).Title.String + "_test.fig");
end
    