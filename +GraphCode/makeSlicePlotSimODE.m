parameter = "hosp";
slice = ["p_risk", "p_cautious"];
% assumes: p risk == 1 - p cautious
values = unique(T.p_risk) ; %  [0.3 0.4];
val2Percent = @(x) 100*str2num(cell2mat(x));
g = figure; 
%--- ODE ---%
subtable = SimT(abs(1 - SimT.(slice(1)) - SimT.(slice(2))) < eps &...
    ismembertol(SimT.(slice(1)), values,eps),:);
x = unique(subtable.corr);
y = [];
for iter = 1 : length(values)
    inds = abs(subtable.(slice(1)) - values(iter)) < eps;
    y(:,iter) = cellfun(@(x) sum(x), (subtable(inds,:).(parameter)));
end
factor = 1 / ( mean(subtable.N0)) * 100 ; % 3.3818 *
p(1) = plot(x,y(:, 1) * factor,"r-","LineWidth",2); hold on;
p(2) = plot(x,y(:, 2) * factor,"r--","LineWidth",2);
t1 = y * factor;
p(1).Color = [0.9 0 0];
p(2).Color = [0 0.8 0];
hold on;

%--- D-regular simulation ---%

subtable = T(abs(1 - T.(slice(1)) - T.(slice(2))) < eps &...
    ismembertol(T.(slice(1)), values,eps),:);
% avoids double comparison issues.
subtable.(slice(1)) = categorical(subtable.(slice(1)));
values = categories(subtable.(slice(1)));
if true
    for iter = 1 : numel(values)
        % assumes: slice(1) values == slice(2) values.
        thisVal = values(iter);
        st = subtable(subtable.(slice(1)) == thisVal & ...
            subtable.graphType == "DregGraph", :);
        x = st.corr(:, 1);
        y = mean(st.(parameter).Variables,2)*4; % removes sb, snb, nsb nsnb and sums
        y = mean(reshape(y,numel(unique(st.corr)),[]), 2); % mean over columns
        x = reshape(unique(x, "stable"), size(y));
        factor = 1 / (3.3818 * mean(subtable.N0)) * 100;%  ,7.3233 * 3.3818 *
        p(iter) = plot(x, y * factor,"ko","LineStyle","none","LineWidth",1);
    end
    drawnow
    p(1).MarkerSize = 10;
    p(1).MarkerFaceColor = [1 0.4 0.4];
    
    p(2).MarkerSize = 10;
    p(2).MarkerFaceColor = [0.8 1 0.6];
    p(2).Marker = "diamond";
    p(2).NodeChildren(1).LineWidth = 2;
    p(1).NodeChildren(1).LineWidth = 2;
    hold on;
end
%--- structured simulation ---%
if true
    for iter = 1 : numel(values)
        % assumes: slice(1) values == slice(2) values.
        thisVal = values(iter);
        st = subtable(subtable.(slice(1)) == thisVal & ...
            subtable.graphType == "StructuredGraph", :);
        x = st.corr(:, 1);
        y = mean(st.(parameter).Variables,2)*4; % removes sb, snb, nsb nsnb and sums
        y = mean(reshape(y,numel(unique(st.corr)),[]), 2); % mean over columns
        x = reshape(unique(x, "stable"), size(y));
        factor = 1 / (3.3818 * mean(subtable.N0)) * 100;%  ,7.3233 *
        p(iter) = plot(x, y * factor,"ks","LineStyle","none","LineWidth",3);
        txt(iter) = text(x(3)+0.1, y(3)*factor, str2double(thisVal{1})*100+"% risk");
    end
    drawnow
    hold on;
    p(1).Marker = "^";
    p(1).MarkerSize = 8;
    p(1).MarkerFaceColor = [1 0.4 0.4];
    p(1).NodeChildren(1).LineWidth = 2;
    p(2).MarkerSize = 10;
    p(2).MarkerFaceColor = [0.6 1 0.6];
    p(2).NodeChildren(1).LineWidth = 2;
end
% -- graph config -- %
xlabel("Probability of caution if at risk");
ylabel("[%] percent hospitalized at peak");
numVals = cell2mat(values);
l = legend(["ODE model "+val2Percent(values)+"% risk"; ...
    "Agent on d-regular graph "+val2Percent(values)+"% risk"; ...
    "Agent on structured graph "+val2Percent(values)+"% risk"; ]');
% l.ItemHitFcn = @hitcallback_ex1;

switch parameter
    case "hosp"
        paramName = "hospitalization";
    case "dead"
        paramName = "deceased";
end
g.Color = "w";
title("Peak "+paramName,"FontSize",14);
box off;
legend boxoff;
grid off;

xlim(xlim + [-0.02 0.02]);
ylim(ylim .* [0.98 1.01]);

fdr = mfilename("fullpath");
if contains(fdr, "temp", "ignorecase", true)
    fdr = "C:\Users\yoel\Dropbox\SocialStructureGraph\matlab\1\1"
end
fparts = strsplit(fdr,filesep());
fparts = fparts(1:end-2);
fdr = strjoin(fparts,filesep());
fdr = fullfile(fdr,"figures",datestr(today));
if isfolder(fdr) == false
    mkdir(fdr);
end

savefig(g, fullfile(fdr,"comparison "+parameter+".fig"));
saveas(g, fullfile(fdr,"comparison "+parameter+".eps"),"epsc");

%%
% subtable
