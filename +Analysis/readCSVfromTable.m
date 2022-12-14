function thisCSV = readCSVfromTable(name, pattern, fdr)
    % by default, looks in +Runners.
    d = dir(fullfile(mfilename("fullpath"), "..", "..", "+Runners"));
    cd (d(1).folder)
    if ischar(name)
        name = convertCharsToStrings(name);
    end
    if nargin < 3
        fdr = strtok(name{1}, filesep());
    end
    if nargin < 2
        pattern = "*graph";
    end
    f = what(convertCharsToStrings( fdr));
    if isempty(f)
        s = dir(fullfile(f.path, "."));
    else
        s = dir(fullfile(f.path, ".."));
    end
    outerDir = s(1).folder;
    % find the files:
    [~, ~, ext] = fileparts(name{1});
    if ext == "" || isempty(ext)
        ext = "csv";
    end
    name = squeeze(split(name, filesep()));
    file = dir(fullfile(outerDir, pattern+name(1), name(2)+"."+ext));
    if isempty(file)
        thisCSV = [];
        return ;
    end
    thisCSV = cell(numel(file), 1);
    for iter = 1 : numel(file)
        f_read = fullfile(file(iter).folder, file(iter).name);
        switch ext
            case "csv"
                thisCSV{iter} = csvread(f_read);
            otherwise
                thisCSV{iter} = readmatrix(f_read);
        end
    end
    % returns cell matrix of results, unless one result returned, then
    % matrix.
    if iter == 1
        thisCSV = thisCSV{1};
    end
end