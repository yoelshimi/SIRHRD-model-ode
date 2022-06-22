function csv = readCSVfromTable(name, fdr)
    % by default, looks in +Runners.
    if nargin == 1
        fdr = strtok(name, filesep());
    end
    f = what(convertCharsToStrings( fdr(1)));
    if isempty(f)
        s = dir(fullfile(f.path, "."));
    else
        s = dir(fullfile(f.path, ".."));
    end
    outerDir = s(1).folder;
    % find the files:
    [~, ~, ext] = fileparts(name);
    if ext == "" || isempty(ext)
        ext = "csv";
    end
    name = split(name, filesep());
    file = dir(fullfile(outerDir, "*graph"+name(1), name(2)+"."+ext));
    if isempty(file)
        csv = [];
        return ;
    end
    file = fullfile(file.folder, file.name);
    switch ext
        case "csv"
            csv = csvread(file);
        otherwise
            csv = readmatrix(file);
    end
end