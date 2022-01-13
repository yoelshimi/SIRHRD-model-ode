% script for creating graphs and plots from SIRHRD model. called by main.

Xs = ["Ssb","Ssnb","Snsnb","Snsb","Isb","Isnb","Insnb","Insb","Hsb","Hsnb",...
    "Hnsnb","Hnsb","Rsb","Rsnb","Rnsnb","Rnsb","Dsb","Dsnb","Dnsnb","Dnsb"];
figure;
s = semilogy(t,x,'LineWidth',2); grid on, xlabel('days'),shg
legend(Xs)
n = length(t);
% for iter=1:length(s)
%     switch mod(iter,4)
%         case 0
%             s(iter).Marker = 'x';
%         case 1
%             s(iter).Marker = 'o';
%         case 2
%             s(iter).Marker = '*';
%         case 3
%             s(iter).Marker = 'p';
%     end
% end    
xlim([0 5e2])
ylim([1e-2 4*N0])
f = figure;
subplot(1,2,1); 
disp("R should be: "+param(1)*N0/param(4));
pie(x(end,:)/N0,Xs)
subplot(1,2,2); 
Xtab = array2table(x,"VariableNames",Xs);
bar(categorical(Xs),x(end,:))   
figure(3); hold on; plot(t_interp, sum(x_interp(:,9:12),2)); hold on;...
    plot(t_interp,sum(x_interp(:,17:20)')); legend("hospitalized", "Dead")

x_start = find(islocalmin(x_interp(:,5)));
[~,x_max_i] = max(x_interp(:,5));
ef = expfit(x_interp(x_start:x_max_i/2,5))  

