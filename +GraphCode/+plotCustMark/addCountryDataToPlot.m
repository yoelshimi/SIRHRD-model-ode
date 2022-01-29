function addCountryDataToPlot(tab, f, countryMode)
    % function plots onto axes of f data from table about contries.
    % input: tab, table with country-wise data, countryMode, way of
    % selecting countries, f, figure to be plotted onto.
    % output: void. saves into fixed folder figures / date.
    if nargin == 1
        f = figure;
        countryMode = "random";
    end
    ID = categories(tab.country);
    switch(countryMode)
        case "fixed"
            chosenCountries = [15 14 26 7 23 32 2 5 10];
            %  these are: ["Italy" "Israel" "Romania" "Denmark" "Peru" "Uruguay" ...
            %  "Belgium" "Cyprus" "France"];
            k = numel(chosenCountries);
        case "random"
            k = numel(ID);
            chosenCountries = randperm(k,20);
        case "all"
            chosenCountries = ID;
            k = numel(chosenCountries);
    end

    ax1 = gca;
    b = jet;
    xlim([0 0.5]); ylim([0 1]);
    validCorrs = isnan(tab.pnCifR) == false & ...
        tab.pnCifR >= 0;
    for iter =  chosenCountries
        country = ID(iter);
        hold on;
        ftr = strcmp(tab.Entity, country);
        ftr = ftr & validCorrs;
        % randomly chooses a time when things are valid.
        if any(ftr) == false
            continue;
        end

        idx = find(ftr, randi(nnz(ftr)), 'first');
        idx = idx(end);
        sz = tab(idx, :).pnCifR ;

        if isnan(sz) || sz < 0 
            continue
        end
        x = tab(idx, :).p_cautious;
        y = tab(idx, :).pnCifR;
        ax2 = GraphCode.plotCustMark.addImageToPlot(ax1, x, y, ...
            VaccinationData.getFlagFromDB(country), string(country));
    end
    % legend(ax1);
    xlabel(ax1, "caution"); 
    ylabel(ax1, "prob. not cautious if at risk");
    grid(ax1, "off");
    f.Color = "white";
    fdr = fullfile("..\..\figures", datestr(today));
    mkdir(fdr)
    saveas(f,fullfile(fdr, "world vaccination data "+datestr(today)+".fig"))
    saveas(f,fullfile(fdr, "world vaccination data "+datestr(today)+".eps"), "epsc")

end