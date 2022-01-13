Rmethods = ["R infections", "R growth inf rate", "R ratio S/R"];
Rmethod = 1:2;
shapes = ["s","o"];
averagingInd = 5;
corrDim = find(size(RRandMatrix) == length(corrs));
types = ["rand", "struct"];
for method = 1:length(Rmethod)
    for iter2 = 1%  :length(types)
        for iter = 1:N_susc
            figure;  hold on;
            mat = squeeze(mean(RRandMatrix(:,iter,method,:,:),averagingInd));
    %         mat = squeeze(RRandMatrix(:,iter,:,:,Rmethod));
            mat2 = squeeze(std(RRandMatrix(:,iter,method,:,:),0,averagingInd));
            for i = 1:size(mat,1)
                errorbar(corrs, mat(i,:,:),mat2(i,:,:),shapes(method)); hold on;
            end
            legend(string(cautions));
            xlabel("correlation");
            ylabel("R0 rate");
            title(Rmethods(method)+" "+types(iter2)+" "+suscs(iter)+" susc")
        end
    end
end
