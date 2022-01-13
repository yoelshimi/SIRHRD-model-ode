function mu = find_mu(PE_func, PIB_func, Q_n, bins)

s = 0;
for n = 1:length(bins)
    s = s + Q_n(n) * PIB_func(x).^n;
end
eqn = @(x)PIB_func(x) * (PE_func(x) * (1 - s) + 1) - 1;
mu = fzero(eqn,2);

end

function eqn_hdl = mu_eqn(PE_func, PIB_func, PL_func, Q_n, bins)
return 
end