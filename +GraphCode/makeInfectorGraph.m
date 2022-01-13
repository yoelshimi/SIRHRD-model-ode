%%
n = 3.3*5000;
cscale = zeros(4,2);
cscale([1 4],2) = 0.01;
cscale([2 3],2) = 1;
figure; 
for iter = 1:4
    subplot(2,2,iter);
    s=pcolor(corrs, cautions, squeeze(mean(structInfMat(:,1,:,:,iter)./n,4)));
    s.FaceColor = 'interp';
    set(s, 'EdgeColor', 'none');
    colormap("hot")
    colorbar;
    caxis(cscale(iter,:));
    xlabel("corr")
    ylabel("part susc")
    title(nms(iter)+"structured")
    grid off; 
end
f(5) = figure; 
for iter = 1:4
    subplot(2,2,iter);
    hold on
    s = pcolor(corrs, cautions, squeeze(mean(randInfMat(:,1,:,:,iter)./n,4)));
    s.FaceColor = 'interp';
    set(s, 'EdgeColor', 'none');
    colormap("hot")
    caxis(cscale(iter,:));
    xlabel("corr")
    ylabel("part susc")
    colorbar;
    title(nms(iter)+"rand")
    grid off; 
end
set(f(5),'color','w');
% savefig(fullfile("SIRHRD model ode","figures","infetorGraph"+datestr(today)+".fig"));
% saveas(f(5),fullfile("..","pnas format","figures","graphs",...
% "infectorGraph"+datestr(today)+".eps"),"epsc");