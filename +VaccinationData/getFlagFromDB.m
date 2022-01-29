function flg = getFlagFromDB(country)
    % returns flag from country using the csv index to get them.
    % opens CSV to get country code from name.
    fdr      = fullfile(fileparts(which("GraphCode.plotCustMark.addImageToPlot")),...
        "+flags");
    csvPath  = fullfile(fdr, "data_csv.csv");
    tab      = readtable(csvPath);
    code     = tab.Code(strcmp(tab.Name, country));
    flagPath = fullfile(fdr, code+".png");
    if isempty(flagPath)
        disp(string(country)+" flag not found");
        flg = nan;
        return;
    end
    [flg, map]      = imread(flagPath, "png");
    flg = ind2rgb(flg, map);
    
end