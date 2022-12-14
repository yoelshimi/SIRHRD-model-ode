parameter   = "peakHosp";
slice       = ["p_risk", "p_cautious"];
% assumes: p risk == 1 - p cautious
values      = uniquetol(T.(slice(1))); %  [0.3 0.4];
values2     = flip(uniquetol(T.(slice(2))));
values2     = values2(1);
values      = values(1);
val2Percent = @(x) 100*str2num(cell2mat(x));
strfun      = @(x) sprintf("%2.0f",x(end)*100);
g           = figure; 
if exist('p','var') && any( ~ ishghandle(p))
    clear("p");
end

% filters out valid indices: input: table. output: filtered indices.
constraint1 = @(x) ismembertol(x.(slice(1)), values,eps);
constraint2 = @(x) true(size(x, 1), 1); %  ismembertol(x.(slice(1)) + x.(slice(2)), 1, eps);
colors = {[0.5 1 0.5]; [1 0.5 0.5]; };
%%
%--- ODE ---%
if parameter == "peakHosp"
    SimT.peakHosp = cellfun(@(x) sum(x) , SimT.hosp);
end
subtable = SimT(constraint2(SimT) & constraint1(SimT),:);
% x = unique(subtable.corr);
% for iter2 = 1 : numel(values2)
for iter = 1 : numel(values)
    for iter2 = 1 : numel(values2)
    inds = ismembertol(subtable.(slice(1)), values(iter), eps);
    inds = inds & ismembertol(subtable.(slice(2)), values2(iter2),  eps);
    x{iter} = subtable.RnC(inds);
    if iscell (subtable(inds,:).(parameter))
        y{iter} = cellfun(@(x) sum(x), (subtable(inds,:).(parameter)));
    else
        y{iter} = subtable(inds,:).(parameter);
    end
    factor = 1 / ( mean(subtable.N0)) * 100 ; 
    p(iter) = plot(x{iter},y{iter} * factor,...
        "r-","LineWidth",2, "DisplayName",...
        "ODE model "+strfun(median(x{iter}))+"% "+"\Phi"+...
        " "+slice(1)+"="+values(iter)+...
        " "+slice(2)+"="+values2(iter2)); hold on;
    end
end
% end
% t1 = y * factor;
% p(2).Color = [0.7 0.2 0.2];
p(1).Color = [0 0.6 0];
hold on;
%%
%--- D-regular simulation ---%

subtable = T(constraint2(T) & constraint1(T),:);
% avoids double comparison issues by using categorical.
subtable.(slice(1)) = categorical(subtable.(slice(1)));
values = categories(subtable.(slice(1)));
% subtable.(slice(2)) = categorical(subtable.(slice(2)));
% values2 = categories(subtable.(slice(2)));
values      = values(1);
if true
    for iter2 = 1 : numel(values2)
        for iter = 1 : numel(values)
            % assumes: slice(1) values == slice(2) values.
            thisVal = values(iter);
            thisVal2 = values2(iter2);
            st = subtable(subtable.(slice(1)) == thisVal & ...
                subtable.(slice(2)) == thisVal2 & ...
                subtable.graphType == "DregGraph", :);
            if isempty(st)
                continue;
            end
            x{iter} = st.RnC(:, 1);
            y{iter} = st.(parameter);
    %         y = mean(st.(parameter).Variables,2)*4; % removes sb, snb, nsb nsnb and sums
    %         y = mean(reshape(y,numel(unique(st.corr)),[]), 2); % mean over columns
    %         
            x{iter} = reshape(unique(x{iter}, "stable"), size(mean(y{iter}, 2)));
            factor = 1 / (mean(subtable.N0)) * 100;%  ,7.3233 * 3.3818 *
%             plot(x{iter}, y{iter} .* factor, "k.");
%             [~, p(iter)] = ...
            GraphCode.plotAreaErrorBar(y{iter}' * factor, ...
                struct("handle", g, "x_axis", x{iter}', "error", "std1.5", ...
                "color_area", colors{iter}, "alpha", 0.7, "color_line", colors{iter}, ...
                "line_width", 0));
            p(iter) = plot(x{iter}, mean(y{iter}, 2) * factor,...
                "ko","LineStyle","none","LineWidth",1, ...
                "DisplayName", "Agent D-reg \Phi="+strfun(x{iter})+"%");
            txt(iter) = text(x{iter}(3), y{iter}(3)*factor - 0.1, ...
                str2double(thisVal{1})*100+"% risk", "FontSize", 8);
        end
    end
    drawnow
%     set(p, "MarkerSize", 3);
%     set(p, "MarkerFaceColor", "w" ) ;
%     p(2).NodeChildren(1).LineWidth = 1;
    Utilities.applyToOutputs(p, "NodeChildren", "LineWidth", 2)
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
%         plot(x{iter}, y{iter} .* factor, "k.");
        GraphCode.plotAreaErrorBar(y{iter}' * factor, ...
            struct("handle", g, "x_axis", x{iter}', "error", "std1.5", ...
            "color_area", colors{iter}, "alpha", 0.8, "color_line", colors{iter}, ...
            "line_width", 0))
        p(iter) = plot(x{iter}, mean(y{iter}, 2) * factor,...
            "ko","LineStyle","none","LineWidth",2,...
            "DisplayName", "Agent structured \Phi="+strfun(x{iter})+"%");
        p(iter).MarkerSize = 10;
        p(iter).Marker = "square";
    end
    drawnow
    hold on;
%     p(1).MarkerFaceColor = "w";
    p(1).NodeChildren(1).LineWidth = 2;
%     p(2).MarkerFaceColor = "w";
%     p(2).NodeChildren(1).LineWidth = 2;
end
drawnow
%%
% -- graph config -- %
xlb = xlabel("\Phi"); % Probability of caution if at risk
xlb.FontWeight = "bold"
txt.Visible = "off";
ylabel("[%] percent hospitalized at peak");
numVals = cell2mat(values);
% l = legend(["ODE model "+val2Percent(values)+"% risk"; ...
%     "Agent on d-regular graph "+val2Percent(values)+"% risk"; ...
%     "Agent on structured graph "+val2Percent(values)+"% risk"; ]');
% l.ItemHitFcn = @hitcallback_ex1;
% GraphCode.applyLabel(g);

switch parameter
    case "peakHosp"
        paramName = "hospitalization";
    case "dead"
        paramName = "deceased";
end
g.Color = "w";
ttl = title("Peak "+paramName,"FontSize",14);
box off;
ttl.Visible = "off";
% legend boxoff;
grid off;

xlim([0 1]);
ylim(ylim .* [0.98 1.01]);

GraphCode.saveGraph(g, gca, "emf")
%%
% subtable
