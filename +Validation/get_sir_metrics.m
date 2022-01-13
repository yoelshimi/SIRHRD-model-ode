function get_sir_metrics(x,t)
    [~,x_max_i] = max(sum(x(:,5:8),2));
    t_max = t(x_max_i)
    % global R rate check:
    pop = sum(x(1,:));
    p_decrease_i = (pop - sum(x(x_max_i,1:4))) / pop;
    R_global = 1-1/p_decrease_i;
    
    % R rate per category:
    pop = x(1,1:4) + x(1,5:8);
    [~,x_max_i] = max(x(:,5:8));
    p_decrease_i = (pop - diag(x(x_max_i,1:4))') ./ pop;
    R_comp = 1-1./p_decrease_i;
    
    R_global
    R_comp
end