cd("C:\Users\yoel\Dropbox\SocialStructureGraph\matlab")
addpath("SIRHRD model ode\correlation");
format long g
tic;
code_path = "C:\Users\yoel\Documents\army\corona\rami_simulation\python";
fdr_stc = 'israel population graphvalid';
fdr_rnd = 'random graphvalid';
space = " ";
command = "python";
run_file = "basic_run.py";
families = 5000;
if ~exist('p_susc','var')
    p_susc = 0.3;
end
p_init = 0.01;
R = 5;
gamma = 1/10;% recovery rate
beta = R*gamma;
alpha = 0; % no latency.
b_l = [0 0 3]; % betas: 1: BB, 2:nBB, 3: nBnB
gammaH = 1/20; % rate of move out of hospital.
N0 = families*3.3;

p_h_l =[0.2 0.2]; %  [0.2,0.2/10];
pD_l=[0.2 0.2]; % [0.2,0.05];

is_plot = false;
freq = 24;
output_filename = "valid\res"
corrs = -1:0.1:1;
RGmode = "sb"  
corr = -0.2;% corrs(iter);
mat = good_corr(corr, p_susc);
mat(mat(:)<0.001) = 0
to_run = command+space+code_path+filesep()+run_file+space+" -n "+families...
+" -p "+is_plot+" -o "+output_filename+" -p_i "+p_init+" -b "+beta+" -a "+alpha+" -g "...
+gamma+" -f "+freq+" -b_l "+b_l(1)+" "+b_l(2)+" "+b_l(3)+" -g_h "+gammaH + " -p_h_l "+...
p_h_l(1)+" "+p_h_l(2)+" -p_d_l "+pD_l(1)+" "+pD_l(2)+" -sbc_l "+mat(1,1)+space...
+mat(1,2)+space+mat(2,1)+space + mat(2,2)+" -rng "+RGmode; 
for iter = 1:11
    result = system(to_run)

    tab{iter} = readmatrix(fullfile(fdr_stc,"res.csv"));

    tab2{iter} = readmatrix(fullfile(fdr_rnd,"res.csv"));
end
% t2 = 1:1/freq:1/freq*length(tab);
% t2 = 1:1/freq:81;
% t2 = t2(1:end-1);
%%
C = corr;
mat = good_corr(C, p_susc);
sb = mat(1,2); snb = mat(1,1); nsnb = mat(2,1);nsb = mat(2,2);

xinit = [sb*N0; snb*N0; nsnb*N0; nsb*N0; ones(4,1)*p_init*N0/4; zeros(12,1)];
xinit = xinit / sum(xinit) * N0; 
tspan=[0,365];
param=[beta.*b_l/N0 gamma gammaH p_h_l pD_l];
[x,t]=SEIRodeSolver_YR(tspan,param,xinit);
longt = t;
ind_last = find(t<81,1,'last');
inds = 1:ind_last;
t = t(inds);
S = sum(x(inds,1:4),2);
I = sum(x(inds,4+(1:4)),2);
H = sum(x(inds,8+(1:4)),2);
R = sum(x(inds,12+(1:4)),2);
D = sum(x(inds,16+(1:4)),2);
%%
for iter = 1:11
    hold on
    t2_1 = 1/freq*(1:length(tab{iter}));
    t2_2 = 1/freq*(1:length(tab2{iter})); 
    subplot(2,2,1);
    semilogy(t,S,"kp-");
    hold on; semilogy(t2_1,tab{iter}(1,:)); 
    hold on; semilogy(t2_2,tab2{iter}(1,:)); 
    title("S");
    legend("ODE","structure","random")
    subplot(2,2,2);

    semilogy(t,I,"kp-");
    hold on; semilogy(t2_1,tab{iter}(3,:)); 
    hold on; semilogy(t2_2,tab2{iter}(3,:)); 
    title("I");
    legend("ODE","structure","random")
    subplot(2,2,3);
    semilogy(t,R,"kp-");
    hold on; semilogy(t2_1,tab{iter}(4,:)); 
    hold on; semilogy(t2_2,tab2{iter}(4,:)); 
    title("R");
    legend("ODE","structure","random")
    subplot(2,2,4);
    semilogy(t,D,"kp-");
    hold on; semilogy(t2_1,tab{iter}(7,:)); 
    hold on; semilogy(t2_2,tab2{iter}(7,:));
    title("D");
    legend("ODE","structure","random");
end
