set(groot, 'defaultLegendItemHitFcn', @hitcallback_ex1);
cd("C:\Users\yoel\Dropbox\SocialStructureGraph\matlab")
% our file = ls("..\statistical materials\hosp israel 20-21.xlsx")
fdr       = "..\statistical materials\vaxTest";
hosp      = handleFiles(readtable(fullfile(fdr,"critical.xlsx")));
vaxPerDay = handleFiles(readtable(fullfile(fdr,"daily vaccination.xlsx")));
Rdaily    = handleFiles(readtable(fullfile(fdr,"R rate.xlsx")));
infected  = handleFiles(readtable(fullfile(fdr,"infected.xlsx")));

infectedAndVax = handleFiles(readtable(fullfile(fdr, "positive and vaccinated.xlsx")));
hospAndVax     = handleFiles(readtable(fullfile(fdr, "hospital - vaccinated.xlsx")));

R0      = calcR0MOH(infected.x1, 1:length(infected.t), 1:length(infected.t));
R0fixed = movmean(R0, 7);
figure; 
subplot(2,2,1);
plot(infected.t, R0fixed.^1.1); hold on; 
plot(Rdaily.t(12:end), Rdaily.x1(12:end))
hold on; plot(ones(length(R0fixed), 1), "k-");
l = legend("R0_{yoel}", "R0_{MOH}", "threshold");
xlabel("Time [days]"); ylabel("R0"); title("R0 comparison")

firstVaxTime = vaxPerDay.t(1);
% basicGrRate, before vaccinations.
beforeVaxT  = infected.t < vaxPerDay.t(1);
[~, t0]     = min(infected.x1(beforeVaxT));
freeTime    = t0 : find(beforeVaxT, 1, "last");
infs        = movmean(infected.x1(freeTime), 7);
infT        = infected.t(freeTime);
[f0,gof]    = fit(freeTime(:),infs(:),'exp1');

subplot(2, 2, 2);
plot(infT, infs(:), "r.-"); 
hold on;
plot(infT, f0.a * exp(freeTime * f0.b), "b");
l = legend("infections", "fit: "+f0.a+"e^{"+f0.b+"t}");
xlabel("Time [days]"); ylabel("new infections")

subplot(2,2,3)
[b,g] = sgolay(3,7);

x  = log(infs);
dx = zeros(length(x),4);
for p = 0:3
  dx(:,p+1) = conv(x, factorial(p)/(-1)^p * g(:,p+1), 'same');
end
% plot(x,'.-')
hold on
plot(infT, dx(:,2));
plot(infT, zeros(length(dx), 1), "k");
ylim([-0.5 0.5]); xlabel("time"); ylabel("diff(exp(data))");
title("local growth rate"); l = legend("discrete exp growth", "threshold")
hold off
subplot(2, 2, 2); hold on; plot(infT, dx(:,1), "k");
growthRegions = single(dx(:,2) > 0);
subplot(2, 2, 4); plot(infT, growthRegions, "b.-"); 
hold on; plot(infT, hampel(growthRegions),"r.-")
ylim([-0.2 1.2])
%%
% ----- run tests on vaccinated  data ---- % 
firstVaxInd     = find(~beforeVaxT, 1, "first");
vaccinationTime = infected.t(firstVaxInd) : infected.t(end, :);
vaxInd          = firstVaxInd : firstVaxInd + length(vaccinationTime) - 1;
infs            = movmean(infected.x1(getTimeInds(vaccinationTime, infected.t)), 7);
hosps           = hosp(getTimeInds(vaccinationTime, hosp.t), :);
vaccines        = movmean(vaxPerDay.x1, 7);

figure; 
% subplot(2, 2, 2);
plot(vaccinationTime, infs(:), "ro");  hold on;
plot(vaccinationTime, vaccines, "bo"); hold on;
plot(vaccinationTime, hosps.x1, "ko")
legend("infections", "vaccinations", "critical");

xlabel("Time [days]"); ylabel("new infections")

[b,g] = sgolay(3,7);

x = log(infs);
dx = zeros(length(x),4);
for p = 0:3
  dx(:,p+1) = conv(x, factorial(p)/(-1)^p * g(:,p+1), 'same');
end

% figure; plot(vaccinationTime, dx(:,2))

% find vaccinated efficiency, compliance, 
%  such that the growth rate achieved is that from 1.3.21 - 1.5.21

decreaseTimeStart = datetime(2021, 03, 01);
decreaseTimeEnd   = datetime(2021, 05, 01);
decreaseT         = decreaseTimeStart : decreaseTimeEnd;
dInds             =  days(decreaseT - decreaseT(1))';
dInfs             = infected.x1(getTimeInds(decreaseT, infected.t));
[decreaseInfRate, gof] = fit(dInds, dInfs,'exp1');

dHosp             = hosp.x1(getTimeInds(decreaseT, hosp.t));
[decreaseHospRate, gof2] = fit(dInds,dHosp,'exp1');

rates = [decreaseInfRate.b, decreaseHospRate.b];
fits  = {decreaseInfRate, decreaseHospRate};

hold on; 
plot(decreaseT, expFitVals(decreaseInfRate, dInds), "r-", ...
    "DisplayName", "infection fit R: "+gof.adjrsquare); hold on;
plot(decreaseT, expFitVals(decreaseHospRate, dInds), "k-", ...
    "DisplayName", "hospital fit R: "+gof2.adjrsquare);

%%
vaxToNow = cumsum(vaxPerDay.x1 + vaxPerDay.x2) / 2;
% now find params that reflect this.
N0   = 9e6;
p_h_l=  [0.2,0.2/10];
pD_l = [0.2,0.05];
p_susc = vaxToNow(find(decreaseTimeStart <= vaxPerDay.t, 1, "first")) / N0;
init_hosp = hospAndVax(hospAndVax.t == decreaseTimeStart, :);
risk_init_hosp = init_hosp(init_hosp.x14 == "over 60", :);
safe_init_hosp = init_hosp(init_hosp.x14 == "under 60", :);
hosp_and_vax = 2;
hosp_not_vax = 4;

% x(1) = Ssb, x(2)=Ssnb, x(3)= Snsnb, x(4) = Snsb
hosp_at_start  = [risk_init_hosp.("x"+hosp_and_vax); risk_init_hosp.("x"+hosp_not_vax);
    safe_init_hosp.("x"+hosp_not_vax); safe_init_hosp.("x"+hosp_and_vax)];

init_inf = infectedAndVax(infectedAndVax.t == decreaseTimeStart, :);
risk_init_inf = init_inf(init_inf.x8 == "over 60", :);
safe_init_inf = init_inf(init_inf.x8 == "under 60", :);
inf_and_vax = 2;
inf_not_vax = 4;

% x(1) = Ssb, x(2)=Ssnb, x(3)= Snsnb, x(4) = Snsb
inf_at_start  = [risk_init_inf.("x"+inf_and_vax); risk_init_inf.("x"+inf_not_vax);
    safe_init_inf.("x"+inf_not_vax); safe_init_inf.("x"+inf_and_vax)];
%  test variable is vaccine efficacy, and probability of caution.
% p_cautious;
% vaxEfficiency;% between 0 and 1
SimInput  = CSimInput("N0",N0,"pH",p_h_l,'pD',pD_l,...  
        'p_susc',p_susc,'p_cautious',0,'R',3, ...
        "corr", 1, "tspan", [min(dInds) max(dInds)]);
SimInput.beta = 3 * SimInput.gamma;

% riskInfectedVax = infectedAndVax(infectedAndVax.t == firstVaxTime & ...
%     infectedAndVax.x8 == "over 60", :).x2;
% safeInfectedVax = infectedAndVax(infectedAndVax.t == firstVaxTime & ...
%     infectedAndVax.x8 == "under 60", :).x2;
initStruct =  struct("inf_0",inf_at_start,"hosp_0", hosp_at_start);

testFunc = @(eff, caution) testVaxDecrease(eff, caution, SimInput, dInfs, dHosp,...
    initStruct);

qualTestExp  = @(input) sum(((testFunc(input(1), input(2)) - rates)./rates).^2);

fitDataFun   = @(input) testFunc(input(1), input(2));

A = [1 0; 0 1; -1 0; 0 -1;]; 
b = [1; 1; 0; 0;];
[vals,fval, ~, op]   = fmincon(qualTestExp, [0.1, 0.4], A, b); %, [0 0], [1 1]);
[vals2, ~, ~, ~, op2]   = lsqnonlin(@(x) errfun(x, testFunc), vals, b(3:4), b(1:2));
%%
[rates, err, x, t, gofs, runInputs] = testVaxDecrease(vals2(1), vals2(2),...
    SimInput, dInfs, dHosp, initStruct);

infs = sum(x(:, 5:8), 2);
% alternately:
bad_corr_xinit = runInputs.xinit;
% all susc. transfer to not cautious.
p_transfer = 0.3;
transfer_matrix   = eye(20);
S_transfer_matrix = eye(4);
S_transfer_matrix(1, 1) = 1 - p_transfer;
S_transfer_matrix(2, :) = [p_transfer 1 0 0];
S_transfer_matrix(3, :) = [0 0 1 p_transfer];
S_transfer_matrix(4, :) = [0 0 0 1-p_transfer];
transfer_matrix(1:4, 1:4) = S_transfer_matrix;
bad_corr_xinit = transfer_matrix * bad_corr_xinit';

[x2, t2] = SEIRodeSolver_YR(runInputs.tspan, runInputs.param, bad_corr_xinit);

bad_infs = sum(x2(:, 5:8), 2);
bad_hosp = sum(x2(:, 9:12), 2);

% build figure
f = figure;
plot(decreaseT, dInfs, "rd", "MarkerFaceColor", [1 0.8 0.8], "MarkerSize", 8,...
    "DisplayName", "infection data", "LineWidth", 2);
hold on;

plot(decreaseTimeStart + t, infs, ...
    "r-", "LineWidth", 3, "DisplayName", "infections fitted");

plot(decreaseTimeStart + t2, bad_infs, "LineStyle", ":", "Color", [1 0.7 0.7]*0.7, ...
    "DisplayName", "infections degraded", "LineWidth", 4);

plot(decreaseT, dHosp, "bo", "MarkerFaceColor", [0.8 0.8 1], "MarkerSize", 8,...
    "DisplayName", "hospitalized data", "LineWidth", 2);
plot(decreaseTimeStart + t, sum(x(:, 9:12), 2),...
    "b-", "LineWidth", 3, "DisplayName", "hospitalized fitted");
title("vaccine influence fitted data", "FontSize", 12)

plot(decreaseTimeStart + t2, bad_hosp,  "LineStyle", "--", "Color", [0.7 0.8 1]*0.5, ...
    "DisplayName", "hospitalized degraded", "LineWidth", 4);

h = gca;
h.YAxis.FontWeight = 'bold';
h.XAxis.FontWeight = 'bold';

xlabel("date");
ylabel("number of people");
ylim([1e2 1e4])
xlim(decreaseTimeStart + [0 60])
f.Children.YScale = "log";

box off
l = legend();
l.Position = [0.5720 0.6187 0.3018 0.2440];
l.Box = "off";
l.AutoUpdate = "off";
l.Visible = "off";

h = get(gca, "Children");
order = [3 2 6 5 1 4];
set(gca,'Children',h(order));

% add text labels to figure:
plots = f.Children(arrayfun(@(x) x.Type == "axes", f.Children)).Children;
positions = zeros(length(plots), 4);
positions(3, :) = [0.3482,0.7286,-0.1,0]; 
positions(2, 1:2) = [2.3036,350.088];
positions(1, :) = [0.784,0.377,0.0117,-0.182];
positions(4, 1:2) = [22.0737,1623.446];
positions(5, 1:2) = [40.322,1759.696];
positions(6, 1:2) = [40.737,6146.33];


annotOrText = contains({plots.DisplayName}, "data", "IgnoreCase", true);

displayInd = round(length(decreaseT)/3);
displayT = decreaseT(displayInd);

for iter = 1 : length(plots)
    if annotOrText(iter) 
        txts(iter) = annotation("textarrow", "Position", ...
            positions(iter, :),...
            "string" , plots(iter).DisplayName);
    else 
        dataP = interp1(plots(iter).XData, plots(iter).YData, displayT);
        txts(iter) = text(displayT, dataP, ...
            plots(iter).DisplayName);
        txts(iter).Position = positions(iter, 1:2);
    end
end

fdr = mfilename("fullpath");
if contains(fdr, "temp", "ignorecase", true)
    fdr = "C:\Users\yoel\Dropbox\SocialStructureGraph\matlab\1\1"
end
fparts = strsplit(fdr,filesep());
fparts = fparts(1:end-2);
fdr = strjoin(fparts,filesep());
fdr = fullfile(fdr,"figures",datestr(today));
if isfolder(fdr) == false
    mkdir(fdr);
end

savefig(f, fullfile(fdr,"vaccinationData"+".fig"));
saveas(f, fullfile(fdr,"vaccinationData"+".eps"),"epsc");
%%
SimInput.betaList = [1 1 1];
[tspan, param, xinit] = SimInput.getODEParams();
vaxToNow = sum(vaxPerDay.x2(vaxPerDay.t < decreaseTimeStart));
riskPortion = 1/3;
xinit(1:4) = [vaxToNow*riskPortion, (SimInput.N0 - vaxToNow)*riskPortion,... 
    (SimInput.N0 - vaxToNow)*(1-riskPortion), vaxToNow*(1-riskPortion)];
xinit(5:8) = inf_at_start;
xinit(9:12) = hosp_at_start;
fitSIHRDparams(xinit, param, dInds, dInfs, "inf", "efficiency")
