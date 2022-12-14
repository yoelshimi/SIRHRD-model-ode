function [f, fname] = makeTopoGraphGeneral(varargin)
    % function makes a new plot with a topoligical map from data and
    % inputs.
    import Utilities.*

    [data, xField, yField, zField, constraints, fcn] = parseArgs(varargin{:});
    [res, xVals, yVals] = retrieve2mat(data,...
        xField, yField, zField, nan, constraints);

    GraphCode.colorsConfig();
    
    yVals = flipud(yVals);
    res   = fcn(flipud(res(:, :, 1)'));
%     f = figure;  % use the current figure.
    f = gcf;
    ax = gca;
    p = contourf(flattenToRow(xVals), flattenToRow(yVals),...
        res, Ncolours, 'linewidth', 2, "Fill", "on");
    hold on; 
%     colorbar; hold on;
    shading interp ;
    strfun = @(x) strrep(x, "_", " ");
    xField = strfun(xField);
    yField = strfun(yField);
    zField = strfun(zField);
    FontString = {"FontSize",12}; % , 'interpreter', 'none'
    TFString = {"FontSize",12,"FontWeight","bold"};
    xlabel(xField, TFString{:})
    ylabel(yField, TFString{:})
    c = string(fields(constraints));
    v = cellfun(@(x) constraints.(x), c);
    c = {c, v};
    title(sprintf("%s for %s, %s, with %s %s", zField, xField, yField, c{:}), ...
        TFString{:})
    colormap(ax, cmap);
%     fname = GraphCode.saveGraph(f);
end


function [data, xField, yField, zField, constraints, fcn] = parseArgs(varargin)
    % gets the inputs, and any extra become constraints.
    fcn = @(x) x;
    n = nargin;
    data   = varargin{1};
    xField = varargin{2};
    yField = varargin{3};
    zField = varargin{4};

    % extra constraints.
    iter = 5;

    while iter <= n
        if isa(varargin{iter},'function_handle')
            fcn = varargin{iter};
            iter = iter + 1;
            continue;
        end
        constraints.(varargin{iter}) = varargin{iter + 1};
        iter = iter + 2;
    end
end