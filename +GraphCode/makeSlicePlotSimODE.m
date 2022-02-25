parameter = "peakHosp";
slice = ["p_risk", "p_cautious"];
% assumes: p risk == 1 - p cautious
values = unique(T.p_risk) ; %  [0.3 0.4];
val2Percent = @(x) 100*str2num(cell2mat(x));
strfun = @(x) sprintf("%2.0f",x(end)*100);
g = figure; 
%%
%--- ODE ---%
if parameter == "peakHosp"
    SimT.peakHosp = cellfun(@(x) sum(x) , SimT.hosp);
end
subtable = SimT(ismembertol(SimT.(slice(1)) + SimT.(slice(2)), 1, eps) &...
    ismembertol(SimT.(slice(1)), values,eps),:);
% x = unique(subtable.corr);

for iter = 1 : numel(values)
    inds = abs(subtable.(slice(1)) - values(iter)) < eps;
    x{iter} = subtable.RnC(inds);
    if iscell (subtable(inds,:).(parameter))
        y{iter} = cellfun(@(x) sum(x), (subtable(inds,:).(parameter)));
    else
        y{iter} = subtable(inds,:).(parameter);
    end
    factor = 1 / ( mean(subtable.N0)) * 100 ; 
    p(iter) = plot(x{iter},y{iter} * factor,...
        "r-","LineWidth",2, "DisplayName",...
        "ODE model "+strfun(x{iter})+"% "+"\Phi"); hold on;
end
% t1 = y * factor;
p(1).Color = [0.9 0 0];
p(2).Color = [0 0.8 0]
hold on;
%%
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
        x{iter} = st.RnC(:, 1);
        y{iter} = st.(parameter);
%         y = mean(st.(parameter).Variables,2)*4; % removes sb, snb, nsb nsnb and sums
%         y = mean(reshape(y,numel(unique(st.corr)),[]), 2); % mean over columns
%         
        x{iter} = reshape(unique(x{iter}, "stable"), size(mean(y{iter}, 2)));
        factor = 1 / (mean(subtable.N0)) * 100;%  ,7.3233 * 3.3818 *
        p(iter) = plot(x{iter}, mean(y{iter}, 2) * factor,...
            "ko","LineStyle","none","LineWidth",1, ...
            "DisplayName", "Agent D-reg \Phi="+strfun(x{iter})+"%");
        plot(x{iter}, y{iter} .* factor, "k.");
    end
    drawnow
    p(1).MarkerSize = 10;
    p(1).MarkerFaceColor = [1 0.4 0.4]*0.6;
    
    p(2).MarkerSize = 10;
    p(2).MarkerFaceColor = [0.8 1 0.6]*0.6;
%     p(1).Marker = "square";
    p(2).NodeChildren(1).LineWidth = 2;
    p(1).NodeChildren(1).LineWidth = 2;
    hold on;
end
%%
%--- structured simulation ---%
if true
    for iter = 1 : numel(values)
        % assumes: slice(1) values == slice(2) values.
        thisVal = values(iter);
        st = subtable(subtable.(slice(1)) == thisVal & ...
            subtable.graphType == "StructuredGraph", :);
        x{iter} = st.RnC(:, 1);
        y{iter} = st.(parameter);
%         y = mean(st.(parameter).Variables,2)*4; % removes sb, snb, nsb nsnb and sums
%         y = mean(reshape(y,numel(unique(st.corr)),[]), 2); % mean over columns
        x{iter} = reshape(unique(x{iter}, "stable"), size(mean(y{iter}, 2)));
        factor = 1 / ( mean(subtable.N0)) * 100;%  ,7.3233 * 3.3818 *
        p(iter) = plot(x{iter}, mean(y{iter}, 2) * factor,...
            "ko","LineStyle","none","LineWidth",2,...
            "DisplayName", "Agent structured \Phi="+strfun(x{iter})+"%");
        plot(x{iter}, y{iter} .* factor, "k.");
        txt(iter) = text(x{iter}(3)+0.1, y{iter}(3)*factor, str2double(thisVal{1})*100+"% risk");
        p(iter).MarkerSize = 10;
        p(iter).Marker = "square";
    end
    drawnow
    hold on;
    p(1).MarkerFaceColor = [1 0.4 0.4]*0.6;
    p(1).NodeChildren(1).LineWidth = 2;
    p(2).MarkerFaceColor = [0.6 1 0.6]*0.6;
    p(2).NodeChildren(1).LineWidth = 2;
end
drawnow
%%
% -- graph config -- %
xlabel("Probability of caution if at risk");
ylabel("[%] percent hospitalized at peak");
numVals = cell2mat(values);
% l = legend(["ODE model "+val2Percent(values)+"% risk"; ...
%     "Agent on d-regular graph "+val2Percent(values)+"% risk"; ...
%     "Agent on structured graph "+val2Percent(values)+"% risk"; ]');
% l.ItemHitFcn = @hitcallback_ex1;
GraphCode.applyLabel(g);

switch parameter
    case "peakHosp"
        paramName = "hospitalization";
    case "dead"
        paramName = "deceased";
end
g.Color = "w";
title("Peak "+paramName,"FontSize",14);
box off;
% legend boxoff;
grid off;

xlim(xlim + [-0.02 0.02]);
ylim(ylim .* [0.98 1.01]);

GraphCode.saveGraph(g)
%%
% subtable
