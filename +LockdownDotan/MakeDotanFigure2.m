close
%x vec:
%  X: [S I H R D]
% x(1:4) = S,
% x(1) = Ssb, x(2)=Ssnb, x(3)= Snsnb, x(4) = Snsb
% x(5:8) = I,
% x(5) = Isb, x(6) = Isnb, x(7) = Insnb, x(8) = Insb
% x(9:12) = H,
% x(9) = Hsb, x(10) = Hsnb, x(11) = Hnsnb, H(12) = Hnsb
% x(13:16) = R,
% x(13) = Rsb, x(14) = Rsnb, x(15) = Rnsnb, x(16) = Rnsb
% x(17:20) = D.
% x(17) = Dsb, x(18) = Dsnb, x(19) = Dnsnb, x(20) = Dnsb
% s-susceptiblr- risk group. C - cautious - "believer".
%SC=1,SnC=2,nSnC=3,nSC=4
%SC=5,SnC=6,nSnC=7,nSC=8
%SC=9,SnC=10,nSnC=11,nSC=12
%SC=13,SnC=14,nSnC=15,nSC=16
%SC=17,SnC=18,nSnC=19,nSC=20
growth     = 3;
gamma      = 1/14;
N0 = 9e6;
beta(1)    = 0.05 * growth * gamma /N0; %infection from believer-believer.
beta(2)    = 0.15 * growth * gamma /N0; %infection rate believer-non believer.
beta(3)    = 1.00 * growth * gamma /N0; %infection rate non-believer - non-believer.
param(1:3) = beta;


% params(4:5):
% gamma: rate to transition out of I.
param(4)=gamma;
% gamma_H: rate to transition out of hospital.
param(5)=gamma;
% params(6:7):
% P_H: probability to move into hospital once finished with I.
% P_H(1): probability of hospitalization from Susceptible.
% P_H(2): probability of hospitalization from non-Susceptible.
param(6)=0.3;
param(7)=0.1;
% params(8:9):
% P_D: probability of death from hospital.
% P_D(1): death from Susceptible.
% P_D(2): death from non-susceptible.
param(8)=0.6;
param(9)=0.1;


options1 = odeset('NonNegative',20,"Refine",40);%all 20 parameters in the state vector are non-negative


p_susc=0.35;
%fraction of susceptible individuals
p_cautious=0.2;
%fraction of careful individuals

N0 = 9e6;

TtoQuarantine = 60;
pBgivenS = 0.1;
xtmp = nonSymCorr(p_susc,p_cautious,pBgivenS);
xtmp = xtmp(:);
xtmp = reshape(xtmp, 1, length(xtmp));
% xtmp=[(p_susc)*p_cautious p_cautious*(1-p_susc) ...
% (1-p_susc)*(p_cautious) ((1-p_susc))*(1-p_cautious)];

xinit=[N0*xtmp,0.0001*N0*xtmp,0*xtmp,0*xtmp,0*xtmp];  % ./1.25;

[xh,th] = runSEIRDotanNotReact(xinit, param, TtoQuarantine, options1);

S2=sum(xh(:,1:4),2);
I2=sum(xh(:,5:8),2);
H2=sum(xh(:,9:12),2);
R2=sum(xh(:,13:16),2);
D2=sum(xh(:,17:20),2);

[xnoQ,tnoQ] = runSEIRDotanNotReact(xinit, param, 364, options1);
InoQ=sum(xnoQ(:,5:8),2);
HnoQ=sum(xnoQ(:,9:12),2);

param2 = param;
param2(10)=0.9;

[xR,tR] = runSEIRDotanReact(xinit, param2, TtoQuarantine, options1, false);

S=sum(xR(:,1:4),2);
I=sum(xR(:,5:8),2);
H=sum(xR(:,9:12),2);
growth=sum(xR(:,13:16),2);
D=sum(xR(:,17:20),2);
pop2percent = 100 / N0;
f = figure;
hold on;
c{1} = [0.85 1 0.85];
c{2} = [1 0.85 0.85];
c{3} =[0.5 0.65  0.4]; % dark green
c{4} = [ 0.7   0.5  0.7]*0.8; % sorta purple
c{5} = [0.2 0.2 0.3];
c{6} = [0.2 0.3 0.2];
flims = [0 0  120 10];
shft = 1;
txTime = TtoQuarantine + 10 + shft;
[~, txInd] = min(abs(txTime - shft - tR));
txTime2 = TtoQuarantine + 30 + shft;
[~, txInd2] = min(abs(txTime2 - shft - tR));
r(1) = rectangle('Position',[flims(1:2) TtoQuarantine flims(4)], 'EdgeColor',"none", 'FaceColor',c{1});
r(2) = rectangle('Position',[TtoQuarantine flims(2:4)], 'EdgeColor',"none", 'FaceColor',c{2});

plot(tR,100*H*pop2percent,'LineWidth',2.2,"Color","red","DisplayName","response H"), hold on;
text(txTime, 100*H(txInd)*pop2percent-0.2, "response")

plot(tR,100*I*pop2percent,'LineWidth',2.2,"Color","blue","DisplayName","response I"),hold all
text(txTime, 100*I(txInd)*pop2percent+0.3*shft, "response");

plot(th,100*H2*pop2percent,'LineWidth',3,"Color",c{4},...
    "DisplayName","static H","LineStyle","--"), hold on;
text(txTime2, 100*H2(txInd2)*pop2percent-0.2, "no response")

plot(th,100*I2*pop2percent,'LineWidth',3,"Color",c{3},...
    "DisplayName","static I","LineStyle","--"), hold on;
text(txTime, 100*I2(txInd)*pop2percent, "no response")
xline(TtoQuarantine,'LineWidth',2,"Color","black", "DisplayName", "T_{Lockdown}", "LineStyle",":");
text(TtoQuarantine+1, 4, "Lockdown", "FontWeight", "bold")

% not lockdown no response
plot(tnoQ, 100*HnoQ*pop2percent,...
    'LineWidth',2.2,"Color",c{5}, "LineStyle", "--");
plot(tnoQ, 100*InoQ*pop2percent,...
    'LineWidth',2.2,"Color",c{6}, "LineStyle", "--");
hold on;
markTime = 95;
[~, ind] = min(abs(tnoQ - markTime));
text(90+6*shft, 100*HnoQ(ind)*pop2percent, "no lockdown", "FontSize", 10);


% mark the infected or hosp big noodles.
markTime = 30;
[~, ind] = min(abs(tR - markTime));
text(markTime-10, 100*H(ind)*pop2percent+shft*0.5, "Hospitalized", "FontWeight", "bold")
text(markTime-shft*10, 100*I(ind)*pop2percent+shft, "Infected", "FontWeight", "bold")
hold on;
l = legend();
l.Box = "off";
l.Visible = "off";
hold on;
xlabel("Time [days]");
ylabel("[%] percent of population");
title("responsive vs. non-responsive populations");
f.Color = "w";
grid on;
ylim(flims([2 4]));
xlim(flims([1 3]));

ax = gca;
ax.XTickMode = "auto";
set(ax,"Layer","top")
grid off
ax2_pos = [0.158 0.6 0.265 0.28];
ax2 = axes('Position',ax2_pos);
ext = load("ExternalI.mat");
Iext=interp1(ext.tt,ext.iext,th,"pchip");
p(1) = plot(ax2,ext.tt,ext.iext*100/sum(ext.xinit),"b-",...
    "DisplayName","Inf. Neighbors","LineWidth", 2); hold on;
[~, ind] = min(abs(ext.tt - 110));
text(40, ext.iext(ind)*100/sum(ext.xinit), p(1).DisplayName)

RiskNoCaution = xh(:,2);
transfer = param2(10).*RiskNoCaution.*Iext ./ sum(xh(1,:));
p(2) = plot(ax2,th,transfer*pop2percent,...
    "r:","DisplayName","Response","LineWidth", 3);
title(ax2,"Response to infected neighbors")
xlim(flims([1 3]));
ylim(flims([2 4]));
xl = xlim;
yl = ylim;
a = annotation(f, 'textarrow',[0.3 0.5],[0.6 0.5],...
    'String','elective response');
a.Position = [0.351,0.745,0.03,-0.0595];
% note_x = 0.75*flims(3)+0.25*flims(1);
% note_y = interp1(p(2).XData, p(2).YData, note_x);

grid(ax2,"on")
xlabel(ax2,"[days]");
ylabel(ax2,"[%]");
ax2.YAxisLocation = "right";
ax2.Box = "off";
l = legend();
l.Box = "off";
l.Visible = "off";
l.Location = "northwest";
xticks(linspace(xl(1),xl(2),5))
yticks(linspace(yl(1),yl(2),5))

loc = "C:\Users\yoel\Dropbox\SocialStructureGraph\matlab\SIRHRD model ode\figures";

if isfolder(fullfile(loc, datestr(today))) == false
    mkdir(fullfile(loc, datestr(today)));
end
    
savefig(f, fullfile(loc, datestr(today),"comparison lockdown.fig"))
saveas(f, fullfile(loc, datestr(today),"comparison lockdown.eps"),"epsc")
