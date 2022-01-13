function axes2 = addExplanationToAxes(g, imageLoc)
    % function adds explanation image over axes
    % g - handle to figure
    % imageLoc - location of image file to add to axes.
    if nargin == 1
        loc = split(mfilename("fullpath"), "\");
        imageLoc = fullfile(loc{1 : end - 4}, ...
            "pnas format", "newFigs","potatoFig.pdf" );
    end
    if ls(imageLoc) % exists
        
        disp("image added");
    else
        error("image doesnt exist!");
    end
    axes1 = gca;
    
    axes2 = axes();
    [~, ~, ext] = fileparts(imageLoc);
  

    % Get the new aspect ratio data
    aspect = get(axes1,'PlotBoxAspectRatio');
    % Change axes Units property (this only works with non-normalized units)
    set(axes1,'Units','pixels');
    set(axes2,'Units','pixels');
    % Get and update the axes width to match the plot aspect ratio.
    pos = get(axes1,'Position');
    pos(3) = aspect(1)/aspect(2)*pos(4);
    set(axes1,'Position',pos);
    
    axes2.Position= [pos(1:3) pos(4)*0.2]
    
    switch(ext)
        case ".pdf"
            axes3 = actxcontrol('AcroPDF.PDF.1', axes2.Position, g);
            axes3.LoadFile(imageLoc);
%             axes3.move([5, 5, 410, 440]);
            axes3.setZoom(100);
        case ".bmp"
            im = imread(imageLoc);
            imagesc(axes2, im);
        otherwise error("fahrk")
    end
end