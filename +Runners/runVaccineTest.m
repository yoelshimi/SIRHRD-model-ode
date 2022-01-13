N0 = 9e6;
pVaccine    = 0.9%0.3:0.3:0.9;
%  percentage of infection ability the vaccine reduces.
% probability of vaccinated to get sick.
vEfficiency = linspace(0,1,61);
% probability of a non-vaccinated person being cautious.
pnCgivenV     = linspace(0,1,71);
init_inf    = 1e-6;
gamma=1/10;
gammaH=1/20;
R=5;
tspan = [0 365];
calcFactor = 0.5;
model = "SEIR";
caution = 1 - 0.85;
vnames = ["probVax","efficacy","pCfromNV","pnCfromV","xinit","Hosp","Dead","maxI",...
    "maxItime","expA","R0fit","RSquared"];
VTable = table('Size',[numel(pVaccine)*numel(vEfficiency)*numel(pnCgivenV),...
     numel(vnames)],...
    'VariableTypes',[repmat("double",1,4),repmat("cell",1,5),repmat("double",1,3)],...
    'VariableNames',vnames);
cnt = 1;

PNCgivenV_2_pCgivenS_func = @(pC,pS,pNCgivenV) ...
    (pC - 1 + pS + pNCgivenV .* (1 - pS)) ./ pS;
%%
betaCaution = [caution^2 caution 1];

for iterVax = 1 : length(pVaccine)
    probVax = pVaccine(iterVax);
    pS = 1 - probVax;
    pC = pS;
    for iterEfficacy = 1 : length(vEfficiency)
        efficiency = vEfficiency(iterEfficacy);
        notEff      = 1 - efficiency;
        betaVax = [notEff^2*R*gamma notEff*R*gamma R*gamma];
        
        pH=[0.2 0.2*notEff];
        pD=[0.2 0.2*notEff];
        for iterCorr = 1 : length(pnCgivenV)
            probNotCautiousgVax = pnCgivenV(iterCorr);
            
%             pCgivenS = PNCgivenV_2_pCgivenS_func(pC,pS,probNotCautiousgVax);
            
            param=[betaVax/N0 betaCaution gamma gammaH pH pD];
            %  p Susc - is p Vax. p cautious = p vax.
            mat = VaxCorr2MAT(pS,probNotCautiousgVax) ;
            % nonSymCorr(pC, pS, pCgivenS);
            pCgivenS = 0;
            noVaxCautious   = mat(1,2);  % nVC
            noVaxnoCautious = mat(1,1);  % nVnC
            vaxNoCautious   = mat(2,1);  % VNC
            vaxCautious     = mat(2,2);  % VC
            
            xinit_s = N0 * [noVaxCautious; noVaxnoCautious;...
                vaxNoCautious; vaxCautious;];
            xinit = [xinit_s; xinit_s*init_inf; zeros(12,1)];
            xinit = xinit / sum(xinit) * N0; 
            % call model.
            [x,t]=SEIRVaccineSolver(tspan,param,xinit);
            i1 = iterVax; i2 = iterEfficacy; i3 = iterCorr;
            not_s(i1,i2,i3,:) = xinit(1:4)' - x(end,1:4);
            % measure hospitalization for compartments
            [max_i,t_max_ind] = max(x(:,5:8));
            t_max_i = t(t_max_ind);
            
            TtoMaxParts(i1,i2,i3,:) = t_max_i;
%             infected(i1) = {sum(x(:,5:8),2)};
            % measure hospitalization overall
             [~,t_max_ind] = max(sum(x(:,9:12),2));
            t_max_h = t(t_max_ind);
            TtoMaxHosp(i1,i2,i3,:) = t_max_h;
            Hosp(i1,i2,i3,:) = x(t_max_ind,9:12);...
                %  ./ (x(1,1:4) + x(1,5:8));
            % 
            Dead(i1,i2,i3,:) = x(end,17:20); 
            %  ./ ((x(1,1:4) + x(1,5:8)).*reshape([pD;pD].*[pH;pH],1,4));
%              Correlation(i1,i2,i3) = (sb*nsnb - snb*nsb);
    %         snb_(i1, i2) = mat(1,1); sb_(i1) = mat(1,2);
            infs = sum(x(:,5:8),2);
            [f0,gof] = calcGrowth(t, infs,  tspan, calcFactor);
            grRate(i1,i2,i3,:) = [f0.a, f0.b, gof.adjrsquare];
%             ["probVax","efficacy","pCfromNV","xinit","Hosp","Dead","maxI",...
%     "maxItime","expA","R0fit","RSquared"]
            VTable(cnt,:) = table(probVax,efficiency,pCgivenS,probNotCautiousgVax,...
                {xinit(1:4)'},{x(t_max_ind,9:12)},{x(end,17:20)},{max_i},...
                {t_max_i'},f0.a,f0.b, gof.adjrsquare);
            cnt = cnt + 1;
        end
    end
end
% VTable = table(r
%%

    f=figure;
plotVals = pVaccine %0.3:0.3:0.9;
n = length(plotVals);
for iter = 1 : n

    subplot(1,n,iter); hold on;
    ind = find(abs(pVaccine - plotVals(iter)) < eps);
    mat = cellfun(@(x) sum(x), VTable.Hosp);
    mat = reshape(mat, length(unique(VTable.efficacy)), length(unique(VTable.pnCfromV)));
%     mat = squeeze(grRate(ind,:,:,2));
%     [locx,locy] = interpForZeros(mat, pnCgivenV, vEfficiency);
%     contourf(pnCgivenV, vEfficiency, mat, 10);
    if all(isnan(locx)) == false
        hold on;
        loc2 = smooth(locx,5); % 
        loc2(isnan(medfilt1(locx,9))) = nan;
        locy2 = smooth(locy,5);
        locy2(isnan(medfilt1(locy,9))) = nan;
        plot(loc2, vEfficiency, "k.-","LineWidth",3); hold on;
        plot(pnCgivenV, locy2, "k.-","LineWidth",3);
    end
    title(pVaccine(ind)*100+"% Vaccinated");
    xlabel("Probability of not cautious if vaccinated",'fontweight','bold')
    ylabel("Efficiency",'fontweight','bold');
    colorbar;
%     caxis([-0.1 0.35])
    
    
    colorsConfig();
    colormap(f,cmap);
    f.Color = "w";
    sgtitle("Partially vaccinated infected growth rate [per day]");
    set(gca,'linewidth',2)
    set(gca,'fontweight','bold')
%     saveas(f,fullfile(fdr,"vaxGraph"+...
%         datestr(today)+plotVals(iter)+".svg"))
end
    fdr = fullfile("C:\Users\yoel\Dropbox\SocialStructureGraph\"+...
        "matlab\SIRHRD model ode\figures",datestr(today));
    if isfolder(fdr) == false
        mkdir(fdr);
    end
    
%     savefig(fullfile(fdr,"vaxGraph"+...
%         datestr(today)+".fig"))
%     saveas(f,fullfile(fdr,"vaxGraph"+...
%         datestr(today)+".eps"),"epsc")

