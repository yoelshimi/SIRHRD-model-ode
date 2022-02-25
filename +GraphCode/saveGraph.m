function filename = saveGraph(g, ax)
    % function for saving graph into folder of graphs.
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
    if contains(ttl, "\")
        % latex symbols.
        ttl = erase(ttl, ["_", ",","\"]);
    end
    filename = fullfile(fdr,ttl);
    savefig(g,filename +".fig");
    saveas(g,filename+".eps","epsc");
%     saveas(g,filename+".emf");
end