
p_risk = 0.7;
p_cautious = unique( SimT.p_cautious(SimT.p_risk == p_risk));
corrs = [0 0.25 0.5 0.75 1];
g=figure;
sgtitle("part at risk: "+p_risk+" part cautious: "+p_cautious)
n = numel(corrs);
for iter = 1 : n
    hold on;
    subplot(1, n, iter);
    corr = corrs(iter);
    title("prob cautious if at risk: "+corr)
    notation = SimT.notation{1};
    data = SimT(SimT.corr == corr & SimT.p_risk == p_risk, :).pop{:};
    [xm, ym] = mosaic_plot(data);
    multi_text(xm(:),ym(:),...
        notation(:)+": "+form_percentage_strings_from_array(data(:)));
end


fdr = mfilename("fullpath");
fparts = strsplit(fdr,filesep());
fparts = fparts(1:end-3);
fdr = strjoin(fparts,filesep());
fdr = fullfile(fdr,"figures",datestr(today));
if isfolder(fdr) == false
    mkdir(fdr);
end
g.Color = "w";
%     ax2 = addExplanationToAxes(g);
savefig(g, fullfile(fdr,"population division"+".fig"));
saveas(g,fullfile(fdr,"population division"+".pdf"));