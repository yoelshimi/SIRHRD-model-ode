
function [rates, err, x, t, gofs, runInputs] = testVaxDecrease(vaxEfficiency, p_cautious,...
    SimInput, infections, hospitalized, extra_input)
    betaList = [vaxEfficiency.^2, vaxEfficiency ,1];
    SimInput.p_cautious = p_cautious;
    SimInput.betaList = betaList;
    
    [tspan, param, xinit] = SimInput.getODEParams();
    % x(1) = Ssb, x(2)=Ssnb, x(3)= Snsnb, x(4) = Snsb
    if nargin == 6
        inf_0  = extra_input.inf_0;
        hosp_0 = extra_input.hosp_0;
        s = sum(xinit);
        xinit(5:8)  = inf_0;
        xinit(9:12) = hosp_0;
        xinit = xinit * s / sum(xinit);
    end
    [x,t]=SEIRodeSolver_YR(tspan,param,xinit);
    runInputs = struct("tspan", tspan, "param", param, "xinit", xinit);
    
    dInfs_est = sum(x(:,5:8), 2);
    dHosp_est = sum(x(:,9:12), 2);
    [decreaseInfFit, gof] = fit(t, dInfs_est,'exp1');
    disp("R squared: "+gof.adjrsquare)
    [decreaseHospFit, gof2] = fit(t,dHosp_est,'exp1');
    disp("R squared: "+gof2.adjrsquare)
    
    rates = [decreaseInfFit.b,decreaseHospFit.b];
    gofs = [gof, gof2];
    fits = {decreaseInfFit, decreaseHospFit};
    
    t_test = tspan(1):tspan(end);
    fittedDataOld = [infections, hospitalized];
    fittedDataNew = [expFitVals(fits(1), t_test), ...
        expFitVals(fits(2), t_test)];
    
    err = sqrt(sum(fittedDataOld.^2 - fittedDataNew.^2,1)) ./ norm(fittedDataOld);

end