close all
clear

N0 = 9e6;
% positive correlation - if susceptible then believer else not
part_susceptible = 0.7;
xinit=[N0; 0; N0; 0; ones(4,1)*1e-3*N0/4; zeros(12,1)];
xinit([1 2]) = part_susceptible*xinit([1 2]);
xinit([3 4]) = (1-part_susceptible)*xinit([3 4]);
xinit = xinit / sum(xinit) * N0; 
main
exes.corr1 = x_interp;
exes.t = t_interp;

xinit=[N0; N0; N0; N0; ones(4,1)*1e-3*N0/4; zeros(12,1)];
xinit([1 2]) = part_susceptible*xinit([1 2]);
xinit([3 4]) = (1-part_susceptible)*xinit([3 4]);
xinit = xinit / sum(xinit) * N0; 
main
exes.corr0 = x_interp;

xinit=[0; N0; 0; N0; ones(4,1)*1e-3*N0/4; zeros(12,1)];
xinit([1 2]) = part_susceptible*xinit([1 2]);
xinit([3 4]) = (1-part_susceptible)*xinit([3 4]);
xinit = xinit / sum(xinit) * N0; 
main
exes.corr_neg1 = x_interp;

%%
figure; 
subplot(2,1,1); plot(exes.t, sum(exes.corr1(:,9:12),2), exes.t, ...
    sum(exes.corr0(:,9:12),2), exes.t, sum(exes.corr_neg1(:,9:12),2));
legend("C=1","C=0","C=-1");
hold on;
subplot(2,1,2);
plot(exes.t,sum(exes.corr1(:,17:20),2),exes.t,sum(exes.corr0(:,17:20),2),...
    exes.t,sum(exes.corr_neg1(:,17:20),2))
legend("C=1","C=0","C=-1");