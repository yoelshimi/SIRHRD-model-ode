% clear Nevents tauIB tauE tauL tauIBrnd tauErnd nG G X Event Now What Who NextEventTime NextEventTime NextEventNode counter X I E R t s muth
clear Nevents tauIB tauE tauL tauIBrnd tauErnd nG X Event Now What Who NextEventTime NextEventTime NextEventNode counter X I E R t s muth
%function runSEIR(x,G,tauL,tauE,tauIB,Nevents)
tic
nG = 2000 %  2*8192;%number of nodes
SuperSpread=0;
if 0%Fully connected graph
    G=ones(nG).*(~eye(nG));
    d=nG;
end
if 0%random d-regular graph
%     if ~exist("d")
%         d=3
%     end
    isregm = 0;
    while isregm == 0
        [G,isregm] = RandomRegularGraph(nG, d);
    end
    "new graph"
end
if 0
    d=2;
    [G,isregm] = RandomRegularGraph(nG, d);
    if isregm==0
        [G,isregm] = RandomRegularGraph(nG, d);
    end
    rndprm=randperm(nG);
    ind=rndprm(1:round(0.075*nG));
    for k=1:length(ind)
        rndind=randperm(nG);
        rndind=setdiff(rndind,ind);
        G(ind(k),rndind(1:7))=1;
        G(rndind(1:7),ind(k))=1;
    end
    
end
if new_graph_flag %Exponetial graph
    G=false(nG);
    if ~exist('d','var')
        d=6;
    end
    for k=1:nG
        numneig=round(exprnd(d));
        rndprm=randi(nG,numneig);% randperm(nG);
        selfloop = rndprm==k;
        while sum(selfloop)>0
            rndprm(selfloop) = randi(nG,numneig);
            selfloop = rndprm==k;
        end
%         rndprm(rndprm==k)=[];
        G(k,rndprm(1:numneig))=1;
        G(rndprm(1:numneig),k)=1;
    end
end
if 0
    d=6;
    OutDegree=exprnd(d,1,nG);
    G=makeGraphWithGivenDegreeDistribution(nG,OutDegree);
end
if 0
    %OutDegree=floor(gevrnd(.5,1,2,1,nG));
    OutDegree=floor(gevrnd(.7,0.9,1.3,1,nG));
    OutDegree(OutDegree==0)=1;
    G=makeGraphWithGivenDegreeDistribution(nG,OutDegree);
end
if 0
    SuperSpread=1;
    OutDegree=zeros(1,nG);
    OutDegree(1:round(nG*0.8))=1;
    OutDegree((1+round(nG*0.8)):(1+round(nG*0.8)+round(nG*0.1)))=3;
    OutDegree((2+round(nG*0.8)+round(nG*0.1)):end)=4;
    OutDegree=OutDegree(randperm(nG));
    G=makeGraphWithGivenDegreeDistribution(nG,OutDegree);
end
Nevents=16*8192;
tauE=3;
tauL=5;
%tauIB= 1.6667*mean(sum(G>0,2));
tauIB=tauL/2;
%tauib (of a single infector) = (tauIB/d)
%tauL/(tauIB/d)

tauIBrnd=exprnd(tauIB,1,1e6);
tauErnd=exprnd(tauE,1,1e6);
tauLrnd=exprnd(tauL,1,1e6);

%event type
%Type == 1 Susceptivle to exposed S--->E
%Type == 2 Exposed to Infected    E--->I
%Type == 3 Infected to recovered  I--->R

X=zeros(1,nG);
%X = state  (S,E,I,R)
%X == 0 (Suceptible)
%X  == 1 (Exposed)
%X  == 2 (Infected)
%X  == 3 (Recovered)

Event.Times=inf*ones(1,nG);%initialy all the events happen at infinity expect the first infection
Event.Types=ones(1,nG);
rndprm=randi(nG);
Event.Times(rndprm(1))=0.001;

clear rndprm
Infector = nan(1,nG);
Inf_Time = nan(1,nG);
%Event.Times = a vector of length nG
%Event.Type = a vector of length nG
[NextEventTime,NextEventNode]=min(Event.Times);
NextEventType=Event.Types(NextEventNode);
% --- init loop vals ---
counter=1;cntr=1;k=1;
E(k)=sum(X==1);
I(k)=sum(X==2);
R(k)=sum(X==3);
Now=NextEventTime;
t(k)=Now;

while k<Nevents && Now < Inf %main event loop
    k=k+1;
    t(k)=Now;

    Now=NextEventTime;
    What=NextEventType;
    Who=NextEventNode;

    if What==1 %S--->E
        X(Who)=1;
        Event.Times(Who)=Now+tauErnd(counter);%time to start being infectious
        counter=counter+1;
        Event.Types(Who)=2;
        E(k)=E(k-1) +1 ;
        I(k)=I(k-1);
        R(k)=R(k-1);
        %t_ib_population(cntr)=now;
        %cntr=cntr+1;
    elseif What==2% E--->I
        X(Who)=2;
        Event.Times(Who)=Now+tauLrnd(counter);%time until recovery
        counter=counter+1;
        Event.Types(Who)=3;
        neighbors=find(G(Who,:)==1);
        Inf_Time(Who) = Now;
        for kk=1:length(neighbors)%run over all neighbors and infect the suceptibles
            if X(neighbors(kk))==0
                CandidateNextEventTime=Now+tauIBrnd(counter);
                counter=counter+1;
                if (CandidateNextEventTime<Event.Times(neighbors(kk)))&&(CandidateNextEventTime<Event.Times(Who))
                    Event.Times(neighbors(kk))=CandidateNextEventTime;
                    Event.Types(neighbors(kk))=1;
                    Infector(neighbors(kk)) = Who;
                end
            end
        end
        E(k)=E(k-1) -1 ;
        I(k)=I(k-1) +1;
        R(k)=R(k-1);
    elseif What==3%I--->R
        X(Who)=3;
        Event.Times(Who)=inf;
        counter=counter+1;
        Event.Types(Who)=4;
        E(k)=E(k-1);
        I(k)=I(k-1) -1;
        R(k)=R(k-1) +1;
    end
    [NextEventTime,NextEventNode]=min(Event.Times);
    NextEventType=Event.Types(NextEventNode);
    if counter>=9e5
        tauIBrnd=exprnd(tauIB,1,1e6);
        tauErnd=exprnd(tauE,1,1e6);
        tauLrnd=exprnd(tauL,1,1e6);
        counter=1;
    end
end

if length(t) < length(I)
    I = I(1:length(t));
elseif length(I) < length(t)
    t = t(1:length(I));
end
figure(1); hold on;
semilogy(t,I)

%calculate growth rate
%for expoential case only we have:
n_=0:1:200;
s=(1e-6):(1e-6):1;
cv=(std(sum(G>0,2)))./mean(sum(G>0,2));
% if 0
%     tauib=tauIB/mean(sum(G>0,2));
% else
%     tauib=tauIB.*(1./(1+cv.^2))./mean(sum(G>0,2));
% end
tauib=tauIB;
qn=(tauib/tauL)./(1+(tauib/tauL)).^(n_+1);
tauErnd=exprnd(tauE,1,2000);
if 0
    qnmc=zeros(1,2000);
    for k=1:1e6
        tauIBrnd=exprnd(tauIB,1,2000);
        tauLrnd=exprnd(tauL,1,1);
        tibcs=cumsum(tauIBrnd);
        tmp=find(tibcs>tauLrnd,1);
        if isempty(tmp)==0
            qnmc(1)=qnmc(1)+1;
        else
            qnmc(tmp+1)=qnmc(tmp+1)+1;
        end
    end
end
Pib=1./(1+s*tauib);
L=0*Pib;
for k1=1:length(n_)
    L=L+qn(k1)*Pib.^(k1);
end
PE=1./(1+tauE*s);
minF=Pib.*(PE.*(1-L)+1)-1;
[mn,mnind]=min(abs(minF));
muth=s(mnind);
shift=-5.0;
% hold all,plot(t(t<66)+shift,exp(2*muth*t(t<66)),'--r')
shg
toc
R = 1./(1-max(I)/nG)

%%
tic;
infectees = num2cell(Inf_Time);
for iter = 1:nG
    ind =  Infector(iter);
    if ~isnan(ind) 
        infectees(ind) =  {[infectees{ind}; Inf_Time(iter)]};
    end
end
toc;
t_ib = cellfun(@(x) diff(sort(x)), infectees, 'UniformOutput', false);
figure(2); hold on; histogram(cell2mat(t_ib'),'Normalization','probability')
toc;
Qn_emp = cellfun(@(x) length(x), infectees);
[b,p] = myhist(Qn_emp,max(Qn_emp)+1); % what if someone doesnt get infected?
R_actual = dot(p,0:length(b)-1)
