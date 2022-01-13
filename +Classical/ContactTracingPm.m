
%This code calculates nq - the estimated number of infections given 
%a contact tracing operations
% clc
% ync=input('do you want to clear all? yes==1   ');
function [p,b] = ContactTracingPm(config)
Nruns=1e4; % 50625;
mone=1;
lower_E = 3; upper_E = 5;
lower_L = 2; upper_L = 4;
avgE=lower_E;nE=upper_E;  %  latency time  exponents
avgL=lower_L; % 4/3;
nL=upper_L;%3;  %  3 exponents used to form Erlang dist rate avgl shape nL.
avgSympt=2;TminSympt=3; % time to get symptoms
avg_tst=1;tmin_tst=0.5; % time from test to results.
avgib1=1 ; pib1 = 0.9;
avgib2 = 1/5;%0.5;
tminib=0;%0.5; % shifted exponential parameters
nmx=50;
try 
    pr
catch
    pr = 0.4
end
% pr=0.4;%chance to catch second ring in epidimiological investigation 
% tau_ib=exprnd(0.5,1,nmax)+0.5;
% ps=1/3;%probability to develop symptoms
% tau_symptoms=exprnd(3,1,nmax)+4;%time to develop symptoms 
%(from begining of infectious period)
% tauE=sum(exprnd(2.5,2,nmax));
% tauL=sum(exprnd(4/3,3,nmax));
% tauq=exprnd(1,1,nmax)+0.5;
% Pr=0.5; %prob to detect a person that belongs 
%to the first ring of infection

rec=[]; %  record of scenarios of sick people
nq=[]; % number of sick people per indivual
FIT=[]; 
for counter=1:Nruns
    ps=0.4; % probability of symptoms developing.
    tau_ib=pib1.* exprnd(avgib1,1,nmx)+(1-pib1).*exprnd(avgib2,1,nmx); % split exponent - tau ib
    tauE=window_func(avgE,nE,1); %  sum(exprnd(avgE,nE,1)); %  latency time
    tauL=window_func(avgL,nL,1); %  sum(exprnd(avgL,nL,1)); %  from infectious window start to end (after tau E).
    FirstInfectionTimes=tauE+cumsum(tau_ib); % first circle of infection time.
    % shifted exponential of time to develop symtoms starting with tauE
    tau_symptoms=exprnd(avgSympt,1,1)+TminSympt; 
    % time to be quarantined - I will be quarantined if im symptomatic,
    % with a positive test all my contacts will be isolated. 
    % TauQ is time for me to get positive answer.
    tauq=tauE+tau_symptoms+exprnd(avg_tst,1,1)+tmin_tst;
    
    r=rand;
    if r<ps
        noSymptoms=0;
    else
        noSymptoms=1;
    end
    if noSymptoms==1
        % remove the ones that got infected after i stopped being
        % infectious.
        FirstInfectionTimes=...
FirstInfectionTimes(FirstInfectionTimes<(tauE+tauL));
    else
        % remove also if I was symtomatic and then quarantined.
        FirstInfectionTimes=...
FirstInfectionTimes(FirstInfectionTimes<min(tauq,tauE+tauL));
    end
    %model first ring of person we using
    
    ltmp=length(FirstInfectionTimes);
    if ltmp>0 % if I infected anyone
        noSymptoms2=rand(1,ltmp)>ps; % are my infectees symtomatic
        tauE2=sum(window_func(avgE,nE,ltmp),1); %  sum(exprnd(avgE,nE,ltmp),1);  
        tauL2=sum(window_func(avgL,nL,ltmp),1);
        tau_symptoms2=exprnd(avgSympt,1,ltmp)+TminSympt;
        for k=1:ltmp%run over all second ring infections
            tauq2=tauE2(k)+tau_symptoms2(k)+exprnd(avg_tst,1,1)+tmin_tst;
            tau_ib2=pib1.* exprnd(avgib1,1,nmx)+(1-pib1).*exprnd(avgib2,1,nmx); % exprnd(avgib,1,nmx)+tminib;
            FirstInfectionTimes2=tauE2(k)+cumsum(tau_ib2);
            ti=tauE+FirstInfectionTimes(k); % when did I get infected rel to parent.
            if noSymptoms2(k)==1 %first ring dont have symptoms
                if noSymptoms==1%mother did not have symptoms
                    FirstInfectionTimes_=ti+...  % ltmp length vec for infection of gen.1
FirstInfectionTimes2(FirstInfectionTimes2<(tauE2(k)+tauL2(k)));
                    % case of no symtoms
                    rcrd(k)=1;%rcrd=1 mother and daugter dont have symptoms
                else%mother had symptoms
                    r2=rand;
                    if r2<pr  %   detected by the epid. inquiry
                        FirstInfectionTimes_tmp=ti+FirstInfectionTimes2; % vec. of ppl inf. by first gen.
                        [mn,mnind]=...
min([ti+tauE2(k)+tauL2(k),ti+tauE2(k)+tauq]); % did gen.1 infect or get quarantined first.
                        FirstInfectionTimes_=FirstInfectionTimes_tmp(...
                            FirstInfectionTimes_tmp<mn...
                            ); % are infectious gen1.
                        if mnind==1
                            rcrd(k)=2;%mother had symptoms but daughter was 
%quaratined too late to matter (after infectious window but no sympt.)
                        elseif mnind==2
                            rcrd(k)=3;%mother had symptoms daughter 
%quaratined (somewhat) effectivly (but daughter has no symptoms)
                        end
                    else%not detected by the epid. inquiry
                        % removes infections gen. 1 to gen. 2 that were
                        % after infectious window of gen.1
                        FirstInfectionTimes_tmp=ti+FirstInfectionTimes2;
                        FirstInfectionTimes_=...
FirstInfectionTimes_tmp(FirstInfectionTimes_tmp<(ti+tauE2(k)+tauL2(k)));
                        rcrd(k)=4;%mother has symptoms but daughter 
%undetected (and also with no symptoms) and hence not quarantied
                    end
                end
            else%second ring has symptoms
                if noSymptoms==1%mother did not have symptoms
                    [mn,mnind]=min([tauE2(k)+tauL2(k),tauq2]);
                    FirstInfectionTimes_=...
FirstInfectionTimes2(FirstInfectionTimes2<=mn);
                    if mnind==1
                        rcrd(k)=5;%mother has no symptoms, but daughter do, 
%but the quarantine was ineffective
                    elseif mnind==2
                        rcrd(k)=6;%mother has no symptoms, but daughter do, 
%and the quarantine was (somewhat) effective
                    end
                else  %   mother had symptoms - gen1 was missed, reached now from symptoms.
                    FirstInfectionTimes_tmp=ti+FirstInfectionTimes2; % gen2 infections
                    r=rand;
                    [mn,mnind]=...
min([(tauq*(r<pr)+1e12*(r>=pr)),ti+tauq2,ti+tauE2(k)+tauL2(k)]);
%  [mum quaratined me, I got quarantined while infecting, I finished
%  infecting
                    if mnind==1
                        rcrd(k)=7;%mother had symptoms, daugher too, 
                        % and the quarantine due to the mother was effective
                    elseif mnind==2
                        rcrd(k)=8;%mother had symptoms, daugher too, 
                        % and the quarantine due to the daughter was effective
                    elseif mnind==3
                        rcrd(k)=9;%mother had symptoms, daugher too, 
                        % and the quarantine was ineffective;
                    end
                    % infection chains cut!
                    FirstInfectionTimes_=...
FirstInfectionTimes_tmp(FirstInfectionTimes_tmp<=mn);
                end
            end
        end
        % how many people did I infect.
        nqtmp(mone)=length(FirstInfectionTimes_);
        mone=mone+1;
        clear FirstInfectionTimes_
        %else
        %nqtmp(mone)=0;
        %mone=mone+1;
        %rcrd=0;
    else
        nqtmp(mone)=0;
        mone=mone+1';
    end
    rec=[rec,rcrd];
    counter;
end
nq=nqtmp;
[b,p]=myhist(nq,0:50);
[br,type_pr]=myhist(rec,0:9)
end

function res =window_func(lower_lim,upper_lim,outsize)
if nargin == 2
    outsize =1;
end
    res = rand(1,outsize) .* (upper_lim - lower_lim) + lower_lim;
end

