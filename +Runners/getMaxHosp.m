HOSPIND = 6;
baseDir = "C:\Users\yoel\Dropbox\SocialStructureGraph";
tabDir = fullfile(baseDir, "results from yoel\result tables");
resultsDir = fullfile(baseDir, "matlab\SIRHRD model ode\results");
tabs = dir(tabDir+ "\*.mat");
tabs = tabs(3 : end);
for t = 1 : numel(tabs)
    tabName = tabs(t).name;
    s = load(fullfile(tabDir, tabName));
    if isfield(s, "T") == false
        continue;
    end
    T = s.T;
    fnames = T.output_filenames;
    max_vals = zeros(size(fnames));
    for iter = 1 : height(T)
        files = fnames(iter, :);
        switch T(iter, :).graphType
            case "StructuredGraph"
                prefix = "israel population graph";
            case "DregGraph"
                prefix = "random graph";
            otherwise
                error("shark")
        end
        for iter2 = 1 : numel(files)
            csvFile = prefix+files(iter2)+".csv";
            m = getMaxVal(fullfile(resultsDir, csvFile), HOSPIND);
            max_vals(iter, iter2) = m;
        end

    end
    T.maxHosp = max_vals;

    save(fullfile(tabDir, tabName), "T")
end

function m = getMaxVal(csvfile, valInd)
    if nargin == 1
        valInd = HOSPIND;
    end
    csvdata = csvread(csvfile);
    data = csvdata(valInd, :);
    m = max(data);
end