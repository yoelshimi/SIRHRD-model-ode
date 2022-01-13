 %israel population graph virus beta=0.15 lockdown=0.0 23.4.20.csv                  
%israel population graph virus beta=0.15 lockdown=0.05 23.4.20.csv                 
%israel population graph virus beta=0.15 lockdown=0.1 23.4.20.csv                  
%israel population graph virus beta=0.15 lockdown=0.15 23.4.20.csv  
%israel population graph virus beta=0.15 lockdown=0.2 23.4.20.csv                  
%israel population graph virus beta=0.15 lockdown=0.25 23.4.20.csv                 
%israel population graph virus beta=0.15 lockdown=0.3 23.4.20.csv  
%israel population graph virus beta=0.15 lockdown=0.35 23.4.20.csv  
%israel population graph virus beta=0.15 lockdown=0.4 23.4.20.csv                  
%israel population graph virus beta=0.15 lockdown=0.45 23.4.20.csv                 
%israel population graph virus beta=0.15 lockdown=0.5 23.4.20 (1).csv              
%israel population graph virus beta=0.15 lockdown=0.5 23.4.20.csv                  
%israel population graph virus beta=0.15 lockdown=0.55 23.4.20.csv
k=1;
str='israel population graph virus beta=0.15 lockdown=0.0 23.4.20.csv';
u(1)=0;
M=importdata(str);
M=M';
y=M(:,3);
t=1:length(M);
[mx,mxind]=max(y);
N=mean(sum(M,2));
pmx(1)=mx/N;
tmx(1)=mxind;
figure(1), plot(t,y),hold all
clear M
k=k+1;
str='israel population graph virus beta=0.15 lockdown=0.05 23.4.20.csv';
u(k)=0.05;
M=importdata(str);
M=M';
y=M(:,3);
t=1:length(M);
[mx,mxind]=max(y);
N=mean(sum(M,2));
pmx(k)=mx/N;
tmx(k)=mxind;
figure(1), plot(t,y),hold all

clear M
k=k+1;
str='israel population graph virus beta=0.15 lockdown=0.1 23.4.20.csv';
u(k)=0.1;
M=importdata(str);
M=M';
y=M(:,3);
t=1:length(M);
[mx,mxind]=max(y);
N=mean(sum(M,2));
pmx(k)=mx/N;
tmx(k)=mxind;
figure(1), plot(t,y),hold all

clear M
k=k+1;
str='israel population graph virus beta=0.15 lockdown=0.15 23.4.20.csv';
u(k)=0.15;
M=importdata(str);
M=M';
y=M(:,3);
t=1:length(M);
[mx,mxind]=max(y);
N=mean(sum(M,2));
pmx(k)=mx/N;
tmx(k)=mxind;
figure(1), plot(t,y),hold all

clear M
k=k+1;
str='israel population graph virus beta=0.15 lockdown=0.2 23.4.20.csv';
u(k)=0.2;
M=importdata(str);
M=M';
y=M(:,3);
t=1:length(M);
[mx,mxind]=max(y);
N=mean(sum(M,2));
pmx(k)=mx/N;
tmx(k)=mxind;
figure(1), plot(t,y),hold all

clear M
k=k+1;
str='israel population graph virus beta=0.15 lockdown=0.25 23.4.20.csv';
u(k)=0.25;
M=importdata(str);
M=M';
y=M(:,3);
t=1:length(M);
[mx,mxind]=max(y);
N=mean(sum(M,2));
pmx(k)=mx/N;
tmx(k)=mxind;
figure(1), plot(t,y),hold all

clear M
k=k+1;
str='israel population graph virus beta=0.15 lockdown=0.3 23.4.20.csv';
u(k)=0.3;
M=importdata(str);
M=M';
y=M(:,3);
t=1:length(M);
[mx,mxind]=max(y);
N=mean(sum(M,2));
pmx(k)=mx/N;
tmx(k)=mxind;

clear M
k=k+1;
str='israel population graph virus beta=0.15 lockdown=0.35 23.4.20.csv';
u(k)=0.35;
M=importdata(str);
M=M';
y=M(:,3);
t=1:length(M);
[mx,mxind]=max(y);
N=mean(sum(M,2));
pmx(k)=mx/N;
tmx(k)=mxind;
figure(1), plot(t,y),hold all

clear M
k=k+1;
str='israel population graph virus beta=0.15 lockdown=0.4 23.4.20.csv';
u(k)=0.4;
M=importdata(str);
M=M';
y=M(:,3);
t=1:length(M);
[mx,mxind]=max(y);
N=mean(sum(M,2));
pmx(k)=mx/N;
tmx(k)=mxind;
figure(1), plot(t,y),hold all

clear M
k=k+1;
str='israel population graph virus beta=0.15 lockdown=0.45 23.4.20.csv';
u(k)=0.45;
M=importdata(str);
M=M';
y=M(:,3);
t=1:length(M);
[mx,mxind]=max(y);
N=mean(sum(M,2));
pmx(k)=mx/N;
tmx(k)=mxind;
figure(1), plot(t,y),hold all

clear M
k=k+1;
str='israel population graph virus beta=0.15 lockdown=0.5 23.4.20.csv';
u(k)=0.5;
M=importdata(str);
M=M';
y=M(:,3);
t=1:length(M);
[mx,mxind]=max(y);
N=mean(sum(M,2));
pmx(k)=mx/N;
tmx(k)=mxind;
figure(1), plot(t,y),hold all

clear M
k=k+1;
str='israel population graph virus beta=0.15 lockdown=0.55 23.4.20.csv';
u(k)=0.55;
M=importdata(str);
M=M';
y=M(:,3);
t=1:length(M);
[mx,mxind]=max(y);
N=mean(sum(M,2));
pmx(k)=mx/N;
tmx(k)=mxind;
figure(1), plot(t,y),hold all

figure
plot(u,pmx),hold all
figure
plot(u,tmx),hold all