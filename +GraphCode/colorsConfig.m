% configs colormaps
Ncolours = 25;
c1       = [112 172 105]/1.2;
c2       = [255 220 140];
c3       = [210 31 31]/1.2;
cmap     = arrayfun(@(x) linspace(single(c1(x))/256, ...
    single(c2(x))/256, Ncolours/2+1), 1:length(c2), 'UniformOutput', false);
cmap     = cell2mat(cmap')';
tcmp     = arrayfun(@(x) linspace(single(c2(x))/256, ...
    single(c3(x))/256, Ncolours/2+1), 1:length(c2), 'UniformOutput', false);
tcmp     = cell2mat(tcmp')';
cmap     = [cmap; tcmp(2:end,:)];
