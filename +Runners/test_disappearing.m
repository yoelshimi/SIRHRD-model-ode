
name = datestr(today);
suscs = 0.3;
N_susc = length(suscs);
cautions = linspace(0, 0.8, 33); 
N_cautious = length(cautions);
output_filename = string(name)+filesep()+"sim_run_";
fnamefun = @(x, it1, it2) x+it1+"_"+it2+"_";
RGmode = "manual" ; 
T = table();
isActive = struct("dreg", true, "struct", false, "save", false);
for Biter = 1 : N_cautious
    p_cautious = cautions(Biter);
    for Riter = 1 : N_susc
        p_susc = suscs(Riter);
        fname = fnamefun(output_filename, Riter, Biter);
        [seir, Niter1, Niter2, cfg] = Runners.runMySimulation(p_susc, p_cautious, ...
            fname, RGmode);
        [res(Biter, Riter), T] = Utilities.readSimOutput(fname, Niter1, Niter2, seir, isActive, cfg, T);
    end
end

%%

tStruct = table2struct(T);
[G, ID] = findgroups(T.p_cautious, T.p_risk);
%%
n = max(G); m =  numel(tStruct(1).output_filenames);
csv = cell(n, 1);
fld = "isPeakInfMoreThen1";
% CSV is used here only to display a sample of first value for each group.
for ind = 1 : n
    % by running using disperse, it runs on a group each time.
    [tStruct(G == ind).isOutbreak] = Utilities.disperse(Analysis.isOutbreak(tStruct(G == ind)));
    csv(ind, 1) = cellfun(@(x) Analysis.readCSVfromTable(x, "random*"), ...
            {tStruct(find(G==ind, 1, "first")).output_filenames(1)}, ...
            "UniformOutput", false);
end
figure; cellfun(@(x) plot(x'), csv);
T = struct2table(tStruct);
%%
for fld = convertCharsToStrings(fields(tStruct(1).isOutbreak))'
    for ind = 1 : n
        ctn(ind) = mean([tStruct(G == ind).p_cautious]);

        testVal(ind) =  mean(arrayfun(@(x) nnz(x.(fld)) /  ...
            numel(x.(fld)), [tStruct(G == ind).isOutbreak]));
    end
    plot(ax, ctn, 1-testVal, "bo", "DisplayName", fld);
end
%%
% p_ext        = zeros(n, 1);
extinct_data = load("C:\Users\yoel\Dropbox\SocialStructureGraph\results from yoel"+...
    "\result tables\p_extinct23-Jun-2022.mat");
p_ext        = interp1(extinct_data.p_cautious, extinct_data.p_extinct, [T.p_cautious]);
if exist("n", "var") == false
    m = numel(T.output_filenames(1, :));
    n = height(T);
end
expected_S   = zeros(n, 1);
matches_SEIR = zeros(1, m);
for ind = 1 : n
    figure; hold on;
    it = find(G==ind, 1, "first");
    plot(T(it, :).seir.structMatrix.t, T(it, :).seir.structMatrix.S, "kx");
    expected_S(ind) = T(it, :).seir.structMatrix.S(end);
    for iter = 1 : m
        hold on;
%         y = csv{ind, iter}(1, :)';
%         plot(linspace(0, max(numel(y) ./ [T(ind, :).freq]), numel(y)), y,  "DisplayName", num2str(iter), ...
%             "LineWidth", 10.^(1 - T.isOutbreak(ind).metrics(iter)));
        matches_SEIR(iter) = expected_S(ind) * 2 >= csv{ind, 1}(1, end) && ...
            expected_S(ind) * 1/2 <= csv{ind, 1}(1, end);
    end
    isoutbreak.matches_SEIR = matches_SEIR;
    T.isOutbreak(ind).matches_SEIR = matches_SEIR;

    title(ind+" p(outbreak) tested: "+T.isOutbreak(it).p_outbreak+...
        " p_outbreak theory: "+num2str(1 - p_ext(it)))
end
%%
[G, ID] = findgroups(T.p_cautious);
n = max(G);
y = zeros(n, 1);
for g = 1 : n
    s = [tStruct(G == g).isOutbreak];
    y(g) = mean([s.p_outbreak]);
end
figure; plot(ID, y, "bs", "MarkerSize", 10, "MarkerFaceColor", "g");
%%
k = zeros(n, 1);
for iter = 1 : n
    k(iter) = mean([T.isOutbreak(iter).matches_SEIR]);
end
ftr = all(T.corr == 0, 2);
figure; plot(T(ftr, :).p_cautious, [T(ftr, :).isOutbreak.p_outbreak], "kx", "MarkerSize", 12, ...
    "DisplayName", "theoretical_test");
hold on
plot(T(ftr, :).p_cautious, 1 - p_ext(ftr), "bo", "MarkerSize", 12, ...
    "DisplayName", "muli_theory_SEIR");
hold on; plot([T(ftr, :).p_cautious], k(ftr), "rp", "MarkerSize", 12, ...
    "DisplayName", "actual_result");