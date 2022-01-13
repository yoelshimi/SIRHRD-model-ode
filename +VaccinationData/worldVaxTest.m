cd(mfilename);
dataDir = "..\..\..\statistical materials\worldVaxData";

%  age matrix tables
fname = "PPL2020.csv";
ageTable = readtable(fullfile(dataDir, fname), "EmptyValue", NaN,...
    "HeaderLines", 1, "TreatAsEmpty", "...");
ageTable = ageTable(ageTable.ReferenceDate_asOf1July_ == 2020, :);
f = string(fieldnames(ageTable));
f = f(startsWith(f, "x"));
for iter = 1 : numel(f)
    if isnumeric(ageTable.(f(iter))) == false
        ageTable.(f(iter)) = str2double(ageTable.(f(iter)));
    end
end

ageGroupString = str2double( extractBetween(f,"x","_"));
ageSumFun = @(flds) nansum(cell2mat(cellfun(@(x) ageTable.(x), flds,...
    'UniformOutput', false)'), 2);

ageTable.sum = ageSumFun(f);
ageTable.RiskSum = ageSumFun(f(ageGroupString >= 60));
ageTable.notRiskSum = ageSumFun(f(ageGroupString < 60));
save(fullfile(dataDir, "ageTable.mat"), "ageTable");
%%
dataDir = "..\..\..\statistical materials\worldVaxData";

load(fullfile(dataDir, "ageTable.mat"));
%  covid partly vaccinated by age
fname = "covid-fully-vaccinated-by-age.csv";
vaxByAge = readtable(fullfile(dataDir, fname));

UNFACTOR = 1e3;

% stupid index match
AgeDataLoc = cellfun(@(x) find(contains(string(...
    ageTable.Region_Subregion_CountryOrArea_),...
    string(x))), vaxByAge.Entity, 'UniformOutput', false);

indexAgeData = zeros(height(vaxByAge), 1);
ftr = true(height(vaxByAge), 1);

for iter = 1 : numel(AgeDataLoc)
    if isempty(AgeDataLoc(iter)) || isempty(AgeDataLoc{iter})
        indexAgeData(iter) = nan;
        ftr(iter) = false;
    else
        indexAgeData(iter) = AgeDataLoc{iter};
    end
end

emptyVals =  zeros(height(vaxByAge), 1);
vaxByAge.population = emptyVals;
vaxByAge.risk = emptyVals;
vaxByAge.notRisk = emptyVals;

vaxByAge.population(ftr) = ageTable.sum(indexAgeData(ftr));
vaxByAge.risk(ftr) = ageTable.RiskSum(indexAgeData(ftr)) ./ vaxByAge.population(ftr);
vaxByAge.notRisk(ftr) = ageTable.notRiskSum(indexAgeData(ftr)) ./ vaxByAge.population(ftr);

f = string(fieldnames(vaxByAge));
f = f(startsWith(f, "x"));
ageGroupString = str2double( extractBetween(f,"x","_"));
ageSumFun = @(flds) nansum(cell2mat(cellfun(@(x) vaxByAge.(x), flds,...
    'UniformOutput', false)'), 2);

popVaxTable = ageSumFun(f);
% cautiousVaxPop = ageSumFun(ageGroupString < 60);


save(fullfile(dataDir, "vaxByAge.mat"), "vaxByAge");
%%

% for each age group, find the number of people in that group and multiply
% percent from vax table by pop size to get the number of vaccinated people
% in group.
combinedTables = vaxByAge;

n = height(combinedTables);
countryInTable = categorical(string(combinedTables.Entity));
combinedTables.country = countryInTable;
countries = categories(countryInTable);
[G, ID] = findgroups(countryInTable);
combinedTables.Properties.VariableNames = ...
    erase(combinedTables.Properties.VariableNames, "_fully");

vaxAges = getXfields(combinedTables);
UNAges = getXfields(ageTable);
vaxAgeNum = getIdxFromFld(vaxAges);
UNAgesNum = getIdxFromFld(UNAges);
vaxAgeAvg = cellfun(@(x) mean(x), vaxAgeNum);
UNAges = string(UNAges);
vaxAges = string(vaxAges);
% vaxPop = (vaxAges+"_pop");
% for fld = vaxPop'
%     combinedTables.(fld) = zeros(height(combinedTables), 1, "single");
% end
c_states = ["cautiousRisk" "cautiousNotRisk"];
combinedTables.(c_states(1)) = zeros(n, 1, "single");
combinedTables.(c_states(2)) = zeros(n, 1, "single");
combinedTables.ageFakePop = zeros(n, 1, "single");
    
percent2pop = @(x) x / 100;
for iter = 1 : numel(ID)
    ctry = ID(iter);
    % get the values from age table
    ftr = ageTable.Region_Subregion_CountryOrArea_ == ctry;
    if any(ftr) == false
        continue;
    end
    st = ageTable(ftr, :);
    agesVals = arrayfun(@(x) st.(x), UNAges);
    rpAges = cellfun(@(x) mean(x), UNAgesNum);
    popInterp = interp1(rpAges, agesVals, vaxAgeAvg);
    % add to vaccination data
    ftr = countryInTable == ctry;
    if any(ftr) == false
        continue;
    end
    v_flds = 0;
    for iter2 = 1 : numel(popInterp)
        Vinds = isnan(combinedTables(ftr, :).(vaxAges(iter2)));
        if all(Vinds) == true
            continue;
        end
        
        combinedTables(ftr, :).(vaxAges(iter2)) = ...
            combinedTables(ftr, :).(vaxAges(iter2)) * popInterp(iter2) * UNFACTOR / (100 *2);
        
        if vaxAgeAvg(iter2) <= 60
            c_state = "cautiousRisk";
        else
            c_state = "cautiousNotRisk";
        end
        combinedTables(ftr, :).(c_state) = ...
                nansum([combinedTables(ftr, :).(c_state) ...
                combinedTables(ftr, :).(vaxAges(iter2))], 2);
        v_flds = v_flds + 1;
    end
    combinedTables.ageFakePop(ftr) = sum(popInterp) * UNFACTOR / v_flds;
end

cautious = combinedTables.(c_states(1))+combinedTables.(c_states(2));
combinedTables.p_cautious = cautious ./ combinedTables.ageFakePop;
combinedTables.(c_states(1)) = combinedTables.(c_states(1))./ cautious;
combinedTables.(c_states(2)) = combinedTables.(c_states(2))./ cautious;

combinedTables.RC = combinedTables.p_cautious .* combinedTables.cautiousRisk;
combinedTables.nRC = combinedTables.p_cautious .* combinedTables.cautiousNotRisk;
combinedTables.RnC = combinedTables.risk - combinedTables.RC;
combinedTables.nRnC = combinedTables.notRisk - combinedTables.nRC;

combinedTables.pnCifR = combinedTables.RnC ./ (combinedTables.RnC + combinedTables.RC);

save(fullfile(dataDir, "CRdata.mat"), "combinedTables");
%%
k = numel(ID);
randomCountries = randperm(k,10);
f = figure;
b = jet;
for iter = randomCountries
    hold on;
    ftr = combinedTables.Entity == ID(iter);
    idx = find(ftr, randi(sum(ftr)), 'first');
    idx = idx(end);
    sz = combinedTables(idx, :).pnCifR ;
    
    if isnan(sz) || sz < 0 
        continue
    end
    plot(combinedTables(idx, :).p_cautious, ...
        combinedTables(idx, :).risk, ...
        "DisplayName", string(ID(iter)), "MarkerSize", ...
        (sz*20+ 20) / 2,"LineWidth", (sz*20+ 20) / 2,...
        "Marker", "square", "MarkerEdgeColor", b (round(sz*64), :))
end
legend();
xlabel("cautious"); ylabel("risk");
xlim([0 1]); ylim([0 1])
mkdir(fullfile("..\figures", datestr(today)))
saveas(f,fullfile("..\figures", datestr(today), "world vaccination data "+today+".fig"))
saveas(f,fullfile("..\figures", datestr(today), "world vaccination data "+today+".eps"), "epsc")

%%
function f = getXfields(T)
    f = fields(T);
    f = f(startsWith(f, "x"));
end

function t = getIdxFromFld(f)
    t = cell(numel(f), 1);
    for iter = 1 : length(f)
        t(iter) = cellfun(@(x) str2double(x),...
            regexp(f(iter),'\d*', "match"), 'UniformOutput', false);
    end
end