function filename = saveGraph(g, ax, types)
    % function for saving graph into folder of graphs.
    ILLEGAL_CHARS = '[/\*:?"<>|]';
    if nargin <= 1
        ax = gca;
    end
    if nargin == 0
        g = gcf;
    end
        
    fdr    = mfilename("fullpath");
    fparts = strsplit(fdr,filesep());
    fparts = fparts(1 : end - 3);
    fdr    = strjoin(fparts,filesep());
    fdr    = fullfile(fdr,"figures",datestr(today));
    if isfolder(fdr) == false
        mkdir(fdr);
    end
    g.Color = "w";
%     axis square
    ttl = ax.Title.String;
    if isempty(ttl)
        ttl = "graph";
    end
    if size(ttl, 1) > 1 % multiline titles.
        ttl = ttl(1, :);
    end
    if isempty(regexp(ttl, '[/\*:?"<>|]', 'all')) == false
        % latex symbols.
        ttl = erase(ttl, ["_", ",","\", "/"]);
    end
    filename = fullfile(fdr,ttl);
    savefig(g,filename +".fig");
    saveas(g,filename+".eps","epsc");
    if nargin == 3
        saveas(g,filename+"."+types);
    end
end