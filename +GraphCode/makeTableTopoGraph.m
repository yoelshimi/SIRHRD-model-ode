function g = makeTableTopoGraph(odeTable,valField, name, idx, flg)
    % function to make topographical map of values from table data.
    if nargin == 1
            valField = "hosp";
    end
    if nargin <= 2
            name = "";
    end
    if nargin <= 3
            idx = nan;
            flg = "percent";
    end

    subTable = odeTable(odeTable.p_risk == 1 - odeTable.p_cautious,:);
    popSize = mean(subTable.N0(:));

    [Data, corrs, p_risk] = Utilities.retrieve2mat...
        (subTable,"nCifR","p_risk",[valField], idx);
    if flg ~= "data"
        Data = Data / popSize * 100;
        probToPercent = @(x) 100 * x;
    else
        probToPercent = @(x) x;
    end
    GraphCode.colorsConfig();
    sval_to_plot = [0.6] %  [0.3 0.4];
    g = figure;
    p1 = contourf(corrs', probToPercent (p_risk'), Data(:, :, 1)'...
        ,Ncolours,'linewidth',2,"Fill","off");hold on;
    p2 = contourf(corrs', probToPercent (p_risk'), Data(:, :, 1)'...
        ,Ncolours,'linewidth',2,"Fill","on");hold on;    
    
    for iter = 1 : length(sval_to_plot)    
        hold on; 
        plot(corrs', probToPercent(...
            sval_to_plot(iter))*ones(length(corrs),1),"w--","linewidth", 3)
    end
    colorbar; hold on;
    shading interp ;
    
    FontString = {"FontSize",10};
    TFString = {"FontSize",10,"FontWeight","bold"};
    
    ylabel("Percent [%] at high risk, not cautious",...
        FontString{:})
    title("Hospitalized percent [%] at peak stress", ...
        TFString{:})
    xlabel("percent of non cautious at risk")
    
    colormap(g,cmap);
    
%     ylim([40 100])
    fdr = mfilename("fullpath");
    fparts = strsplit(fdr,filesep());
    fparts = fparts(1:end-2);
    fdr = strjoin(fparts,filesep());
    fdr = fullfile(fdr,"figures",datestr(today));
    if isfolder(fdr) == false
        mkdir(fdr);
    end
    g.Color = "w";
    axis square
 
%     ax2 = addExplanationToAxes(g);
    savefig(g, fullfile(fdr,"graph "+valField+name+".fig"));
    saveas(g,fullfile(fdr,"graph "+valField+name+".eps"),"epsc");
    saveas(g,fullfile(fdr,"graph "+valField+name+".emf"));
end